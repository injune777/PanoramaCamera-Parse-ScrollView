
#import "LocationManager.h"

//地理位置Library
#import <CoreLocation/CoreLocation.h>

@interface LocationManager()<CLLocationManagerDelegate>

//現在經緯度座標
@property(nonatomic, assign) CLLocationCoordinate2D currentLocationCoordinate;
//CLLocationManager一定要設成全局變量，才可以使用代理模式
@property(nonatomic, strong) CLLocationManager *myLocationManager;
@end


@implementation LocationManager

-(id) init{
    self = [super init];
    if(self){
        //初始化地理位置管理員
        _myLocationManager = [[CLLocationManager alloc] init];
        //設定精確度
        [_myLocationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
        //設定委託給viewController
        _myLocationManager.delegate = self;
        
        //判別是否有支援這個方法-->才用的手法-->因為此方法在ios8以後才支援
        //跳出【總是授權的Dialog】
        if ([_myLocationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            //此方法在ios8以後才支援
            //如果是總是授權的方式，這裡要用-->requestAlwaysAuthorization
            //如果是當使用時授權的方式，這裡要用-->.....When......
            [_myLocationManager requestAlwaysAuthorization];
        }
        
        //開始計算所在位地置的功能
        [_myLocationManager startUpdatingLocation];

        return self;
    }
    return  nil;
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


//計算user離餐廳距離-->計算的時機??
-(void) calculateDistanceWithRestaurantLatitude:(double)latitude withRestaurantLongitude:(double)longtitude
           withCompletion:(void(^)(CLLocationDistance meters))completion{
    //餐廳的坐標
    CLLocation *restaurantLocation=[[CLLocation alloc] initWithLatitude:latitude longitude:longtitude];
    //user的緯經度
    double userLongitude = _currentLocationCoordinate.longitude;
    double userLatitude = _currentLocationCoordinate.latitude;
    //User的坐標
    CLLocation *userLocation=[[CLLocation alloc] initWithLatitude:userLatitude longitude:userLongitude];
    // 計算距離
    CLLocationDistance meters = [userLocation distanceFromLocation:restaurantLocation]/1000;
    completion(meters);
}



//更新user經緯度-->私有方法
-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    //取user位置的最新一筆Coordinate(座標)
    _currentLocationCoordinate = [locations.lastObject coordinate];
}

//取得經緯度
-(CLLocationCoordinate2D) getCoordinate{
    return _currentLocationCoordinate;
}


@end
