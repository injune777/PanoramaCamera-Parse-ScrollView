
#import "DiscoverTBC.h"
#import "SWRevealViewController.h"
#import "DiscoverCell.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#import <CoreLocation/CoreLocation.h>

#import "UIImageView+WebCache.h"
#import "UIImageView+ClipAndspecific.h"

#import "DetailVC.h"

//轉轉轉
#import <PQFCustomLoaders/PQFCustomLoaders.h>



@interface DiscoverTBC ()<CLLocationManagerDelegate>

//Slide Bar
@property(nonatomic, strong) UIBarButtonItem *slideBarBtn;

//CLLocationManager一定要設成全局變量，才可以使用代理模式
@property(nonatomic, strong) CLLocationManager *myLocationManager;

@property(nonatomic, strong) NSMutableArray *nearMeParse;
@property(nonatomic, strong) NSArray *tempArray;
@property(nonatomic, strong) NSMutableArray *stringArray;

//現在經緯度座標
@property(nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate;
//轉轉轉
@property (nonatomic, strong) PQFBouncingBalls *bouncingBalls;

@end

@implementation DiscoverTBC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //轉轉轉
    _bouncingBalls = [PQFBouncingBalls createModalLoader];
    _bouncingBalls.loaderColor = [UIColor orangeColor];
    _bouncingBalls.jumpAmount = 60;
    _bouncingBalls.zoomAmount = 50;
    _bouncingBalls.separation = 30;
    _bouncingBalls.diameter = 20;
    _bouncingBalls.label.text = @"請稍候...";
    _bouncingBalls.label.textColor = [UIColor orangeColor];
    _bouncingBalls.fontSize = 20;
    //開始轉轉
    [_bouncingBalls showLoader];

    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //初始化nearMeParse
    _nearMeParse = [[NSMutableArray alloc] init];
    _tempArray = [[NSArray alloc] init];
    _stringArray = [[NSMutableArray alloc] init];
    
    //初始化地理位置管理員
    _myLocationManager = [[CLLocationManager alloc] init];
    //設定委託給viewController
     _myLocationManager.delegate = self;
    //設定精確度
    [_myLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    //授權
    [_myLocationManager requestAlwaysAuthorization];
    //開始計算所在位地置的功能
    [_myLocationManager startUpdatingLocation];
    
    
    _slideBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slideBar.png"]
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:nil];
    [_slideBarBtn setTintColor:[UIColor orangeColor]];
    self.navigationItem.leftBarButtonItem = _slideBarBtn;
    //Slide Bar Menu
    SWRevealViewController *revealViewController = [self revealViewController];
    if (revealViewController) {
        //調整寬度
        revealViewController.rearViewRevealWidth = 220;
        [_slideBarBtn setTarget:self.revealViewController];
        [_slideBarBtn setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    
    //經緯度轉成Parse用的object
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        if (!error) {
            //User's location
            // Create a query for places
            PFQuery *query = [PFQuery queryWithClassName:@"travel"];
            // Interested in locations near user.
            [query whereKey:@"location" nearGeoPoint:geoPoint];
            // Limit what could be a lot of points.
            query.limit = 200;
            // Final list of objects
            _tempArray = [query findObjects];
            for (PFObject *obj in _tempArray) {
                NSString *tmpStr = obj[@"Name"];
                if ([_stringArray containsObject:tmpStr] == NO) {
                    [_nearMeParse addObject:obj];
                    [_stringArray addObject:tmpStr];
                }
            }
            //停止轉轉
            [_bouncingBalls setHidden:YES];
            [self.tableView reloadData];
        }
    }];
}



#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_nearMeParse count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DiscoverCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    
    //設定文字的斷點
    cell.nameLbl.lineBreakMode = NSLineBreakByTruncatingTail;
    //設定文字的粗體和大小
    cell.nameLbl.font = [UIFont boldSystemFontOfSize:17.0f];
    //設定文字的粗體和大小
    cell.nameLbl.font = [UIFont boldSystemFontOfSize:17.0f];
    //設定文字的粗體和大小
    cell.stateLbl.font = [UIFont boldSystemFontOfSize:17.0f];
    //設定文字的粗體和大小
    cell.kmLbl.font = [UIFont boldSystemFontOfSize:17.0f];
    
  
    cell.nameLbl.text = _nearMeParse[indexPath.row][@"Name"];
    NSString *urlStr = [_nearMeParse[indexPath.row][@"Picture1"]
                        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    [cell.theImageView sd_setImageWithURL:url
                         placeholderImage:[UIImage imageNamed:@"1.jpg"]
                                  options:SDWebImageProgressiveDownload];
    
    [self LocationZipCodeWithLatitude:[_nearMeParse[indexPath.row][@"location"] latitude]
                        withLongitude:[_nearMeParse[indexPath.row][@"location"] longitude]
                       withCompletion:^(CLPlacemark *placemark) {
                           cell.stateLbl.text =  placemark.locality;
                       }];

    [self calculateDistanceWithRestaurantLatitude:[_nearMeParse[indexPath.row][@"location"] latitude]
                          withRestaurantLongitude:[_nearMeParse[indexPath.row][@"location"] longitude]
                                   withCompletion:^(CLLocationDistance meters) {
                                       cell.kmLbl.text = [NSString stringWithFormat:@"%.0f公里", meters];
                                   }];
    
    return cell;
}



//更新user經緯度-->私有方法
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //取user位置的最新一筆Coordinate(座標)
    _currentLocationCoordinate = [locations.lastObject coordinate];
}


//經緯度轉地址
-(void) LocationZipCodeWithLatitude:(double)latitude withLongitude:(double)longitude
                     withCompletion:(void(^)(CLPlacemark *placemark))completion{
    CLLocation *locaiton = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    //創造一個地理編碼管理員在負責地址轉經緯度
    CLGeocoder *geoder = [CLGeocoder new];
    //開始把經緯度轉換成地址
    [geoder reverseGeocodeLocation:locaiton completionHandler:^(NSArray *placemarks, NSError *error){
        CLPlacemark *placemark = placemarks[0];
        completion(placemark);
    }];
}


//計算user離餐廳距離
-(void) calculateDistanceWithRestaurantLatitude:(double)latitude withRestaurantLongitude:(double)longtitude
                                 withCompletion:(void(^)(CLLocationDistance meters))completion{
    //餐廳的坐標
    CLLocation *restaurantLocation=[[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
    //user的緯經度
    double userLongitude = _currentLocationCoordinate.longitude;
    double userLatitude = _currentLocationCoordinate.latitude;
    //User的坐標
    CLLocation *userLocation=[[CLLocation alloc] initWithLatitude:userLatitude longitude:userLongitude];
     //計算距離
    CLLocationDistance meters = [userLocation distanceFromLocation:restaurantLocation]/1000;
    completion(meters);
}


//傳值
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //取得點擊的列
    NSIndexPath *path = [self.tableView indexPathForSelectedRow];
    if ([segue.identifier isEqualToString:@"detailVC"]) {
        DetailVC *targeView = segue.destinationViewController;
        targeView.detailObj = _nearMeParse[path.row];
    }
}











/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
