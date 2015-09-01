
#import <UIKit/UIKit.h>

@interface MessageTBViewCell : UITableViewCell
//Message圖片
@property (weak, nonatomic) IBOutlet UIImageView *messagePicture;
@property (weak, nonatomic) IBOutlet UIImageView *messagerPersonalPic;
@property (weak, nonatomic) IBOutlet UILabel *messagerNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *theMessageLbl;
@property (weak, nonatomic) IBOutlet UILabel *postDate;

@end
