
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


@interface DiscoverTBC ()<CLLocationManagerDelegate>

//Slide Bar
@property(nonatomic, strong) UIBarButtonItem *slideBarBtn;

//CLLocationManager一定要設成全局變量，才可以使用代理模式
@property(nonatomic, strong) CLLocationManager *myLocationManager;

@property(nonatomic, strong) NSArray *nearMeParse;

@end

@implementation DiscoverTBC

- (void)viewDidLoad {
    [super viewDidLoad];

    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //初始化nearMeParse
    _nearMeParse = [[NSArray alloc] init];
    
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
            NSLog(@"座標物件~~~%@", geoPoint.description);
            //User's location
            // Create a query for places
            PFQuery *query = [PFQuery queryWithClassName:@"travel"];
            // Interested in locations near user.
            [query whereKey:@"location" nearGeoPoint:geoPoint];
            // Limit what could be a lot of points.
            query.limit = 10;
            // Final list of objects
            _nearMeParse = [query findObjects];
            NSLog(@"最近景點物件~~%@",_nearMeParse[0]);
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
    
    cell.nameLbl.text = _nearMeParse[indexPath.row][@"Name"];
    
    cell.kmLbl.text = @"122公里";
    cell.theImageView.image = [UIImage imageNamed:@"1.jpg"];
    
    
    
    
    return cell;
}

//更新user經緯度-->私有方法
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //取user位置的最新一筆Coordinate(座標)
//    _currentLocationCoordinate = [locations.lastObject coordinate];
    NSLog(@"%@", locations.firstObject);
    NSLog(@"test");
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
