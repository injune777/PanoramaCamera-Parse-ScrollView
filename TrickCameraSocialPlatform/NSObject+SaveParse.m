
#import "NSObject+SaveParse.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation NSObject (SaveParse)



//Parse取得指定的物件-->更新物件用
+(void) getObjectWithClassName:(NSString*)className withObjectID:(NSString*)ObjectID
                      fetchBlock:(void(^)(PFObject *pfObject))fetchBlock{
    //搜尋的table
    PFQuery *query = [PFQuery queryWithClassName:className];
    //取得指定物件
    PFObject *object =  [query getObjectWithId:ObjectID];
    if (fetchBlock) {
        fetchBlock(object);
    }
    //更新範例
    //如果要直接更新parse資料庫，再加這個即可-->設定更新的值域後saveInBackground
    //[object saveInBackground];
    //getObjectInBackgroundWithId-->另一種語法(前面是Query)
}


//刪除user已按喜歡的文章
+(void)removeFocusUserLikeWithPhotoID:(NSString*)photoID withUserID:(NSString*)userID
                       completions:(void(^)())completions{
    //判斷是否喜歡某張pos文的照片-->雙重限制查詢
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    [query whereKey:@"photoID" equalTo:photoID];
    [query whereKey:@"userID" equalTo:userID];
    
    //刪除物件
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        PFObject *removeObj = results[0];
        [removeObj deleteInBackground];
        [removeObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (completions) {
                completions();
            }
        }];
    }];
}

//刪除指定user的追蹤
+(void)removeFolloweringWithUser:(PFUser*)user
                   withOtherUser:(PFUser*)otherUser
                     completions:(void(^)(BOOL completion))completion{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    [query includeKey:@"follower"];
    [query includeKey:@"followering"];
    [query whereKey:@"follower" equalTo:user];
    [query whereKey:@"followering" equalTo:otherUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        //刪除正在追蹤的人
        PFObject *removeObj = objects[0];
        [removeObj deleteInBackground];
        [removeObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if (completion) {
                completion(YES);
            }
        }];
    }];
}

//創建特定Table的記錄->採Block方法
+(void)saveOneObjectWithClassName:(NSString*)className
                      complection:(void(^)(PFObject *pfObject))complection{
    PFObject *obj = [PFObject objectWithClassName:className];
    if (complection) {
        complection(obj);
    }
    //Block用法範例
    //[pfObject setObject:@"RbUnhp98yE" forKey:@"photoID"];
    //[pfObject setObject:@"RbUnhp98yEaaa" forKey:@"userID"];
    //[pfObject saveInBackground];
}



@end
