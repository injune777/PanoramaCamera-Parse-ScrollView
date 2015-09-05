
#import <UIKit/UIKit.h>

//parse and facebook 登入
#import <Parse/Parse.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

@interface DetailVC : UIViewController

@property(nonatomic, strong) PFObject *detailObj;



@end
