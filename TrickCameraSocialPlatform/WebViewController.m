
#import "WebViewController.h"

//轉轉轉
#import <PQFCustomLoaders/PQFCustomLoaders.h>


@interface WebViewController ()<UIWebViewDelegate>
//WebView
@property (weak, nonatomic) IBOutlet UIWebView *theWebView;
//轉轉轉
@property (nonatomic, strong) PQFBouncingBalls *bouncingBalls;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //轉轉轉
    _bouncingBalls = [PQFBouncingBalls createModalLoader];
    _bouncingBalls.loaderColor = [UIColor orangeColor];
    _bouncingBalls.jumpAmount = 60;
    _bouncingBalls.zoomAmount = 50;
    _bouncingBalls.separation = 30;
    _bouncingBalls.diameter = 20;
    _bouncingBalls.label.text = @"請稍候...";
    _bouncingBalls.label.textColor = [UIColor orangeColor];
    _bouncingBalls.fontSize = 20;
    //開始轉轉
    [_bouncingBalls showLoader];
    
    //開啟網頁
    NSString *urlStr = [_webURL
                        stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //自动适应屏幕大小
    _theWebView.scalesPageToFit=YES;
    [_theWebView loadRequest:request];
}



- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //停止轉轉
    [_bouncingBalls setHidden:YES];
}





@end
