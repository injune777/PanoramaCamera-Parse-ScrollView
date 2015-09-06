
#import "SliderMenu.h"
#import "SWRevealViewController.h"
#import "CameraVC.h"

//parse and facebook 登入
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "UIImageView+ClipAndspecific.h"
#import "NSObject+BlurImageView.h"
#import "UIImage+CustomUIImageEffect.h"



@interface SliderMenu ()

@property (weak, nonatomic) IBOutlet UIImageView *userPicture;

@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *homeLbl;
@property (weak, nonatomic) IBOutlet UILabel *discoverLbl;
@property (weak, nonatomic) IBOutlet UILabel *footLbl;
@property (weak, nonatomic) IBOutlet UILabel *cameraLbl;
@property (weak, nonatomic) IBOutlet UILabel *setUpLbl;

@property(nonatomic, strong) UIImage *thumbnailImage;

@end

@implementation SliderMenu

- (void)viewDidLoad {
    [super viewDidLoad];

    
    
    
    //消去TableView最後沒用到的欄位的分隔線
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //get current user
    PFUser *currentUser = [PFUser currentUser];
    //get user name
    _userName.text = currentUser[@"displayName"];
    
    //圓形效果
    _userPicture = [UIImageView imageViewWithClipCircle:_userPicture];
    
    //頭像添加邊框
    CALayer * layer = [_userPicture layer];
    layer.borderColor = [[UIColor whiteColor] CGColor];
    layer.borderWidth = 4.0f;
    
    //user head picture
    PFImageView *pfImageview = [[PFImageView alloc] init];
    PFFile *thumbnail = currentUser[@"headPhoto"];
    NSData *imageData = [thumbnail getData];
    _thumbnailImage = [UIImage imageWithData:imageData];
    pfImageview.image = _thumbnailImage;
    [pfImageview setFile:currentUser[@"headPhoto"]];
    _userPicture.image = pfImageview.image;
    [pfImageview loadInBackground];
   
    //縮圖
    _userPicture.image = [UIImage imageCompressWithSimple:pfImageview.image scaledToSizeWidth:200.0f scaledToSizeHeight:200.0f];
    
    //自適化TableViewCell高度
    self.tableView.estimatedRowHeight = 44.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    

    
    
//    模糊效果
//    UIImageView *backImageView = [NSObject getBlurImageViewWithImage:backGroundImage withRect:self.tableView.frame];
    
    
//    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sky.jpg"]];

    
    [_userName setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]];
    [_homeLbl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [_discoverLbl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [_footLbl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [_cameraLbl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
    [_setUpLbl setFont:[UIFont fontWithName:@"Helvetica-Bold" size:20]];
}


//使靜態Cell背景透明
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row != 0) {
        cell.backgroundColor = [UIColor clearColor];
    }
}

//跳出相機頁面-->Modal View
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 4) {
        CameraVC *cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"cameraVC"];
        [self presentViewController:cameraVC animated:YES completion:nil];
    }

}



@end
