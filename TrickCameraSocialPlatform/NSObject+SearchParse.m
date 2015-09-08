#import "NSObject+SearchParse.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation NSObject (SearchParse)

//獲取所有照片的information
+(void)getAllPhotoInfo:(void(^)(NSMutableArray *outPut))completions{
    //要搜尋的class-->Photos
    PFQuery *photoQuery = [PFQuery queryWithClassName:@"Photos"];
    //發文時間的排序
    [photoQuery orderByDescending:@"createdAt"];
    [photoQuery includeKey:@"userPID"];
    
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *outputs, NSError *error) {
        
        //Background thread
        dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
        dispatch_async(bg1, ^{
            if (error){
                NSLog(@"Error: %@", error.description);
                return;
            }
            //調用Block前要先判斷，如果呼叫時為nil的block的話，就忽略~~
            NSMutableArray *tempAry = [[NSMutableArray alloc] init];
            //為了判斷是否喜歡某張照片而存在
            PFUser *me = [PFUser currentUser];
            NSString *meID =[me objectId];
            for (PFObject *tempObj in outputs) {
                
                //取得訊息集合
                NSArray *messageAry = [NSObject getFocusPhotoIDToMessage:tempObj.objectId];
                [tempObj setObject:messageAry forKey:@"messageAry"];
                
                //取得是否喜歡該照片
                [NSObject getFocusUserLikeWithPhotoID:tempObj.objectId withUserID:meID completion:^(NSString *completion){
                    dispatch_queue_t bg2 = dispatch_queue_create("bg2", nil);
                    dispatch_async(bg2, ^{
                        if ([completion isEqualToString:@"yes"]) {
                            [tempObj setObject:@"yes" forKey:meID];
                        }else{
                            [tempObj setObject:@"no" forKey:meID];
                        }
                        
                        //有問題
//                        [tempObj saveInBackground];
                        [tempObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                            [tempAry addObject:tempObj];
                            if (completions) {
                                //轉型為NSMutableArray
                                completions((NSMutableArray*)tempAry);
                            }
                        }];
                    });
                }];
            }
        });
    }];
}


//取得photo特定的message集合
+(NSArray*)getFocusPhotoIDToMessage:(NSString*)photoID{
    PFQuery *messageQuery = [PFQuery queryWithClassName:@"Messages"];
    //加了這個才能把userPID的詳細資訊借用過來，因為usrPID是個指標-->好用
    [messageQuery includeKey:@"userPID"];
    [messageQuery orderByDescending:@"createdAt"];
    [messageQuery whereKey:@"photoID" equalTo:photoID];
    NSArray *messages = [messageQuery findObjects];
    return messages;
}

//取得photo特定的喜歡集合
+(NSArray*)getFocusPhotoIDToLikes:(NSString*)photoID{
    PFQuery *likesQuery = [PFQuery queryWithClassName:@"Likes"];
    [likesQuery orderByDescending:@"createdAt"];
    [likesQuery whereKey:@"photoID" equalTo:photoID];
    NSArray *likes = [likesQuery findObjects];
    return likes;
}


//取得指定user的所有發文照片 + 留言次數 + 按喜歡次數 + post文日期 + postName
+(void) getFocusUserAllPostPhotoWithUserID:(NSString*)userID
                                completion:(void(^)(NSMutableArray *completion))completion{
    //這裡使用-->不知會不會有問題
    dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
    dispatch_async(bg1, ^{
        PFQuery *photoQuery = [PFQuery queryWithClassName:@"Photos"];
        [photoQuery includeKey:@"userPID"];
        //排序
        [photoQuery orderByDescending:@"createdAt"];
        //很重要因為該欄位我設為point，所以要尋找時，只能用轉成PFObject的型態去找
        PFUser *userPoint = [NSObject getOneUserInfo:userID];
        [photoQuery whereKey:@"userPID" equalTo:userPoint];
        NSArray *photos = [photoQuery findObjects];
        //Block回傳值
        if (completion) {
            completion((NSMutableArray*)photos);
        }

        
    });
}


//判斷是否喜歡某張pos文的照片-->雙重限制查詢
//私有方法
+(void)getFocusUserLikeWithPhotoID:(NSString*)photoID withUserID:(NSString*)userID
                        completion:(void(^)(NSString *completion))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Likes"];
    //第一個限制條件
    [query whereKey:@"photoID" equalTo:photoID];
    //第二個限制條件
    [query whereKey:@"userID" equalTo:userID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
        if ([results count] >= 1) {
            completion(@"yes");
        }else{
            completion(@"no");
        }
    }];
}

//查詢指定user是否是另一個user的追隨者(follower)
//userID-->目前的使用者
//otherUserID-->點擊到的頁面的user
//很重要因為該欄位設為pointer，所以要尋找時，只能用轉成PFObject的型態去找
+(void)getFoucsUserIsOtherUserFollowerWithUserID:(PFUser*)focusUser  withOtherUserID:(PFUser*)otherUser
                                      completion:(void(^)(BOOL completion))completion{
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    
    //第一個限制條件-->現在user
    [query whereKey:@"follower" equalTo:focusUser];
    //第二個限制條件-->要查詢是否追隨的人
    [query whereKey:@"followering" equalTo:otherUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
        if (completion) {
            if ([results count] > 0) {
                completion(YES);
            }else{
                completion(NO);
            }
            
        }
    }];
}

//查我的追隨者人數(follower) + 和什麼人
+(void)getFollowerNumbersWithCurrentUser:(PFUser*)currentUser
                              completion:(void(^)(NSMutableArray *completion))completion{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    //加includeKey才可以pointer的欄位的詳細資料包進來
    [query includeKey:@"follower"];
    [query includeKey:@"followering"];
    [query whereKey:@"followering" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (completion) {
            completion((NSMutableArray*)objects);
        }
    }];
}

//查我正在追隨的人數(followering) + 和什麼人
+(void)getFolloweringNumbersWithCurrentUser:(PFUser*)currentUser
                                 completion:(void(^)(NSMutableArray *completion))completion{
    
    PFQuery *query = [PFQuery queryWithClassName:@"Follow"];
    //加includeKey才可以把pointer的欄位的詳細資料包進來
    [query includeKey:@"follower"];
    [query includeKey:@"followering"];
    [query whereKey:@"follower" equalTo:currentUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        if (completion) {
            completion((NSMutableArray*)objects);
        }
    }];
}



//取得特定的userInfo
+(PFUser*)getOneUserInfo:(NSString*)userID{
    PFUser *postedUser = [PFQuery getUserObjectWithId:userID];
    return postedUser;
}

@end
