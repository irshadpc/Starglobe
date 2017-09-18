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
- (void)satellitesPressed;
- (void)infosPressed;
- (void)gyroPressed;
- (void)settingsPressed;
- (void)upgradePressed;
- (void)changedCameraValue:(float)time;
@end

@interface SettingsPopupViewController : UIViewController <UNUserNotificationCenterDelegate, FIRMessagingDelegate>
@property (nonatomic, strong) UISlider * cameraSlider;
@property (nonatomic, strong) UISwitch *cameraMode;
@property (nonatomic, strong) UIButton *nightMode;
@property (nonatomic, strong) UIButton *arMode;
@property (nonatomic, strong) UIButton *camera;
@property (nonatomic, strong) UIButton *music;
@property (nonatomic, strong) UIButton *satellites;
@property (nonatomic, strong) UIButton *upgrade;
@property (nonatomic, strong) UIButton *pushNotifications;
@property (nonatomic, strong) UIButton *rateApp;
@property (nonatomic, strong) UIButton *calendar;
@property (nonatomic, strong) UIButton *discoverMode;
@property (nonatomic, strong) UIImageView *cameraSmall;
@property (nonatomic, strong) UIImageView *cameraBig;
@property (nonatomic, retain) UIView *bannerView;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *headlineLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UIButton *upgradeButton;
@property (nonatomic, retain) UIButton *overlayButton;
@property (nonatomic, retain) UILabel *infoLabel;
@property (nonatomic, weak) id <SettingsPopupDelegate> delegate;
@end

