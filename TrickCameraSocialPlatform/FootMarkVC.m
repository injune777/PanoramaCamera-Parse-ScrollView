
#import "FootMarkVC.h"
#import "SWRevealViewController.h"

//Map Framework
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "TestAnnotation.h"



@interface FootMarkVC ()<MKMapViewDelegate, CLLocationManagerDelegate>

//地圖
@property (weak, nonatomic) IBOutlet MKMapView *myFootMap;
//Slide Bar
@property(nonatomic, strong) UIBarButtonItem *slideBarBtn;



//位置管理員
@property(nonatomic, strong) CLLocationManager *locationManager;
//現在經緯度座標
@property(nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate;
//大頭針物件
@property(nonatomic, strong) MKPointAnnotation *myPoint;


@end

@implementation FootMarkVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Slide Bar Menu初始化
    _slideBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slideBar.png"]
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:nil];
    [_slideBarBtn setTintColor:[UIColor orangeColor]];
    self.navigationItem.leftBarButtonItem = _slideBarBtn;
    SWRevealViewController *revealViewController = [self revealViewController];
    
    if (revealViewController) {
        //調整寬度
        revealViewController.rearViewRevealWidth = 220;
        [_slideBarBtn setTarget:self.revealViewController];
        [_slideBarBtn setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
    
    

    //初始化地理位置管理員
    _locationManager = [[CLLocationManager alloc] init];
    //設定精確度
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    //設定委託給viewController
    _locationManager.delegate = self;
    //判別是否有支援這個方法-->才用的手法-->因為此方法在ios8以後才支援
    //跳出【總是授權的Dialog】
    if ([_locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        //此方法在ios8以後才支援
        //如果是總是授權的方式，這裡要用-->requestAlwaysAuthorization
        //如果是當使用時授權的方式，這裡要用-->.....When......
        [_locationManager requestAlwaysAuthorization];
    }
    //開始計算所在位地置的功能
    [_locationManager startUpdatingLocation];
    
    
    //地圖初始化
    //代理
    _myFootMap.delegate = self;
    //地圖類型
    _myFootMap.mapType = MKMapTypeStandard;
    //顯示user當前位置
    _myFootMap.showsUserLocation = YES;
    
    //user大頭針
    MKPointAnnotation *userPoint1 = [[MKPointAnnotation alloc] init];
    userPoint1.title = @"fuck";
    userPoint1.subtitle = @"damit it";
    userPoint1.coordinate = CLLocationCoordinate2DMake(23.74544, 120.75464);
    
    MKPointAnnotation *userPoint2 = [[MKPointAnnotation alloc] init];
    userPoint2.title = @"fuck";
    userPoint2.subtitle = @"damit it~~~~~~~~~~~~~~~";
    userPoint2.coordinate = CLLocationCoordinate2DMake(23.63955, 120.78846);
    
    
    [_myFootMap addAnnotations:@[userPoint1, userPoint2]];
    
    
    
    
    
    
}

//負責顯示大頭針的UI
-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    
    //先到資源回收桶找有沒有不要使用的大頭針-->如果沒有則create一個新的大頭針
    MKPinAnnotationView *customPin = (MKPinAnnotationView*)[_myFootMap dequeueReusableAnnotationViewWithIdentifier:@"customPin"];
    if (customPin == nil) {
        customPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"customPin"];
    }
    customPin.canShowCallout = YES;
    customPin.animatesDrop = NO;
    customPin.annotation = annotation;
    customPin.animatesDrop = YES;
    
    return customPin;

    
}








//更新user經緯度-->私有方法
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //取user位置的最新一筆Coordinate(座標)
    _currentLocationCoordinate = [locations.lastObject coordinate];
    
    
    
    
    
    
    
    
    
    
    
//    //設置地圖的顯示範圍
//    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_currentLocationCoordinate, 80000.0f, 80000.0f);
//    [_myFootMap setRegion:region animated:YES];
}


















/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
