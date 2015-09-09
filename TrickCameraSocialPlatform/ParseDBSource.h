
#import <Foundation/Foundation.h>

@interface ParseDBSource : NSObject

//單例初始化
+(instancetype)shared;

//雲端取Parse
-(void)getParseData:(void(^)(NSMutableArray *pfObject))completion;
//取得指定照片的所有的留言
-(void)getFocusPhotoIDAllMessages:(NSString*)photoID;
///取得所有照片的各自的全部留言資料
-(void)getPhotoAllMessages:(void(^)(NSMutableDictionary *photoAndMessages))completion;
//取得關注人的所有相片information
-(void)getFocusPhotos:(void(^)(NSMutableArray *focusPhotos))theCompletion;


//全部照片的資料
@property(nonatomic, strong) NSMutableArray *parseData;
//指定照片的所有的留言
@property(nonatomic, strong) NSMutableArray *focusAllMessages;
//全部照片的各自的全部留言
@property(nonatomic, strong) NSMutableDictionary *allPhotoAndMessages;
//指定user的所有的照片
@property(nonatomic, strong) NSMutableArray *focusUserALlPicts;
//關注人的所有相片information
@property(nonatomic, strong) NSMutableArray  *allFocusPhotos;

@end
