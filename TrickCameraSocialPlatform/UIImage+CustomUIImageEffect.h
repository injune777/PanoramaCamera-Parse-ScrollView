
#import <UIKit/UIKit.h>

@interface UIImage (CustomUIImageEffect)

//網路縮圖方法
+(UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSizeWidth:(CGFloat)width scaledToSizeHeight:(CGFloat)height;

//照片縮小 image,最大寬高-->等比例縮小??-->待確認
+(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize;

+(UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize  sourceImage:(UIImage *)sourceImage;

//點擊照片跳出Method-->使用第三方庫-->https://github.com/jaredsinclair/JTSImageViewController
+(void)createTapPictureJTSImageViewController:(UIImage*)inputImage
                           withInputImageView:(UIImageView*)inputImageView
                      withInputViewController:(UIViewController*)inputViewController;

//圖片放大動畫效果
+(void) animationScaleImage:(UIImage*)scaleImage scaleImageView:(UIImageView*)scaleImageView;
@end
