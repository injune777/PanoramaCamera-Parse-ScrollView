
#import <UIKit/UIKit.h>

@interface SearchTBCell : UITableViewCell

//頭像
@property (weak, nonatomic) IBOutlet UIImageView *searchPersonImageView;
//稱號
@property (weak, nonatomic) IBOutlet UILabel *personNameLbl;
//狀態-->是否加入好友
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;

@end
