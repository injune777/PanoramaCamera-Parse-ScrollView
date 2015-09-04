//
//  PLITViewerVC.m
//  Pano Lite
//
//  Created by Elias Khoury on 5/22/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import "PLITViewerVC.h"
#import "PLITViewerVC+Controls.h"
#import "PLITShootingVC.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import <FBSDKCoreKit/FBSDKGraphRequestConnection.h>
#import <FBSDKCoreKit/FBSDKGraphRequest.h>
#import "PFLogInViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>



#define TMP_DIR [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DMD_tmp"]
@interface PLITViewerVC ()
- (void)startViewer;
- (void)stopViewer;

- (void)setHideTimer:(NSTimeInterval)ti;
- (void)hideNavBar:(NSTimer*)theTimer;
- (void)showNavBar:(UIGestureRecognizer*)gestureRecognizer;
@end

@implementation PLITViewerVC

//- (id)init
//{
//    self = [super init];
//    if (self) {
//		self.wantsFullScreenLayout = YES;
//    }
//    return self;
//}

- (void)dealloc
{
	[super dealloc];
}

- (void)loadView
{
	CGRect frame = [[UIScreen mainScreen] applicationFrame];

	_panoViewer = [[[PanoViewer alloc] initWithFrame:CGRectMake(0, 0, frame.size.height, frame.size.width)] autorelease];

	UITapGestureRecognizer *singleFingerTap = [[[UITapGestureRecognizer alloc]
											   initWithTarget:self action:@selector(showNavBar:)] autorelease];
	[singleFingerTap requireGestureRecognizerToFail:_panoViewer.doubleTapGR];
	[_panoViewer addGestureRecognizer:singleFingerTap];
	
	self.view = _panoViewer;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self->statusBarWasHidden = [UIApplication sharedApplication].statusBarHidden;
    [UIApplication sharedApplication].statusBarHidden = YES;
	[self setupNavigationController:self.navigationController];
	[self startViewer];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self setHideTimer:1.5];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self stopViewer];
	if (!self->statusBarWasHidden)
		[UIApplication sharedApplication].statusBarHidden = NO;
	[super viewWillDisappear:animated];
}

- (void)setHideTimer:(NSTimeInterval)ti
{
	[_hideTimer invalidate];
	_hideTimer = [NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(hideNavBar:) userInfo:nil repeats:NO];
}

- (void)hideNavBar:(NSTimer*)theTimer
{
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	_hideTimer = nil;
}

- (void)showNavBar:(UIGestureRecognizer*)gestureRecognizer
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
	[self setHideTimer:5.0];
	return;
}


#pragma mark -
#pragma mark DMD Viewer

- (void)startViewer
{
	[_panoViewer performSelector:@selector(start) onThread:[Monitor instance].engineMgr.thread withObject:nil waitUntilDone:NO];
}

- (void)stopViewer
{
	[_panoViewer performSelector:@selector(stop) onThread:[Monitor instance].engineMgr.thread withObject:nil waitUntilDone:NO];
}

- (void)setupNavigationController:(UINavigationController*)nav
{
    nav.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    nav.toolbarHidden = YES;
    nav.toolbar.barStyle = UIBarStyleBlack;
    nav.toolbar.translucent = YES;
    nav.navigationBar.hidden = NO;
    nav.navigationBar.barStyle = UIBarStyleBlack;
    nav.navigationBar.translucent = YES;
    
    UIBarButtonItem *back = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(continueShooting:)] autorelease];
    nav.topViewController.navigationItem.rightBarButtonItem = back;
    
    UIBarButtonItem *share = [[[UIBarButtonItem alloc]initWithTitle:@"Share" style:UIBarButtonItemStylePlain target:self action:@selector(sharePhoto:)] autorelease];
    nav.topViewController.navigationItem.leftBarButtonItem = share;
    UIBarButtonItem *goback = [[[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goBackToMain:)] autorelease];
    nav.topViewController.navigationItem.backBarButtonItem  = goback;
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
}


-(void)goBackToMain:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)sharePhoto:(id)sender
{   NSString *ename = [TMP_DIR stringByAppendingPathComponent:@"equi.jpeg"];
    [[Monitor instance] genEquiAt:ename withHeight:800 andWidth:0 andMaxWidth:0];
    UIImage *aimage = [UIImage imageWithData:[NSData dataWithContentsOfFile:ename]];
    //user物件
    //取得目前的user
    PFUser *currentUser = [PFUser currentUser];
    //取得image
    //轉為NSData並壓縮-->第2個參數為壓縮係數
    NSData *imageData = UIImageJPEGRepresentation(aimage, 0.3f);
    //把NSData轉為PFFile
    PFFile *photoFile = [PFFile fileWithData:imageData];
    //經緯度物件
    //     PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:40.0 longitude:-30.0];
    
    //開始上傳圖片 to parse
    PFObject *userPhoto = [PFObject objectWithClassName:@"Photos"];
    userPhoto[@"userPID"] = currentUser;
    userPhoto[@"photo"] = photoFile;
    //     userPhoto[@"postLocation"] = point;
    [userPhoto saveInBackground];
    
}
- (void)continueShooting:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

@end
