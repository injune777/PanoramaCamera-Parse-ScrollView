//
//  PLITShootingVC.h
//  Pano Lite
//
//  Created by Elias Khoury on 5/21/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMD_LITE.h"

@class PLITInfoView;

@interface PLITShootingVC : UIViewController <MonitorDelegate, UIGestureRecognizerDelegate>
{
	ShooterView *_shooterView;
	PLITInfoView *_infoView;
	UIActivityIndicatorView *_activityInd;
	NSInteger _numShots;
	UITapGestureRecognizer *_tapRecognizer;
	NSTimer *_vibrationTimer;
}

@end
