
#import <Foundation/Foundation.h>

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface NSObject (SaveParse)



//更新物件-->可Parse取得指定的物件，然後再用block更新資料
+(void) getObjectWithClassName:(NSString*)className withObjectID:(NSString*)ObjectID
                      fetchBlock:(void(^)(PFObject *pfObject))fetchBlock;

//刪除user已按喜歡的文章
+(void)removeFocusUserLikeWithPhotoID:(NSString*)photoID withUserID:(NSString*)userID
                       completions:(void(^)())completions;

//創建特定Table的記錄->採Block方法
+(void)saveOneObjectWithClassName:(NSString*)className
                      complection:(void(^)(PFObject *pfObject))complection;

//刪除指定user的追蹤
+(void)removeFolloweringWithUser:(PFUser*)user
                   withOtherUser:(PFUser*)otherUser
                     completions:(void(^)(BOOL completion))completion;



@end
