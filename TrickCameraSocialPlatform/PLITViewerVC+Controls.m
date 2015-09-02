//
//  PLITViewerVC+Controls.m
//  Pano Lite
//
//  Created by Elias Khoury on 5/29/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

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

@implementation PLITViewerVC (Controls)

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
     //    PFUser *currentUser =  [NSObject getOneUserInfo:@"RbUnhp98yE"];
     //取得目前的user
     PFUser *currentUser = [PFUser currentUser];
     //取得image
     //    UIImage *myImage = [UIImage imageNamed:@"111.jpeg"];
     //轉為NSData並壓縮-->第2個參數為壓縮係數
     NSData *imageData = UIImageJPEGRepresentation(aimage, 0.3f);
     //把NSData轉為PFFile
     PFFile *photoFile = [PFFile fileWithData:imageData];
     
     //開始上傳圖片 to parse
     PFObject *userPhoto = [PFObject objectWithClassName:@"Photos"];
     userPhoto[@"userPID"] = currentUser;
     userPhoto[@"photo"] = photoFile;
     [userPhoto saveInBackground];

}
- (void)continueShooting:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		;
	}];
}

@end
