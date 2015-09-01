
#import "UIImageView+ClipAndspecific.h"

@implementation UIImageView (ClipAndspecific)


//陰影效果
+(UIImageView*) imageViewWithShadow:(UIImageView*)imageView withColor:(UIColor*)color{
    imageView.layer.shadowColor= color.CGColor;
    imageView.layer.shadowOffset=CGSizeMake(0,0);
    imageView.layer.shadowOpacity=0.5;
    imageView.layer.shadowRadius=5.0;
    return imageView;
}

//Personal Head clip to circle
+(UIImageView*) imageViewWithClipCircle:(UIImageView*)imageView{
    imageView.layer.cornerRadius = imageView.frame.size.width/2;
    imageView.clipsToBounds = YES;
    return imageView;
}

@end

