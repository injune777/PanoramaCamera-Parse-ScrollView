
#import <UIKit/UIKit.h>
#import "ParallaxHeaderView.h"
#import <Parse/Parse.h>

#define MESSAGE_OK @"MESSAGE_OK"

@interface MessageVCon : UIViewController

//Headview Picture
@property (nonatomic, strong) ParallaxHeaderView *headerView;
@property (nonatomic, strong) PFObject *selectPhotoObj;

//customer Tableview
//自設定TableView in  IBOutlet-->在ViewController內自建TableView一定要用程式碼先建立這一段IBOutlet
//然後再從storyboard上面的TableView拉過來聯結，才會生效
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
