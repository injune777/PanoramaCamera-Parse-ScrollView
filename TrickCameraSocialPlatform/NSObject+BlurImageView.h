
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSObject (BlurImageView)

//模糊效果
+(UIImageView*)getBlurImageViewWithImage:(UIImage*)image withRect:(CGRect)rect;

@end
