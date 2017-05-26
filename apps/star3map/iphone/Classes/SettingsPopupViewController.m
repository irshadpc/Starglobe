//
//  SettingsPopupViewController.m
//  Starglobe
//
//  Created by Alex on 01.03.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import "SettingsPopupViewController.h"
#import "MainViewController.h"


@interface SettingsPopupViewController ()

@end


@implementation SettingsPopupViewController

- (instancetype)init{
    if (self = [super init]) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        CGSize screenSize = CGSizeMake(screenBounds.size.width, screenBounds.size.height);
        self.contentSizeInPopup = CGSizeMake(screenSize.width, 250);
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
    
  /*  BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!hasCamera) {
        [cameraMode setEnabled:NO];
    }
    
    [cameraMode setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"ARModeOn"]];*/
    
    _camera = [UIButton buttonWithType:UIButtonTypeCustom];
    [_camera setFrame:CGRectMake((screenSize.width-44)/2, 15, 44, 44)];
    [_camera setImage:[UIImage imageNamed:@"controls_snapshot"] forState:UIControlStateNormal];
    [_camera addTarget:self action:@selector(cameraPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_camera];
    
    _arMode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_arMode setFrame:CGRectMake(_camera.frame.origin.x - 59, 15, 44, 44)];
    [_arMode setImage:[UIImage imageNamed:@"controls_ar_camera_on"] forState:UIControlStateNormal];
    [_arMode setImage:[UIImage imageNamed:@"controls_ar_camera"] forState:UIControlStateDisabled];
    [_arMode addTarget:self action:@selector(arModePressed) forControlEvents:UIControlEventTouchUpInside];
    [_arMode setEnabled:[[NSUserDefaults standardUserDefaults]boolForKey:@"ARModeOn"]];
    [self.view addSubview:_arMode];
    
    _nightMode = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nightMode setFrame:CGRectMake(_arMode.frame.origin.x - 59, 15, 44, 44)];
    [_nightMode setImage:[UIImage imageNamed:@"controls_night_mode_on_red"] forState:UIControlStateNormal];
    [_nightMode setImage:[UIImage imageNamed:@"controls_night_mode"] forState:UIControlStateDisabled];
    [_nightMode addTarget:self action:@selector(nightModePressed) forControlEvents:UIControlEventTouchUpInside];
    [_nightMode setEnabled:[[NSUserDefaults standardUserDefaults]boolForKey:@"NightModeOn"]];
    [self.view addSubview:_nightMode];
    
    _music = [UIButton buttonWithType:UIButtonTypeCustom];
    [_music setFrame:CGRectMake(_camera.frame.origin.x + 59, 15, 44, 44)];
    [_music setImage:[UIImage imageNamed:@"controls_music_on"] forState:UIControlStateNormal];
    [_music setImage:[UIImage imageNamed:@"controls_music"] forState:UIControlStateDisabled];
    [_music addTarget:self action:@selector(musicPressed) forControlEvents:UIControlEventTouchUpInside];
    [_music setEnabled:[[NSUserDefaults standardUserDefaults]boolForKey:@"MusicOn"]];
    [self.view addSubview:_music];
    
    _satellites = [UIButton buttonWithType:UIButtonTypeCustom];
    [_satellites setFrame:CGRectMake(_music.frame.origin.x + 59, 15, 44, 44)];
    [_satellites setImage:[UIImage imageNamed:@"controls_tracks"] forState:UIControlStateNormal];
    [_satellites setImage:[UIImage imageNamed:@"controls_tracks_on"] forState:UIControlStateDisabled];
    [_satellites addTarget:self action:@selector(infosPressed) forControlEvents:UIControlEventTouchUpInside];
    [_satellites setEnabled:[[NSUserDefaults standardUserDefaults]boolForKey:@"SatellitesOn"]];
    [self.view addSubview:_satellites];
    
    
    _cameraSmall = [[UIImageView alloc]initWithFrame:CGRectMake(_nightMode.frame.origin.x, _camera.frame.origin.y + _camera.frame.size.height + 20, 20, 20)];
    _cameraSmall.image = [UIImage imageNamed:@"camera"];
    [self.view addSubview:_cameraSmall];
    
    _cameraBig = [[UIImageView alloc]initWithFrame:CGRectMake(_satellites.frame.origin.x + _satellites.frame.size.width - 30, _cameraSmall.frame.origin.y - 3, 30, 30)];
    _cameraBig.image = [UIImage imageNamed:@"camera"];
    [self.view addSubview:_cameraBig];
    
    _cameraSlider = [[UISlider alloc]initWithFrame:CGRectMake(_cameraSmall.frame.origin.x + _cameraSmall.frame.size.width + 15, _cameraSmall.frame.origin.y - 5, _cameraBig.frame.origin.x - _cameraSmall.frame.origin.x - _cameraSmall.frame.size.width - 30, 30)];
    [_cameraSlider setThumbTintColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0]];
    [_cameraSlider setMinimumTrackTintColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0]];
    [_cameraSlider setMaximumTrackTintColor:[UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0]];
    [_cameraSlider setMinimumValue: 0.0f];
    [_cameraSlider setMaximumValue: 1.0f];
    _cameraSlider.value = [[NSUserDefaults standardUserDefaults]floatForKey:@"CameraValue"];
    [_cameraSlider setContinuous:YES];
    [self.view addSubview:_cameraSlider];
    
    
    
    _timeSmall = [[UIImageView alloc]initWithFrame:CGRectMake(_nightMode.frame.origin.x, _cameraBig.frame.origin.y + _cameraBig.frame.size.height + 20, 20, 20)];
    _timeSmall.image = [UIImage imageNamed:@"time"];
    [self.view addSubview:_timeSmall];
    
    _timeBig = [[UIImageView alloc]initWithFrame:CGRectMake(_satellites.frame.origin.x + _satellites.frame.size.width - 30, _cameraBig.frame.origin.y + _cameraBig.frame.size.height + 20, 30, 30)];
    _timeBig.image = [UIImage imageNamed:@"time"];
    [self.view addSubview:_timeBig];
    
    _timeSlider = [[UISlider alloc]initWithFrame:CGRectMake(_timeSmall.frame.origin.x + _timeSmall.frame.size.width + 10, _timeSmall.frame.origin.y - 5, _timeBig.frame.origin.x - _timeSmall.frame.origin.x - _timeSmall.frame.size.width - 30, 30)];
    [_timeSlider setThumbTintColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0]];
    [_timeSlider setMinimumTrackTintColor:[UIColor colorWithRed:155.0/255.0 green:155.0/255.0 blue:155.0/255.0 alpha:1.0]];
    [_timeSlider setMaximumTrackTintColor:[UIColor colorWithRed:64.0/255.0 green:64.0/255.0 blue:64.0/255.0 alpha:1.0]];
    [_timeSlider setMinimumValue: 1.0f];
    [_timeSlider setMaximumValue: 15.0f];
    _timeSlider.value = [[NSUserDefaults standardUserDefaults]floatForKey:@"FadeTime"];
    [_timeSlider setContinuous:YES];
    [self.view addSubview:_timeSlider];

    
    
    
    _settings = [UIButton buttonWithType:UIButtonTypeCustom];
    [_settings setFrame:CGRectMake(_camera.frame.origin.x - 35, _timeSlider.frame.origin.y + _timeSlider.frame.origin.y + 10, 50, 50)];
    [_settings setImage:[UIImage imageNamed:@"controls_settings"] forState:UIControlStateNormal];
    [_settings addTarget:self action:@selector(pressNightMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_settings];
    
    _gyro = [UIButton buttonWithType:UIButtonTypeCustom];
    [_gyro setFrame:CGRectMake(_camera.frame.origin.x + 35, _timeSlider.frame.origin.y + _timeSlider.frame.origin.y + 10, 50, 50)];
    [_gyro setImage:[UIImage imageNamed:@"controls_gyro"] forState:UIControlStateNormal];
    [_gyro addTarget:self action:@selector(pressNightMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_gyro];
    
    
    _upgrade = [UIButton buttonWithType:UIButtonTypeCustom];
    [_upgrade setFrame:CGRectMake(_settings.frame.origin.x - 70, _timeSlider.frame.origin.y + _timeSlider.frame.origin.y + 10, 50, 50)];
    [_upgrade setImage:[UIImage imageNamed:@"controls_downloads"] forState:UIControlStateNormal];
    [_upgrade setImage:[UIImage imageNamed:@"controls_downloads_new"] forState:UIControlStateDisabled];
    [_upgrade addTarget:self action:@selector(pressNightMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_upgrade];
    
    
    
    _rateApp = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rateApp setFrame:CGRectMake(_gyro.frame.origin.x + 70, _timeSlider.frame.origin.y + _timeSlider.frame.origin.y + 10, 50, 50)];
    [_rateApp setImage:[UIImage imageNamed:@"controls_rateapp"] forState:UIControlStateNormal];
    [_rateApp setImage:[UIImage imageNamed:@"controls_rateapp_pink"] forState:UIControlStateDisabled];
    [_rateApp addTarget:self action:@selector(enablePush) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_rateApp];
    
    
   /* float sliderVal = [[NSUserDefaults standardUserDefaults] floatForKey:@"CameraValue"];
    [transSlider setValue:sliderVal];
    
    NSNumber * value = [[NSUserDefaults standardUserDefaults] objectForKey: @"slider"];
    if(value.floatValue != 0.0f){
        [fadeSlider setValue: value.floatValue];
        
        secondsLabel.text = [NSString stringWithFormat: @"%.01f", value.floatValue];
        RampDownTime      = value.floatValue;
    }
    else
    {
        [fadeSlider setValue: 7.5f];
        
        secondsLabel.text = [NSString stringWithFormat: @"%.01f", 7.5f];
        RampDownTime      = 7.5;
    }*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)fadeSliderChanged:(UISlider*)sender{
   // RampDownTime = fadeSlider.value;
    
  //  [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithFloat: RampDownTime] forKey: @"FadeTime"];
}

-(void)transSliderChanged:(UISlider*)sender{
    [[NSUserDefaults standardUserDefaults] setFloat: sender.value forKey: @"CameraValue"];
}

- (void)nightModePressed{
    [[Kiip sharedInstance] saveMoment:NSLocalizedString(@"Enabled Nightmode", nil) withCompletionHandler:^(KPPoptart *poptart, NSError *error) {
        if (poptart) {
            poptart.delegate = self;
            [poptart show];
        }
    }];
    
    if([self.delegate respondsToSelector:@selector(nightModePressed)]) {
        [self.delegate nightModePressed];
    }
}

- (void)arModePressed{
  //  [[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:@"ARModeOn"];
    if([self.delegate respondsToSelector:@selector(arModePressed)]) {
        [self.delegate nightModePressed];
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
    if([self.delegate respondsToSelector:@selector(musicPressed)]) {
        [self.delegate musicPressed];
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
    if([self.delegate respondsToSelector:@selector(upgradePressed)]) {
        [self.delegate upgradePressed];
    }
}

- (void)enablePush{
    [UIAlertController showAlertInViewController:self withTitle:@"Stargaze Notifications" message:@"Get notified when the night sky is perfectly clear for stargazing" cancelButtonTitle:NSLocalizedString(@"No, thanks.", nil) destructiveButtonTitle:nil otherButtonTitles:@[NSLocalizedString(@"Yes, please!", nil)] tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
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

@end
