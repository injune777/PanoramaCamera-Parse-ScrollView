//
//  PLITViewerVC.m
//  Pano Lite
//
//  Created by Elias Khoury on 5/22/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import "PLITViewerVC.h"
#import "PLITViewerVC+Controls.h"

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

@end
