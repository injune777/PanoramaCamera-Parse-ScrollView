
#import "MapVC.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MyAnnotation.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "NSObject+SearchParse.h"
#import "UIImage+CustomUIImageEffect.m"

#import "SWRevealViewController.h"


@interface MapVC ()<MKMapViewDelegate, CLLocationManagerDelegate>


@property (weak, nonatomic) IBOutlet MKMapView *theMap;
@property (weak, nonatomic) IBOutlet UISegmentedControl *select;

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic) CLLocationCoordinate2D theCoordinate;

//大頭針陣列
@property(nonatomic, strong) NSMutableArray *pointArray;
@property(nonatomic, strong) NSMutableArray *parseDB;

@property(nonatomic) NSInteger *selectTag;

//Slide Bar
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sliderBar;


@end

@implementation MapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_sliderBar setTintColor:[UIColor orangeColor]];
    self.navigationItem.leftBarButtonItem = _sliderBar;
    //Slide Bar Menu
    SWRevealViewController *revealViewController = [self revealViewController];
    if (revealViewController) {
        //調整寬度
        revealViewController.rearViewRevealWidth = 220;
        [_sliderBar setTarget:self.revealViewController];
        [_sliderBar setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }

    
    //初始化地理位置管理員
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    _locationManager.delegate = self;
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [_locationManager requestAlwaysAuthorization];
        [_locationManager startUpdatingLocation];
    }
    //地圖初始化
    _theMap.delegate = self;
    _theMap.mapType = MKMapTypeStandard;
    //不要跟
//    _theMap.userTrackingMode=MKUserTrackingModeFollow;
    _theMap.showsUserLocation = YES;
    
    
    _parseDB = [[NSMutableArray alloc] init];
    _pointArray = [[NSMutableArray alloc] init];
    //初始化大頭針
    PFUser *currentUser = [self getOneUserInfo:@"RbUnhp98yE"];
    
    //取得指定user所有拍過的照片
    [NSObject getFocusUserAllPostPhotoWithUserID:currentUser.objectId
                                      completion:^(NSMutableArray *completion){
                                          _parseDB = completion;
                                          NSInteger num = 0;
                                          for (PFObject *obj in _parseDB) {
                                              NSLog(@"%@", obj.description);
                                              //大頭針初始化
                                              MyAnnotation *photoPoint = [[MyAnnotation alloc] init];
                                              //取經緯度
                                              photoPoint.coordinate = CLLocationCoordinate2DMake([obj[@"postLocation"] latitude],
                                                                                                  [obj[@"postLocation"] longitude]);
                                              photoPoint.title = obj[@"postState"];
                                              photoPoint.subtitle = [self retunPostDate:[obj createdAt]];
                                              photoPoint.tag = num;
                                              
                                              //原圖的縮略圖==>placeHolder
                                              PFFile *thumbnail = obj[@"photo"];
                                              NSData *imageData = [thumbnail getData];
                                              UIImage *thumbnailImage = [UIImage imageWithData:imageData];
                                              thumbnailImage = [UIImage imageCompressWithSimple:thumbnailImage
                                                                              scaledToSizeWidth:50 scaledToSizeHeight:50];
                                              photoPoint.photoImage = thumbnailImage;
                                              [_pointArray addObject:photoPoint];
                                              num++;
                                          }
                                          [_theMap removeAnnotations:_pointArray];
                                          [_theMap addAnnotations:_pointArray];
                                          
                                          NSLog(@"%ld", _pointArray.count);
                                      }];
}

//日期轉字串
-(NSString*) retunPostDate:(NSDate*)postDateOfData{
    //NSDate轉字符串-->發佈日期
    NSDate *postDate = postDateOfData;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateString = [dateFormatter stringFromDate:postDate];
    return currentDateString;
}


