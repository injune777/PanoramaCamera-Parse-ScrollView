

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TestAnnotation : NSObject<MKAnnotation>

/** 坐标位置 */
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 子标题 */
@property (nonatomic, copy) NSString *subtitle;

@end
