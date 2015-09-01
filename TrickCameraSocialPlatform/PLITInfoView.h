//
//  PLITInfoView.h
//  Pano Lite
//
//  Created by Elias Khoury on 6/26/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PLITInfoView : UIView
{
	UILabel *_textLbl;
	CGRect _mainFrame;
	CGRect _subFrame;
}

- (void)setText:(NSString*)text;
- (void)setSubFrame:(CGRect)subFrame;
- (void)switchToMainFrame;
- (void)switchToSubFrame;

@end
