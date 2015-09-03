
#import "FootMarkVC.h"
#import "SWRevealViewController.h"

//Map Framework
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#import "ParseDBSource.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>

#import "MyAnnotation.h"
#import "UIImage+CustomUIImageEffect.h"







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

@property(nonatomic, strong) ParseDBSource *pe;

@property(nonatomic, strong) MyAnnotation *photoPoint;

@property(nonatomic) NSInteger *selectTag;

//大頭針陣列
@property(nonatomic, strong) NSMutableArray *pointArray;



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
    
    _pointArray = [[NSMutableArray alloc] init];
    //單例模式
    NSInteger num = 0;
    _pe = [ParseDBSource shared];
    for (PFObject *obj in _pe.parseData) {
        //大頭針初始化
        _photoPoint = [[MyAnnotation alloc] init];
        //取經緯度
        _photoPoint.coordinate = CLLocationCoordinate2DMake([obj[@"postLocation"] latitude], [obj[@"postLocation"] longitude]);
        _photoPoint.title = obj[@"postState"];
        _photoPoint.subtitle = [self retunPostDate:[obj createdAt]];
        _photoPoint.tag = num;
        
        //原圖的縮略圖==>placeHolder
        PFFile *thumbnail = obj[@"photo"];
        NSData *imageData = [thumbnail getData];
        UIImage *thumbnailImage = [UIImage imageWithData:imageData];
        thumbnailImage = [UIImage imageCompressWithSimple:thumbnailImage scaledToSizeWidth:50 scaledToSizeHeight:50];
        _photoPoint.photoImage = thumbnailImage;
        [_pointArray addObject:_photoPoint];
        num++;
    }
    [_myFootMap addAnnotations:_pointArray];
}


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
    if (annotation == _myFootMap.userLocation) {
        return nil;
    }
    
    //先到資源回收桶找有沒有不要使用的大頭針-->如果沒有則create一個新的大頭針
    MKPinAnnotationView *customPin = (MKPinAnnotationView*)[_myFootMap dequeueReusableAnnotationViewWithIdentifier:@"customPin"];
    if (customPin == nil) {
        customPin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"customPin"];
    }
    
    if ([annotation isKindOfClass:[MyAnnotation class]]) {
        customPin.tag = annotation.tag;
        customPin.canShowCallout = YES;
        customPin.animatesDrop = NO;
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
        customPin.animatesDrop = NO;
        
        //導航功能加入
        //UIButtonTypeDetailDisclosure-->就是旁邊的驚嘆號
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //用程式碼去實現Button的監聽
        //forControlEvents-->參數是事件的種類
        [rightButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        customPin.rightCalloutAccessoryView = rightButton;
    }
    return customPin;
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view{
    NSLog(@"%ld", view.tag);
    _selectTag = view.tag;
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
//    targetMapItem.name = _tmpRestaurant.name;
    
    //呼叫Apple Map後，可以帶參數過去
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
    //原地和指定地點的導航(單一指定位置)
    [targetMapItem openInMapsWithLaunchOptions:options];
}







////更新user經緯度-->私有方法
//-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//    //取user位置的最新一筆Coordinate(座標)
//    _currentLocationCoordinate = [locations.lastObject coordinate];
////    //設置地圖的顯示範圍
////    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(_currentLocationCoordinate, 80000.0f, 80000.0f);
////    [_myFootMap setRegion:region animated:YES];
//}


















/*
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
