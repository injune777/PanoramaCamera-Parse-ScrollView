//
//  DMD_LITE.h
//  ShootingManager
//
//  Created by Elias Khoury on 4/5/13.
//  Copyright (c) 2013 Dermandar (Offshore) S.A.L. All rights reserved.
//

#ifndef DMD_LITE_h
#define DMD_LITE_h




enum DMDCompassEvents {
	kDMDCompassReady=0,
	kDMDCompassInitializing,
	kDMDCompassNeedsCalibration,
	kDMDCompassInterference
};




@protocol MonitorDelegate <NSObject>

@optional

- (void)preparingToShoot;
- (void)canceledPreparingToShoot;
- (void)takingPhoto;
- (void)photoTaken;
- (void)stitchingCompleted:(NSDictionary*)dict;
- (void)shootingCompleted;

- (void)deviceVerticalityChanged:(NSNumber*)isVertical;
- (void)compassEvent:(NSDictionary*)info;

@end




@interface EngineManager : NSObject

@property (nonatomic, readonly) NSThread *thread;

@end




@interface Monitor : NSObject
{
	id<MonitorDelegate> delegate;
}

@property (nonatomic, assign) id<MonitorDelegate> delegate;
@property (nonatomic, readonly) EngineManager *engineMgr;
@property (nonatomic, assign) BOOL isShooting;

+ (Monitor*)instance;

- (void)restart;
- (void)startShooting;
- (void)stopShooting;
- (void)finishShooting;
- (void)stopSensors;

- (void)genEquiAt:(NSString*)fileName withHeight:(NSUInteger)height andWidth:(NSUInteger)width andMaxWidth:(NSUInteger)maxWidth;

@end




@interface PanoViewer : UIView

@property (nonatomic, readonly) UITapGestureRecognizer *doubleTapGR;

- (void)start;
- (void)stop;

@end




@interface ShooterView : UIView

@property (nonatomic, readonly, getter = get_flashControls) NSArray *flashControls;
@property (nonatomic, readonly, getter = get_exposureControls) NSArray *exposureControls;

- (void)setFlashOn:(id)sender;
- (void)setFlashOff:(id)sender;
- (void)setFlashAuto:(id)sender;
- (void)setExposureLocked:(id)sender;
- (void)setExposureAuto:(id)sender;
- (void)setExposureLockedOnFirst:(id)sender;

@end




#endif
