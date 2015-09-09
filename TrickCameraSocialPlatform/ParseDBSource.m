
#import "ParseDBSource.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "NSObject+SearchParse.m"
#import "NSObject+SaveParse.h"


@interface ParseDBSource()


@end


@implementation ParseDBSource

static ParseDBSource *_parseDBSingleTon = nil;

//初始化Singleton物件
+(instancetype)shared{
    if (_parseDBSingleTon == nil) {
        _parseDBSingleTon = [ParseDBSource new];
    }
    return _parseDBSingleTon;
}


//Parse photo全部資料
-(void)getParseData:(void(^)(NSMutableArray *pfObject))completion{
    //創造子線程(sub thread)
    dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
    dispatch_async(bg1, ^{
        _parseData = [[NSMutableArray alloc] init];
        //取Parse資料
        [NSObject getAllPhotoInfo:^(NSMutableArray *outPut) {
            _parseData = outPut;
            completion(_parseData);
        }];
    });
}

//取得指定照片的所有的留言
-(void)getFocusPhotoIDAllMessages:(NSString*)photoID{
    _focusAllMessages =  (NSMutableArray*)[NSObject getFocusPhotoIDToMessage:photoID];
}


//取得所有照片的各自的留言資料
-(void)getPhotoAllMessages:(void(^)(NSMutableDictionary *photoAndMessages))completion{
    //要搜尋的class-->Photos
    PFQuery *photoQuery = [PFQuery queryWithClassName:@"Photos"];
    //發文時間的排序
    [photoQuery orderByDescending:@"createdAt"];
    [photoQuery includeKey:@"userPID"];
    [photoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        
        //background thread-1
        dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
        dispatch_async(bg1, ^{
            NSMutableDictionary *tempDictionary = [[NSMutableDictionary alloc] init];
            for (PFObject *photoObj in objects) {
                NSArray *tempMessages = [NSObject getFocusPhotoIDToMessage:[photoObj objectId]];
                [tempDictionary setObject:tempMessages forKey:[photoObj objectId]];
            }
            _allPhotoAndMessages = tempDictionary;
            if (completion) {
                completion(_allPhotoAndMessages);
            }
        });
    }];
}


//取得關注人的所有相片information
-(void)getFocusPhotos:(void(^)(NSMutableArray *focusPhotos))theCompletion{
    dispatch_queue_t bg1 = dispatch_queue_create("bg1", nil);
    dispatch_async(bg1, ^{
        _allFocusPhotos = [[NSMutableArray alloc] init];
        //取Parse資料
        PFUser *currentUser = [PFUser currentUser];
        [NSObject getMyFollowingPostPhotos:currentUser myCompletion:^(NSMutableArray *completion){
            //全例變數賦值
            _allFocusPhotos = completion;
            if (theCompletion) {
                theCompletion(completion);
            }
        }];
    });
}






@end


