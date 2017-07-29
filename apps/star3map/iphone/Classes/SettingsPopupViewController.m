//
//  SettingsPopupViewController.m
//  Starglobe
//
//  Created by Alex on 01.03.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import "SettingsPopupViewController.h"
#import "MainViewController.h"
#import "star3mapAppDelegate.h"

@implementation SettingsPopupViewController

- (instancetype)init{
    if (self = [super init]) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGSize screenSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height);
        self.contentSizeInPopup = CGSizeMake(screenSize.width, 200);
        self.popupController.navigationBarHidden = YES;
    }
    return self;
}

- (void)dismiss{

}
                                                  
- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize screenSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height);
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    
    _camera = [UIButton buttonWithType:UIButtonTypeCustom];
    [_camera setFrame:CGRectMake((screenSize.width-44)/2, 15, 44, 44)];
    [_camera setImage:[UIImage imageNamed:@"controls_snapshot"] forState:UIControlStateNormal];
    [_camera addTarget:self action:@selector(cameraPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_camera];
    
    _arMode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_arMode setFrame:CGRectMake(_camera.frame.origin.x - 59, 15, 44, 44)];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ARModeOn"]){
        [_arMode setImage:[UIImage imageNamed:@"controls_ar_camera_on"] forState:UIControlStateNormal];
    } else {
        [_arMode setImage:[UIImage imageNamed:@"controls_ar_camera"] forState:UIControlStateNormal];
    }
    [_arMode addTarget:self action:@selector(arModePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_arMode];
    
    _nightMode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nightMode setFrame:CGRectMake(_arMode.frame.origin.x - 59, 15, 44, 44)];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"NightModeOn"]){
        [_nightMode setImage:[UIImage imageNamed:@"controls_night_mode_on_red"] forState:UIControlStateNormal];
    } else {
        [_nightMode setImage:[UIImage imageNamed:@"controls_night_mode"] forState:UIControlStateNormal];
    }
    [_nightMode addTarget:self action:@selector(nightModePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nightMode];
    
    _music = [UIButton buttonWithType:UIButtonTypeCustom];
    [_music setFrame:CGRectMake(_camera.frame.origin.x + 59, 15, 44, 44)];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"MusicOn"]){
        [_music setImage:[UIImage imageNamed:@"controls_music_on"] forState:UIControlStateNormal];
    } else {
        [_music setImage:[UIImage imageNamed:@"controls_music"] forState:UIControlStateNormal];
    }
    [_music addTarget:self action:@selector(musicPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_music];
    
    _satellites = [UIButton buttonWithType:UIButtonTypeCustom];
    [_satellites setFrame:CGRectMake(_music.frame.origin.x + 59, 15, 44, 44)];
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"SatellitesOn"]){
        [_satellites setImage:[UIImage imageNamed:@"controls_tracks_on"] forState:UIControlStateNormal];
    } else {
        [_satellites setImage:[UIImage imageNamed:@"controls_tracks"] forState:UIControlStateNormal];
    }
    [_satellites addTarget:self action:@selector(satellitesPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_satellites];
    
    
    _cameraSmall = [[UIImageView alloc]initWithFrame:CGRectMake(_nightMode.frame.origin.x, _camera.frame.origin.y + _camera.frame.size.height + 30, 20, 20)];
    _cameraSmall.image = [UIImage imageNamed:@"camera"];
    [self.view addSubview:_cameraSmall];
    
    _cameraBig = [[UIImageView alloc]initWithFrame:CGRectMake(_satellites.frame.origin.x + _satellites.frame.size.width - 30, _cameraSmall.frame.origin.y - 5, 30, 30)];
    _cameraBig.image = [UIImage imageNamed:@"camera"];
    [self.view addSubview:_cameraBig];
    
    _cameraSlider = [[UISlider alloc]initWithFrame:CGRectMake(_cameraSmall.frame.origin.x + _cameraSmall.frame.size.width + 15, _cameraSmall.frame.origin.y - 5, _cameraBig.frame.origin.x - _cameraSmall.frame.origin.x - _cameraSmall.frame.size.width - 30, 30)];
    [_cameraSlider setThumbTintColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0]];
    [_cameraSlider setMinimumTrackTintColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0]];
    [_cameraSlider setMaximumTrackTintColor:[UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0]];
    [_cameraSlider setMinimumValue: 0.0f];
    [_cameraSlider setMaximumValue: 1.0f];
    _cameraSlider.value = [[NSUserDefaults standardUserDefaults]floatForKey:@"RealCameraValue"];
    [_cameraSlider setContinuous:YES];
    [_cameraSlider addTarget:self action:@selector(changedCameraSlider:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_cameraSlider];
    
    
    _pushNotifications = [UIButton buttonWithType:UIButtonTypeCustom];
    [_pushNotifications setFrame:CGRectMake(_camera.frame.origin.x - 35, _cameraSlider.frame.origin.y + _cameraSlider.frame.size.height + 20, 50, 50)];
    [_pushNotifications setImage:[UIImage imageNamed:@"controls_date"] forState:UIControlStateNormal];
    [_pushNotifications addTarget:self action:@selector(enablePush) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_pushNotifications];
    
    _discoverMode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_discoverMode setFrame:CGRectMake(_camera.frame.origin.x + 35, _cameraSlider.frame.origin.y + _cameraSlider.frame.size.height + 20, 50, 50)];
    [_discoverMode setImage:[UIImage imageNamed:@"controls_gyro"] forState:UIControlStateNormal];
    [_discoverMode addTarget:self action:@selector(showDiscoverMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_discoverMode];
    
    
    _upgrade = [UIButton buttonWithType:UIButtonTypeCustom];
    [_upgrade setFrame:CGRectMake(_pushNotifications.frame.origin.x - 70, _cameraSlider.frame.origin.y + _cameraSlider.frame.size.height + 20, 50, 50)];
    [_upgrade setImage:[UIImage imageNamed:@"controls_downloads"] forState:UIControlStateNormal];
    [_upgrade setImage:[UIImage imageNamed:@"controls_downloads_new"] forState:UIControlStateDisabled];
    [_upgrade addTarget:self action:@selector(upgradePressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_upgrade];
    
    
    _rateApp = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rateApp setFrame:CGRectMake(_discoverMode.frame.origin.x + 70, _cameraSlider.frame.origin.y + _cameraSlider.frame.size.height + 20, 50, 50)];
    [_rateApp setImage:[UIImage imageNamed:@"controls_rateapp"] forState:UIControlStateNormal];
    [_rateApp setImage:[UIImage imageNamed:@"controls_rateapp_pink"] forState:UIControlStateDisabled];
    [_rateApp addTarget:self action:@selector(showAd) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rateApp];
    
#ifdef STARGLOBE_FREE
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-1395183894711219/8530266883"];
#endif
    
#ifdef STARGLOBE_PRO
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-1395183894711219/8583691902"];
#endif
    [self.interstitial loadRequest:[GADRequest request]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)changedCameraSlider:(UISlider*)sender{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ARModeOn"]){
        [[NSUserDefaults standardUserDefaults] setFloat: sender.value forKey: @"RealCameraValue"];
        [[NSUserDefaults standardUserDefaults] setFloat: sender.value forKey: @"CameraValue"];
    } else {
        [[NSUserDefaults standardUserDefaults] setFloat: sender.value forKey: @"RealCameraValue"];
    }

    if([self.delegate respondsToSelector:@selector(changedCameraValue:)]) {
        [self.delegate changedCameraValue:sender.value];
    }
}

