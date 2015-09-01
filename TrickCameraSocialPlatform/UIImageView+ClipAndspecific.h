
#import <UIKit/UIKit.h>

@interface UIImageView (ClipAndspecific)

//陰影效果
+(UIImageView*) imageViewWithShadow:(UIImageView*)imageView withColor:(UIColor*)color;
//栽剪成圓形
+(UIImageView*) imageViewWithClipCircle:(UIImageView*)imageView;


@end
