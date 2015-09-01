
#import "NSObject+BlurImageView.h"
#import <UIKit/UIKit.h>

@implementation NSObject (BlurImageView)

//模糊效果
+(UIImageView*)getBlurImageViewWithImage:(UIImage*)image withRect:(CGRect)rect{
    
    //Background view
    UIImageView *backImageView = [[UIImageView alloc] init];
    backImageView.image = image;
    //模糊渲染
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    //模糊View
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = rect;
    visualEffectView.alpha = 1;
    [backImageView addSubview:visualEffectView];
    return backImageView;
}


@end



