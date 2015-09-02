//
//  PanoramaViewController.m
//  TrickCameraSocialPlatform
//
//  Created by Just on 2015/9/2.
//  Copyright (c) 2015年 OSX. All rights reserved.
//

#import "PanoramaViewController.h"
#import "CRMotionView.h"
#import <AVFoundation/AVFoundation.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface PanoramaViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *PanoView;

@end

@implementation PanoramaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    CRMotionView *motionView = [[CRMotionView alloc] initWithFrame:_PanoView.bounds];
    [motionView setImage:[UIImage imageNamed:@"3.jpg"]];
    [_PanoView addSubview:motionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
