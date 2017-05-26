//
//  SettingsPopupViewController.h
//  Starglobe
//
//  Created by Alex on 01.03.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <STPopup/STPopup.h>

@import Firebase;
@class SettingsPopupViewController;
@protocol SettingsPopupDelegate <NSObject>
@optional
- (void)nightModePressed;
- (void)cameraPressed;
- (void)arModePressed;
- (void)musicPressed;
- (void)infosPressed;
- (void)gyroPressed;
- (void)settingsPressed;
- (void)upgradePressed;
-(void)fadeSliderChangedPressed;
-(void)transSliderChangedPressed;
@end

@interface SettingsPopupViewController : UIViewController <UNUserNotificationCenterDelegate, FIRMessagingDelegate, KPPoptartDelegate>
@property (nonatomic, strong) UISlider * cameraSlider;
@property (nonatomic, strong) UISlider * timeSlider;
@property (nonatomic, strong) UISwitch *cameraMode;
@property (nonatomic, strong) UIButton *nightMode;
@property (nonatomic, strong) UIButton *arMode;
@property (nonatomic, strong) UIButton *camera;
@property (nonatomic, strong) UIButton *music;
@property (nonatomic, strong) UIButton *satellites;
@property (nonatomic, strong) UIButton *upgrade;
@property (nonatomic, strong) UIButton *settings;
@property (nonatomic, strong) UIButton *rateApp;
@property (nonatomic, strong) UIButton *calendar;
@property (nonatomic, strong) UIButton *gyro;
@property (nonatomic, strong) UIImageView *cameraSmall;
@property (nonatomic, strong) UIImageView *cameraBig;
@property (nonatomic, strong) UIImageView *timeSmall;
@property (nonatomic, strong) UIImageView *timeBig;
@property (nonatomic, weak) id <SettingsPopupDelegate> delegate;
@end

