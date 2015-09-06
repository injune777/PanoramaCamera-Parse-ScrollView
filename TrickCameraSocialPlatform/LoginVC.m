
#import "LoginVC.h"
#import <QuartzCore/QuartzCore.h>

@interface LoginVC ()

@property (nonatomic, strong) UIImageView *fieldsBackground;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"20.jpeg"]]];
    [self.logInView setLogo:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Logo.png"]]];
    
    
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
}



@end