- (void)nightModePressed{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"NightModeOn"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NightModeOn"];
        [_nightMode setImage:[UIImage imageNamed:@"controls_night_mode"] forState:UIControlStateNormal];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NightModeOn"];
        [_nightMode setImage:[UIImage imageNamed:@"controls_night_mode_on_red"] forState:UIControlStateNormal];
    }
    
    if([self.delegate respondsToSelector:@selector(nightModePressed)]) {
        [self.delegate nightModePressed];
    }
}

- (void)arModePressed{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ARModeOn"]){
        [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey: @"CameraValue"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ARModeOn"];
        [_arMode setImage:[UIImage imageNamed:@"controls_ar_camera"] forState:UIControlStateNormal];
    } else {
        [[NSUserDefaults standardUserDefaults] setFloat:[[NSUserDefaults standardUserDefaults]floatForKey:@"RealCameraValue"] forKey: @"CameraValue"];

        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ARModeOn"];
        [_arMode setImage:[UIImage imageNamed:@"controls_ar_camera_on"] forState:UIControlStateNormal];
    }
}

- (void)cameraPressed{
    UINavigationController *navigationController = (UINavigationController*)self.presentingViewController;
    MainViewController *presentingViewController = (MainViewController*)navigationController.topViewController;
    presentingViewController.takeScreenshot = YES;
    
    [self.popupController dismiss];
    
    if([self.delegate respondsToSelector:@selector(cameraPressed)]) {
        [self.delegate cameraPressed];
    }
}

