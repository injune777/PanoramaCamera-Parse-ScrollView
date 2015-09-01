//
//  PLITInfoView.m
//  Pano Lite
//
//  Created by Elias Khoury on 6/26/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#import "PLITInfoView.h"
#import <QuartzCore/QuartzCore.h>

@interface PLITInfoView()
- (void)changeFrameTo:(CGRect)frame;

@end

@implementation PLITInfoView

- (void)dealloc
{
	[_textLbl release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.alpha = 0.7f;
		_mainFrame = frame;
		_textLbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, frame.size.width-20, frame.size.height-20)];
		_textLbl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_textLbl.font = [UIFont boldSystemFontOfSize:(1*[UIFont systemFontSize]+8.f)];
		_textLbl.textAlignment = NSTextAlignmentCenter;
		_textLbl.lineBreakMode = NSLineBreakByWordWrapping;
		_textLbl.numberOfLines = 0;
		_textLbl.textColor = [UIColor whiteColor];
		_textLbl.backgroundColor = [UIColor clearColor];
		[self addSubview:_textLbl];
    }
    return self;
}

- (void)setSubFrame:(CGRect)subFrame
{
	_subFrame = subFrame;
}

- (void)setText:(NSString*)text
{
	[_textLbl setText:text];
}

- (void)switchToMainFrame
{
	[self changeFrameTo:_mainFrame];
}

- (void)switchToSubFrame
{
	[self changeFrameTo:_subFrame];
}

- (void)changeFrameTo:(CGRect)frame
{
	[UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		self.frame = frame;
	} completion:^(BOOL finished) {
		;
	}];
}

@end
