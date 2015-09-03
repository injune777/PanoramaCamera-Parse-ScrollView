
#import "SetUpTBVC.h"

#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <ParseUI/ParseUI.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

#import "SWRevealViewController.h"

@interface SetUpTBVC ()<PFLogInViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *savePictureInLocal;
@property (weak, nonatomic) IBOutlet UISwitch *logOut;
//parse and facebook 登入
@property(nonatomic, strong) PFLogInViewController *controller;
//Slide Bar
@property(nonatomic, strong) UIBarButtonItem *slideBarBtn;

@end

@implementation SetUpTBVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [_savePictureInLocal setOn:YES];
    [_logOut setOn:NO];
    
    //Slid Bar
    _slideBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slideBar.png"]
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:nil];
    [_slideBarBtn setTintColor:[UIColor orangeColor]];
    self.navigationItem.leftBarButtonItem = _slideBarBtn;
    
    //Slide Bar Menu
    SWRevealViewController *revealViewController = [self revealViewController];
    if (revealViewController) {
        //調整寬度
        revealViewController.rearViewRevealWidth = 220;
        [_slideBarBtn setTarget:self.revealViewController];
        [_slideBarBtn setAction:@selector(revealToggle:)];
        [self.view addGestureRecognizer:revealViewController.panGestureRecognizer];
    }
}


//是否可以儲存相片在本機
- (IBAction)savePictureInLocal:(id)sender {
}

//LogOut Button
- (IBAction)logOut:(id)sender {
    if ([_logOut isOn]) {
        [PFUser logOut];
        _controller = [[PFLogInViewController alloc] init];
        _controller.delegate = self;
        _controller.fields = PFLogInFieldsFacebook;
        [self presentViewController:_controller animated:YES completion:nil];
    }
}

//Protocol-->登入完成時用
//已經登錄的@protocol
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user{
    //取消登入畫面
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