- (void)musicPressed{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"MusicOn"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MusicOn"];
        [_music setImage:[UIImage imageNamed:@"controls_music"] forState:UIControlStateNormal];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MusicOn"];
        [_music setImage:[UIImage imageNamed:@"controls_music_on"] forState:UIControlStateNormal];
    }
    
    if([self.delegate respondsToSelector:@selector(musicPressed)]) {
        [self.delegate musicPressed];
    }
}

- (void)satellitesPressed{
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"SatellitesOn"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SatellitesOn"];
        [_satellites setImage:[UIImage imageNamed:@"controls_tracks"] forState:UIControlStateNormal];
    } else {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SatellitesOn"];
        [_satellites setImage:[UIImage imageNamed:@"controls_tracks_on"] forState:UIControlStateNormal];
    }
    if([self.delegate respondsToSelector:@selector(satellitesPressed)]) {
        [self.delegate satellitesPressed];
    }
}

- (void)infosPressed{
    if([self.delegate respondsToSelector:@selector(infosPressed)]) {
        [self.delegate infosPressed];
    }
}

- (void)gyroPressed{
    if([self.delegate respondsToSelector:@selector(gyroPressed)]) {
        [self.delegate gyroPressed];
    }
}

- (void)settingsPressed{
    if([self.delegate respondsToSelector:@selector(settingsPressed)]) {
        [self.delegate settingsPressed];
    }
}

- (void)upgradePressed{
    UINavigationController *navigationController = (UINavigationController*)self.presentingViewController;
    MainViewController *presentingViewController = (MainViewController*)navigationController.topViewController;
    presentingViewController.showUpgrade = YES;
    
    [self.popupController dismiss];
    
    if([self.delegate respondsToSelector:@selector(upgradePressed)]) {
        [self.delegate upgradePressed];
    }
}

- (void)showAd{
    if (self.interstitial.isReady) {
        [self.interstitial presentFromRootViewController:self];
    } else {
        [self upgradePressed];
    }
}

- (void)showDiscoverMode{
    UINavigationController *navigationController = (UINavigationController*)self.presentingViewController;
    MainViewController *presentingViewController = (MainViewController*)navigationController.topViewController;
    presentingViewController.showDiscover = YES;
    
    [self.popupController dismiss];
}

- (void)enablePush{ 
    [UIAlertController showAlertInViewController:self withTitle:NSLocalizedString(@"Stargaze Notifications", nil) message:NSLocalizedString(@"Get notified when the night sky is perfectly clear for stargazing", nil) cancelButtonTitle:NSLocalizedString(@"No, thanks.", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"Yes, please!", nil)] tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                            if (buttonIndex == controller.cancelButtonIndex) {
                                                NSLog(@"Cancel Tapped");
                                            } else if (buttonIndex == controller.destructiveButtonIndex) {
                                                NSLog(@"Delete Tapped");
                                            } else if (buttonIndex >= controller.firstOtherButtonIndex) {
                                                if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_9_x_Max) {
                                                    UIUserNotificationType allNotificationTypes =
                                                    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
                                                    UIUserNotificationSettings *settings =
                                                    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
                                                    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
                                                } else {
#if defined(__IPHONE_10_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_10_0
                                                    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
                                                    UNAuthorizationOptions authOptions =
                                                    UNAuthorizationOptionAlert
                                                    | UNAuthorizationOptionSound
                                                    | UNAuthorizationOptionBadge;
                                                    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:authOptions completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                                    }];
                                                    [FIRMessaging messaging].remoteMessageDelegate = self;
#endif
                                                }
                                                [[UIApplication sharedApplication] registerForRemoteNotifications];
                                            }
                                        }];
    }

- (void)applicationReceivedRemoteMessage:(nonnull FIRMessagingRemoteMessage *)remoteMessage{
    
}

@end
