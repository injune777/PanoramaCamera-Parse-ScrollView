//
//  PLITViewerVC+Controls.m
//  Pano Lite
//
//  Created by Elias Khoury on 5/29/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import "PLITViewerVC+Controls.h"

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
}

- (void)continueShooting:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:^{
		;
	}];
}

@end
