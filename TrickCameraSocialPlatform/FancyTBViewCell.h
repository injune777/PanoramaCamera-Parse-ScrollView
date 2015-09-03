
#import <UIKit/UIKit.h>
#import <PFImageView.h>
#import "CRMotionView.h"

@interface FancyTBViewCell : UITableViewCell

//新奇圖片
//@property (weak, nonatomic) IBOutlet UIImageView *fancyImageView;



//@property (weak, nonatomic) IBOutlet CRMotionView *fancyImageView;

@property (weak, nonatomic) IBOutlet UIImageView *fancyImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *fancyScrollView;

//發佈者頭像
@property (weak, nonatomic) IBOutlet UIImageView *personalImageView;
//被按喜歡總數
@property (weak, nonatomic) IBOutlet UILabel *likeNumbers;
//被留言總數
@property (weak, nonatomic) IBOutlet UILabel *messageNumbers;
//最新留言
@property (weak, nonatomic) IBOutlet UILabel *theNewMessage;
//發佈距離km
@property (weak, nonatomic) IBOutlet UILabel *postState;
//發佈者名稱
@property (weak, nonatomic) IBOutlet UILabel *userName;
//發佈時間
@property (weak, nonatomic) IBOutlet UILabel *postDate;
//喜歡圖
@property (weak, nonatomic) IBOutlet UIImageView *likeImage;
//留言圖
@property (weak, nonatomic) IBOutlet UIImageView *messageImageView;
//分享圖
@property (weak, nonatomic) IBOutlet UIImageView *shareImage;


//字型調整用
//@property (weak, nonatomic) IBOutlet UILabel *focusLblText;
@property (weak, nonatomic) IBOutlet UILabel *likeLblText;
@property (weak, nonatomic) IBOutlet UILabel *messageLblText;
@property (weak, nonatomic) IBOutlet UILabel *shareLblText;

@end
