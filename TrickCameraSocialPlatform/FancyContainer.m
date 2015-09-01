
#import "FancyContainer.h"
#import "PicWallCollectionVC.h"
#import "SWRevealViewController.h"

#import "FancyTBViewCon.h"
#import "PicWallCollectionVC.h"


@interface FancyContainer ()


//切換開關
@property (assign, nonatomic) BOOL fancySwitch;
//NavigationBar rightBarButton
@property(nonatomic, strong) UIBarButtonItem *rightBarbutton;
@property(nonatomic, strong) UIBarButtonItem *slideBarBtn;

//要加入的controller
@property(nonatomic, strong) FancyTBViewCon *fancyCon;
@property(nonatomic, strong) PicWallCollectionVC *picWallCon;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation FancyContainer

- (void)viewDidLoad {
    [super viewDidLoad];
    _fancySwitch = YES;
    
    //NavigationBar rightBarButton
    _rightBarbutton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"pictureWall.png"]
                                                       style:UIBarButtonItemStyleDone
                                                      target:self
                                                      action:@selector(switchFancyAndPictureWall)];
    _slideBarBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"slideBar.png"]
                                                    style:UIBarButtonItemStyleDone
                                                   target:self
                                                   action:nil];
    
    [_rightBarbutton setTintColor:[UIColor orangeColor]];
    [_slideBarBtn setTintColor:[UIColor orangeColor]];
    self.navigationItem.rightBarButtonItem = _rightBarbutton;
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
    
    //FancyTBView controller
    _fancyCon = [self.storyboard instantiateViewControllerWithIdentifier:@"fancyStoryboard"];
    [self addChildViewController:_fancyCon];
    //顯示出來
    [_containerView addSubview:_fancyCon.view];
    //PicWall controller
    _picWallCon = [self.storyboard instantiateViewControllerWithIdentifier:@"picWall"];
    [self addChildViewController:_picWallCon];
   
}


//切換選單
- (IBAction)segmentedBtn:(id)sender {
}



//NavigationRightBarButton Evne Handler
-(void)switchFancyAndPictureWall{
    if (_fancySwitch == YES) {
        [_containerView addSubview:_picWallCon.view];
        _rightBarbutton.image = [UIImage imageNamed:@"lists.png"];
        _fancySwitch = NO;
    }else{
        [_containerView addSubview:_fancyCon.view];
        _rightBarbutton.image = [UIImage imageNamed:@"pictureWall.png"];
        _fancySwitch = YES;
    }
}










@end
