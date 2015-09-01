
#import <UIKit/UIKit.h>

@interface MePersonalPageTBCell : UITableViewCell

//post文照片
@property (weak, nonatomic) IBOutlet UIImageView *peopleImageViewLeft;
//post文 頭照
@property (weak, nonatomic) IBOutlet UIImageView *postHeadImageView;
//post文 名字
@property (weak, nonatomic) IBOutlet UILabel *postName;
//post文 date
@property (weak, nonatomic) IBOutlet UILabel *postDate;
//喜歡按鈕-->按下去+1
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
//留言按鈕-->按下去跑去留言板
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
//like numbers
@property (weak, nonatomic) IBOutlet UILabel *likeNums;
//message numbers
@property (weak, nonatomic) IBOutlet UILabel *messageNums;


@end