//負責顯示大頭針的UI
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(MyAnnotation*)annotation{
    
    //如果是系統的大頭針，則return nil
    if (annotation == _theMap.userLocation) {
        return nil;
    }
    
    //先到資源回收桶找有沒有不要使用的大頭針-->如果沒有則create一個新的大頭針
    MKPinAnnotationView *customPin = (MKPinAnnotationView*)[_theMap
                                                            dequeueReusableAnnotationViewWithIdentifier:@"customPin"];
    if (customPin == nil) {
        customPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                    reuseIdentifier:@"customPin"];
    }
    
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        customPin.tag = annotation.tag;
        customPin.canShowCallout = YES;
        customPin.animatesDrop = NO;
        //要不要加?
        customPin.annotation = annotation;
        
        
        //Pin附加Accessory
        UIImageView *theImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        //圖片栽剪成圓形
        theImageView.layer.cornerRadius = theImageView.frame.size.width/2;
        theImageView.clipsToBounds = YES;
        //照片
        theImageView.contentMode = UIViewContentModeScaleToFill;
        theImageView.image = annotation.photoImage;
        customPin.leftCalloutAccessoryView = theImageView;
        customPin.animatesDrop = YES;
        
        //導航按鈕
        UIButton *rightBUtton = [[UIButton alloc] init];
        rightBUtton.frame = CGRectMake(0, 0, 40, 40);
        [rightBUtton setTitle:@"導航" forState:UIControlStateNormal];
        [rightBUtton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        rightBUtton.backgroundColor = [UIColor orangeColor];
        [rightBUtton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        customPin.rightCalloutAccessoryView = rightBUtton;
    }
    return customPin;
}


//更新user經緯度-->私有方法
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
}

//用戶位置
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    _theCoordinate = _theMap.userLocation.location.coordinate;
    NSLog(@"哈哈點%f", _theCoordinate.latitude);
    NSLog(@"哈哈點%f", _theCoordinate.longitude);
    
    //设置地图的中心到用户的位置
    _theMap.centerCoordinate = _theCoordinate;
    //设置地图的缩放范围
    MKCoordinateSpan span = MKCoordinateSpanMake(0.1, 0.1);
    MKCoordinateRegion region = MKCoordinateRegionMake(_theCoordinate, span);
    [_theMap setRegion:region animated:YES];
    
}


- (IBAction)selectAction:(id)sender {
    switch ([sender selectedSegmentIndex]){
            //附近
        case 0:
            //设置地图的中心到用户的位置
            _theMap.centerCoordinate = _theCoordinate;
            //设置地图的缩放范围
            MKCoordinateSpan span1 = MKCoordinateSpanMake(0.2, 0.);
            MKCoordinateRegion region1 = MKCoordinateRegionMake(_theCoordinate, span1);
            [_theMap setRegion:region1 animated:YES];
            break;
            //環島
        case 1:
            _theMap.centerCoordinate = _theCoordinate;
            //设置地图的缩放范围
            MKCoordinateSpan span2 = MKCoordinateSpanMake(3, 3);
            MKCoordinateRegion region2 = MKCoordinateRegionMake(_theCoordinate, span2);
            [_theMap setRegion:region2 animated:YES];
            break;
        default:
            break;
    }
    
}

//取得特定的userInfo
-(PFUser*)getOneUserInfo:(NSString*)userID{
    PFUser *postedUser = [PFQuery getUserObjectWithId:userID];
    return postedUser;
}

//導航按鈕-->地址轉經緯度後，開始導航(結合—>轉經緯度+導航)
-(void)buttonPressed:(UIButton*)sender{
    sender.tag = _selectTag;
    
    //拍照的經緯度-->目的地
    CLLocationCoordinate2D coordias = [_pointArray[sender.tag] coordinate];
    
    //創造第2個MapItem—>導航用的專屬物件(屬於MapKit)-->目的地
    MKPlacemark *targetPlace = [[MKPlacemark alloc] initWithCoordinate:coordias addressDictionary:nil];
    //地圖導航用的物件-->目的地
    MKMapItem *targetMapItem = [[MKMapItem alloc] initWithPlacemark:targetPlace];
    
    //呼叫Apple Map後，可以帶參數過去
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
    //原地和指定地點的導航(單一指定位置)
    [targetMapItem openInMapsWithLaunchOptions:options];
}



@end

