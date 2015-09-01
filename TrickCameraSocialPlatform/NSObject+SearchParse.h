
#import <Foundation/Foundation.h>

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface NSObject (SearchParse)

//獲取所有照片的information
+(void)getAllPhotoInfo:(void(^)(NSMutableArray *outPut))completions;

//取得特定的userInfo
+(PFUser*)getOneUserInfo:(NSString*)userID;

//取得photo特定的message
+(NSArray*)getFocusPhotoIDToMessage:(NSString*)photoID;

//取得指定user的所有發文照片 + 留言次數 + 按喜歡次數 + post文日期 + postName
+(void) getFocusUserAllPostPhotoWithUserID:(NSString*)userID
                                completion:(void(^)(NSMutableArray *completion))completion;


//查詢指定user是否是另一個user的追隨者(follower)
//userID-->目前的使用者
//otherUserID-->點擊到的頁面的user
+(void)getFoucsUserIsOtherUserFollowerWithUserID:(PFUser*)focusUser  withOtherUserID:(PFUser*)otherUser
                                      completion:(void(^)(BOOL completion))completion;

//查我的追隨者人數(follower) + 和什麼人
+(void)getFollowerNumbersWithCurrentUser:(PFUser*)currentUser
                              completion:(void(^)(NSMutableArray *completion))completion;

//查我正在追隨的人數(followering) + 和什麼人
+(void)getFolloweringNumbersWithCurrentUser:(PFUser*)currentUser
                                 completion:(void(^)(NSMutableArray *completion))completion;

@end
