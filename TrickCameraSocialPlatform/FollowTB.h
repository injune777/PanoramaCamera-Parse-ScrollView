
#import <UIKit/UIKit.h>

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface FollowTB : UITableViewController

@property(nonatomic, strong) NSMutableArray *followArray;

@end
