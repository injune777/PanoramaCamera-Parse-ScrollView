//
//  PLITViewerVC.h
//  Pano Lite
//
//  Created by Elias Khoury on 5/22/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DMD_LITE.h"

@interface PLITViewerVC : UIViewController
{
	BOOL statusBarWasHidden;
	PanoViewer *_panoViewer;
	NSTimer *_hideTimer;
}

@end
