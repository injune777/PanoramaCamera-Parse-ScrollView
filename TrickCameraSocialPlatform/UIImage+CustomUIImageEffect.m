
#import "UIImage+CustomUIImageEffect.h"
#import "JTSImageInfo.h"
#import "JTSImageViewController.h"
<<<<<<< HEAD
#import "CRMotionView.h"
=======

#import "CRMotionView.h"

>>>>>>> 89fcf08305daeb4af4b547ecc55c4a3dc920448b
@implementation UIImage (CustomUIImageEffect)

//網路縮圖方法
+(UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSizeWidth:(CGFloat)width scaledToSizeHeight:(CGFloat)height
{
    CGSize size;
    size.width = width;
    size.height = height;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0,size.width,size.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


//照片縮小 image,最大寬高-->比例縮小??-->待確認
+(UIImage*)imageWithImageSimple:(UIImage*)image scaledToSize:(CGSize)newSize
{
    float width,height;
    if (image.size.width<newSize.width && image.size.height<newSize.height){
        //如果已經小於newSize則不縮小
        width=image.size.width;
        height=image.size.height;
    }else if (image.size.height >= (newSize.height/newSize.width)*image.size.width){
        width=image.size.width/image.size.height*newSize.height;
        height=newSize.height;
    }else{
        height=image.size.height/image.size.width*newSize.height;
        width=newSize.width;
    }
    newSize.width=width;
    newSize.height=height;
    // Create a graphics image context
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    // Return the new image.
    return newImage;
}




//點擊照片跳出Method-->使用第三方庫-->https://github.com/jaredsinclair/JTSImageViewController
+(void)createTapPictureJTSImageViewController:(UIImage*)inputImage
                           withInputImageView:(UIImageView*)inputImageView
                      withInputViewController:(UIViewController*)inputViewController {
    
    
    
    
//    [inputImageView addSubview:motionView];
    

//    //Create image info
//    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
//    imageInfo.image = inputImage;
//    imageInfo.referenceRect = inputImageView.frame;
//    imageInfo.referenceView = inputImageView.superview;
    
    
    
    
    
    // Setup view controller
    JTSImageViewController *imageViewerVC = [[JTSImageViewController alloc]
                                           initWithImageInfo:nil
                                           mode:JTSImageViewControllerMode_Image
                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
    
    
    CRMotionView *motionView = [[CRMotionView alloc] initWithFrame:CGRectMake(150, 350, inputImage.size.height, inputImage.size.width)];
    motionView.image = inputImage;
    
    
    [imageViewerVC.view addSubview:motionView];
    
    // Present the view controller.
<<<<<<< HEAD

    
    CRMotionView *motionView = [[CRMotionView alloc] initWithFrame:inputImageView.bounds];
    [motionView setImage:[UIImage imageNamed:@"3.jpg"]];
    [inputImageView addSubview:motionView];
    
    [imageViewer showFromViewController:inputViewController transition:JTSImageViewControllerTransition_FromOriginalPosition];
=======
    [imageViewerVC showFromViewController:inputViewController transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
    
    
    
    
    

    
    
//    // Create image info
//    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
//    imageInfo.image = inputImage;
//    imageInfo.referenceRect = inputImageView.frame;
//    imageInfo.referenceView = inputImageView.superview;
//    // Setup view controller
//    JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
//                                           initWithImageInfo:imageInfo
//                                           mode:JTSImageViewControllerMode_Image
//                                           backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
//    // Present the view controller.
//    [imageViewer showFromViewController:inputViewController transition:JTSImageViewControllerTransition_FromOriginalPosition];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
>>>>>>> 89fcf08305daeb4af4b547ecc55c4a3dc920448b
}








//圖片放大動畫效果-->http://code4app.com/ios/%E7%82%B9%E8%B5%9E%E5%8A%A8%E7%94%BB/53e9cfa2933bf08a248b52d8
+(void) animationScaleImage:(UIImage*)scaleImage scaleImageView:(UIImageView*)scaleImageView{
    scaleImageView.layer.contents = (id)scaleImage.CGImage;
    CAKeyframeAnimation *k = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    k.values = @[@(0.1),@(1.0),@(1.6)];
    k.keyTimes = @[@(0.0),@(0.3),@(0.8),@(1.0)];
    k.calculationMode = kCAAnimationLinear;
    [scaleImageView.layer addAnimation:k forKey:@"SHOW"];
}


//會自己算出最適合的呈現區域
+(UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize  sourceImage:(UIImage *)sourceImage{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth= width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else if (widthFactor < heightFactor)
        {
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(targetSize); // this will crop
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width= scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}



@end
