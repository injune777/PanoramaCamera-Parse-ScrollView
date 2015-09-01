
#import <Foundation/Foundation.h>

//地理位置Library
#import <CoreLocation/CoreLocation.h>

@interface LocationManager : NSObject

//經緯度轉地址
-(void) LocationZipCodeWithLatitude:(double)latitude withLongitude:(double)longitude
         withCompletion:(void(^)(CLPlacemark *placemark))completion;

//計算user離餐廳距離
-(void) calculateDistanceWithRestaurantLatitude:(double)latitude
                        withRestaurantLongitude:(double)longtitude
                                 withCompletion:(void(^)(CLLocationDistance meters))completion;
@end
