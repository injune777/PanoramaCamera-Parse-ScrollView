//
//  UINavigationControllerLandscape.m
//  Pano Lite
//
//  Created by Elias Khoury on 11/28/12.
//  Copyright (c) 2012 Dermandar. All rights reserved.
//

#import "UINavigationControllerLandscape.h"

@interface UINavigationControllerLandscape ()

@end

@implementation UINavigationControllerLandscape

- (BOOL)shouldAutorotate
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	return UIInterfaceOrientationLandscapeRight;
}

@end
