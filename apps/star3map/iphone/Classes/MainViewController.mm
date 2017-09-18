//
//  MainViewController.m
//  star3map
//
//  Created by Dmitry Fadeev on 11.01.12.
//  Copyright 2012 knightmare@ether-engine.com. All rights reserved.
//

#import "MainViewController.h"
#import "NSData+Base64.h"
#import "Network.h"
#import "app.h"
#include "r3/command.h"
#include "r3/var.h"
#include "star3map.h"
#import "SAModalBrowserView.h"
#import "CaptureSessionManager.h"
#import "UIImage+Tint.h"
#import "star3mapAppDelegate.h"
#import "SolarSystemViewController.h"
#import "OnboardingViewController.h"
#import "StarsTableViewController.h"
#import "UpgradeViewController.h"
#import "UIView+MLScreenshot.h"
#import "BranchLinkProperties.h"
#import "BranchUniversalObject.h"
#import "MKStoreKit.h"
#import "UAAppReviewManager.h"
#import "AboutViewController.h"

extern bool calibrationEnabled;
extern float redVisionDestination;

@implementation MainViewController

@synthesize cameraImageView;
@synthesize calibrateButton;
@synthesize calibrateView;
@synthesize captureManager;
@synthesize glView;
@synthesize cameraView;
@synthesize popOver;
@synthesize lastContext;
@synthesize nextContext;
@synthesize searchButton;
@synthesize searchField;
@synthesize searchDataSource;
@synthesize infoView;
@synthesize infoViewsShown;

- (BOOL)prefersStatusBarHidden{
    return YES;
}

-(void) viewDidLoad{
    [super viewDidLoad];
    
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
    
    redVisionEnabled = NO;
    
    
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ARModeOn"] == NO) {
        hasCamera = NO;
    }
        
    glView.redVisionOnButton = redVisionEnableButton;
    glView.redVisionOffButton = redVisionDisableButton;
    glView.optionsButton = optionsButton;
    glView.shareButton = shareButton;
    glView.newsButton = newsButton;
    glView.calibrateButton = calibrateButton;
    glView.calibrateView = calibrateView;
    glView.calibrateTarget = calibrateTarget;
    glView.calibrateLabel = calibrateLabel;
    glView.calibrateInfo = calibrateInfo;
    
    self.lastContext = [EAGLContext currentContext];
    /*if(![[NSUserDefaults standardUserDefaults] boolForKey: @"FadeGestureUsed"])
    {
        fadeMessageView.hidden = NO;
        glView.fadeMessageView = fadeMessageView;
    }*/
    
    /*if (hasCamera) {
        self.cameraView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.cameraView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
        [self.view addSubview:cameraView];
        [cameraView setUserInteractionEnabled:NO];
        [cameraView setBackgroundColor:[UIColor clearColor]];
        [cameraView setAlpha:[[NSUserDefaults standardUserDefaults] floatForKey:@"CameraValue"]];
        [self setCaptureManager:[[CaptureSessionManager alloc] init]];
        
        [[self captureManager] addVideoInput];
        
        [[self captureManager] addVideoPreviewLayer];
        CGRect layerRect = [[[self view] layer] bounds];
        [[[self captureManager] previewLayer] setBounds:layerRect];
        [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                      CGRectGetMidY(layerRect))];
        [cameraView.layer addSublayer:[[self captureManager] previewLayer]];
        [[captureManager captureSession] startRunning];
        [cameraView setBackgroundColor:[UIColor redColor]];
    }*/
    
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuButton setAccessibilityLabel:@"Main Menu"];
    [self.menuButton setImage:[UIImage imageNamed:@"MenuOff"] forState:UIControlStateNormal];
    [self.menuButton setImage:[UIImage imageNamed:@"MenuActive"] forState:UIControlStateHighlighted];
    [self.menuButton setFrame:CGRectMake(0, 0, 50, 50)];
    [self.menuButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:self.menuButton];
    [self.menuButton addTarget:self action:@selector(showSettingsPopover) forControlEvents:UIControlEventTouchUpInside];
    
    self.gyroButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gyroButton setAccessibilityLabel:@"Search"];
    [self.gyroButton setImage:[UIImage imageNamed:@"GyroOff"] forState:UIControlStateNormal];
    [self.gyroButton setImage:[UIImage imageNamed:@"GyroActive"] forState:UIControlStateHighlighted];
    [self.gyroButton setFrame:CGRectMake((self.view.frame.size.width)/2 - 50, 0, 50, 50)];
    [self.gyroButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:self.gyroButton];
    [self.gyroButton addTarget:self action:@selector(toggleCompass:) forControlEvents:UIControlEventTouchUpInside];
    
    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.searchButton setAccessibilityLabel:@"Search"];
    [self.searchButton setImage:[UIImage imageNamed:@"SearchOff"] forState:UIControlStateNormal];
    [self.searchButton setImage:[UIImage imageNamed:@"SearchActive"] forState:UIControlStateHighlighted];
    [self.searchButton setFrame:CGRectMake(self.view.frame.size.width-50, 0, 50, 50)];
    [self.searchButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
    [self.view addSubview:self.searchButton];
    [self.searchButton addTarget:self action:@selector(showStars) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[GeneralHelper sharedManager]freeVersion]){
    _bannerView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 50, self.view.frame.size.width, 50)];
    _bannerView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    [self.view addSubview:_bannerView];
    
    _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
    _iconView.image = [UIImage imageNamed:@"Icon-Rounded"];
    [_bannerView addSubview: _iconView];
    
    _headlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 10, self.view.frame.size.width - 60, 17)];
    _headlineLabel.numberOfLines = 1;
    _headlineLabel.font = [UIFont boldSystemFontOfSize:16];
    _headlineLabel.textColor = [UIColor whiteColor];
    _headlineLabel.text = NSLocalizedString(@"Starglobe Pro", nil);
    [_bannerView addSubview: _headlineLabel];
    
    _subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 27, self.view.frame.size.width - 60, 33)];
    _subtitleLabel.numberOfLines = 2;
    _subtitleLabel.font = [UIFont systemFontOfSize:12];
    _subtitleLabel.textColor = [UIColor whiteColor];
    _subtitleLabel.text = NSLocalizedString(@"Try all of the magical premium features of Starglobe for free right now!", nil);
    [_bannerView addSubview: _subtitleLabel];
    
    _upgradeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_upgradeButton setFrame:CGRectMake(_headlineLabel.frame.origin.x + _headlineLabel.frame.size.width + 10, 10, 95, 40)];
    [_upgradeButton setTitle:NSLocalizedString(@"Upgrade", nil) forState:UIControlStateNormal];
    [_upgradeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [_upgradeButton setBackgroundColor:[UIColor redColor]];
    [_upgradeButton setTintColor:[UIColor whiteColor]];
    [_upgradeButton addTarget:self action:@selector(showUpgradeView) forControlEvents:UIControlEventTouchUpInside];
    [_bannerView addSubview: _upgradeButton];
    
    _overlayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_overlayButton setBackgroundColor:[UIColor clearColor]];
    [_overlayButton addTarget:self action:@selector(showUpgradeView) forControlEvents:UIControlEventTouchDown];
    [_overlayButton setFrame:_bannerView.frame];
    [self.view addSubview:_overlayButton];
    [self.view bringSubviewToFront:_overlayButton];
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/soundtrack.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    
    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    _audioPlayer.numberOfLoops = -1;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MusicOn"]) {
        [_audioPlayer play];
    } else {
        [_audioPlayer pause];
    }
    
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.square = NO;
    
    
    [[MKStoreKit sharedKit] startProductRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(succesfulPurchase) name:@"Purchase" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(succesfulPurchase) name:@"RestoredPurchase" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPurchase) name:@"FailedRestoring" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPurchase) name:@"FailedPurchase" object:nil];
    
    if (satellitesShowing){
        NSLog(@"satellitesShowing");
    }

    satellitesShowing = [[NSUserDefaults standardUserDefaults] boolForKey:@"SatellitesOn"];
    [glView toggleSatellites:[[NSUserDefaults standardUserDefaults] boolForKey:@"SatellitesOn"]];
    [glView toggleCompass:NO];
}

- (void)succesfulPurchase{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"StarglobePro"];
        [self.bannerView removeFromSuperview];
    }];
}


- (void)failedPurchase{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.HUD hideAnimated:NO];
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.menuButton setFrame:CGRectMake(0, 0, 50, 50)];
    [self.gyroButton setFrame:CGRectMake((self.view.frame.size.width - 50)/2 , 0, 50, 50)];
    [self.searchButton setFrame:CGRectMake(self.view.frame.size.width-50, 0, 50, 50)];
    if ([[GeneralHelper sharedManager]freeVersion]){
    [_bannerView setFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
    [_iconView setFrame:CGRectMake(5, 5, 50, 50)];
    [_headlineLabel setFrame:CGRectMake(65, 5, self.view.frame.size.width - 175, 20)];
    [_subtitleLabel setFrame:CGRectMake(65, 24, self.view.frame.size.width - 175, 35)];
    [_upgradeButton setFrame:CGRectMake(_headlineLabel.frame.origin.x + _headlineLabel.frame.size.width + 10, 0, 100, 60)];
    [_overlayButton setFrame:_bannerView.frame];
    }
}

- (void)showStars{
    self.lastContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:nil];
    
    [FIRAnalytics logEventWithName:@"Tapped_Show_Stars" parameters:nil];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    UITabBarController *tabbarController = [[UITabBarController alloc]init];
    
    StarsTableViewController *stars = [storyboard instantiateViewControllerWithIdentifier:@"StarsTableViewController"];
    UINavigationController *starsNavigationController = [[UINavigationController alloc] initWithRootViewController:stars];
    
    starsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Discover", nil) image:[UIImage imageNamed:@"menu_icon_stars"] tag:11];
    
    UINavigationController *solarSystemNavigationController = [[UINavigationController alloc] initWithRootViewController:[SolarSystemViewController sharedInstance]];
    solarSystemNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Solar System", nil) image:[UIImage imageNamed:@"menu_icon_solar_system"] tag:12];
    
    if ([[GeneralHelper sharedManager]freeVersion]) {
        UpgradeViewController *upgradeSettings = [storyboard instantiateViewControllerWithIdentifier:@"UpgradeViewController"];
        upgradeSettings.inTabbar = YES;
        UINavigationController *upgradeNavigation = [[UINavigationController alloc]initWithRootViewController:upgradeSettings];
        upgradeNavigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Upgrade", nil) image:[UIImage imageNamed:@"more"] tag:13];
        
        [tabbarController setViewControllers:@[solarSystemNavigationController, starsNavigationController, upgradeNavigation]];
    } else {
        [tabbarController setViewControllers:@[solarSystemNavigationController, starsNavigationController]];
    }
    
    tabbarController.tabBar.tintColor = [UIColor whiteColor];
    
 
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:tabbarController animated:YES completion:nil];
    });
}

- (void)showUpgradeView{
    self.lastContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:nil];
        
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    
    
    UITabBarController *tabbarController = [[UITabBarController alloc]init];
    
    StarsTableViewController *stars = [storyboard instantiateViewControllerWithIdentifier:@"StarsTableViewController"];
    UINavigationController *starsNavigationController = [[UINavigationController alloc] initWithRootViewController:stars];
    
    starsNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Discover", nil) image:[UIImage imageNamed:@"menu_icon_stars"] tag:11];
    
    UINavigationController *solarSystemNavigationController = [[UINavigationController alloc] initWithRootViewController:[SolarSystemViewController sharedInstance]];
    solarSystemNavigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Solar System", nil) image:[UIImage imageNamed:@"menu_icon_solar_system"] tag:12];
    
    if ([[GeneralHelper sharedManager]freeVersion]) {
        UpgradeViewController *upgradeSettings = [storyboard instantiateViewControllerWithIdentifier:@"UpgradeViewController"];
        upgradeSettings.inTabbar = YES;
        UINavigationController *upgradeNavigation = [[UINavigationController alloc]initWithRootViewController:upgradeSettings];
        upgradeNavigation.tabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"Upgrade", nil) image:[UIImage imageNamed:@"more"] tag:13];
        
        [tabbarController setViewControllers:@[solarSystemNavigationController, starsNavigationController , upgradeNavigation]];
    } else {
        [tabbarController setViewControllers:@[solarSystemNavigationController, starsNavigationController ]];
    }
    
    tabbarController.tabBar.tintColor = [UIColor whiteColor];
    [tabbarController setSelectedIndex:2];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:tabbarController animated:YES completion:nil];
    });

}

-(void)showAbout{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
    AboutViewController *aboutView = [storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    UINavigationController *starsNavigationController = [[UINavigationController alloc] initWithRootViewController:aboutView];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:starsNavigationController animated:YES completion:nil];
    });
}

- (void)showSettingsPopover{
    SettingsPopupViewController *settingsPopup = [[SettingsPopupViewController alloc]init];
    settingsPopup.delegate = self;
    self.popupViewController = [[STPopupController alloc] initWithRootViewController:settingsPopup];
    self.popupViewController.style = STPopupStyleBottomSheet;
    [self.popupViewController.backgroundView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundViewDidTap)]];
    self.popupViewController.navigationBarHidden = YES;
    [self.popupViewController presentInViewController:self];
}

- (void)backgroundViewDidTap{
    [self.self.popupViewController dismiss];
}

- (void)toggleCompass:(id)sender {
    extern r3::VarBool app_useCompass;
    if(!app_useCompass.GetVal()) {
        [glView toggleCompass:YES];
    } else {
        [glView toggleCompass:NO];
    }
    useCompass = YES;
}


- (void)showIntro {
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    UIImage *normalImage = [[UIImage imageNamed:@"button"] resizableImageWithCapInsets:insets];
    
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:NSLocalizedString(@"Welcome to Starglobe", nil) body:NSLocalizedString(@"Starglobe is magical. Simply raise your iPhone or iPad to the sky to identify planets, constellation or even satellites!", nil) image:[UIImage imageNamed:@"stars"] buttonText:NSLocalizedString(@"Next", nil) action:^{
        
    }];
    firstPage.titleLabel.font = [UIFont fontWithName:@"Bree-Oblique" size:27.0];
    firstPage.bodyLabel.font = [UIFont fontWithName:@"Roboto-Light" size:14.0];
    firstPage.actionButton.hidden = YES;
    firstPage.movesToNextViewController = YES;

    
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:NSLocalizedString(@"Detailed Solar System", nil) body:NSLocalizedString(@"Deep zoom to reveal more stars in the new Power Sky View. With animated high-res planets and over 110000 more objects, there’s plenty to explore!", nil) image:[UIImage imageNamed:@"planet"] buttonText:NSLocalizedString(@"Next", nil) action:^{
        
    }];
    secondPage.titleLabel.font = [UIFont fontWithName:@"Bree-Oblique" size:27.0];
    secondPage.bodyLabel.font = [UIFont fontWithName:@"Roboto-Light" size:14.0];
    secondPage.actionButton.hidden = YES;
    secondPage.movesToNextViewController = YES;

    
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle:NSLocalizedString(@"Geolocation", nil) body:NSLocalizedString(@"Geolocation permissions are needed to create an accurate Sky View. You must allow this for Starglobe to identify objects in the sky above.", nil) image:[UIImage imageNamed:@"location"] buttonText:NSLocalizedString(@"Allow", nil) action:^{
        [_locationManager requestWhenInUseAuthorization];
    }];
    thirdPage.titleLabel.font = [UIFont fontWithName:@"Bree-Oblique" size:27.0];
    thirdPage.bodyLabel.font = [UIFont fontWithName:@"Roboto-Light" size:14.0];
    thirdPage.movesToNextViewController = YES;
    [thirdPage.actionButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    thirdPage.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    thirdPage.bottomPadding = 40;
    

    
    OnboardingContentViewController *fourthPage;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"StarglobeProForLife"]){
        if([[NSUserDefaults standardUserDefaults] boolForKey: @"AppGratis"]){
            fourthPage = [OnboardingContentViewController contentWithTitle:NSLocalizedString(@"AppGratis", nil) body:NSLocalizedString(@"Thanks to AppGratis, you are receiving the Pro version (worth $9.99) of Starglobe for free!", nil) image:[UIImage imageNamed:@"upgrade"] buttonText:NSLocalizedString(@"Check out AppGratis", nil) action:^{
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://appgratis.com"] options:[NSDictionary dictionary] completionHandler:nil];
            }];
        } else if([[NSUserDefaults standardUserDefaults] boolForKey: @"AppTurbo"]){
            fourthPage = [OnboardingContentViewController contentWithTitle:NSLocalizedString(@"AppGratis", nil) body:NSLocalizedString(@"Thanks to AppGratis, you are receiving the Pro version (worth $9.99) of Starglobe for free!", nil) image:[UIImage imageNamed:@"upgrade"] buttonText:NSLocalizedString(@"Check out AppGratis", nil) action:^{
                [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://appturbo.com"] options:[NSDictionary dictionary] completionHandler:nil];
            }];
        }
    } else {
        fourthPage = [OnboardingContentViewController contentWithTitle:NSLocalizedString(@"Starglobe Premium", nil) body:NSLocalizedString(@"Try all of the magical premium features of Starglobe for free right now!", nil) image:[UIImage imageNamed:@"upgrade"] buttonText:NSLocalizedString(@"Try for Free", nil) action:^{
            self.showUpgrade = YES;
            
        }];
    }
    
    fourthPage.titleLabel.font = [UIFont fontWithName:@"Bree-Oblique" size:27.0];
    fourthPage.bodyLabel.font = [UIFont fontWithName:@"Roboto-Light" size:14.0];
    fourthPage.actionButton.titleLabel.text = NSLocalizedString(@"Start 1 month free trial!", nil);
    [fourthPage.actionButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    fourthPage.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:21];
    fourthPage.movesToNextViewController = YES;
    fourthPage.bottomPadding = 40;
    [fourthPage.view addSubview:self.HUD];

    
    OnboardingContentViewController *fifthPage = [OnboardingContentViewController contentWithTitle:NSLocalizedString(@"Starglobe Premium", nil) body:NSLocalizedString(@"Try all of the magical premium features of Starglobe for free right now!", nil) image:[UIImage imageNamed:@"upgrade"] buttonText:NSLocalizedString(@"Upgrade", nil) action:^{
    }];
    
    fifthPage.viewWillAppearBlock = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };

    
    OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@"OnboardBackground"] contents:@[firstPage, secondPage, thirdPage, fourthPage, fifthPage]];
    onboardingVC.shouldFadeTransitions = YES;
    onboardingVC.shouldMaskBackground = NO;
    onboardingVC.fadePageControlOnLastPage = YES;
    onboardingVC.allowSkipping = YES;
    [onboardingVC.skipButton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
    onboardingVC.skipHandler = ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    
    fourthPage.viewDidAppearBlock = ^{
        [onboardingVC.skipButton setTitle:NSLocalizedString(@"Skip", nil) forState:UIControlStateNormal];
        [onboardingVC.pageControl setHidden:YES];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"StarglobeFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    };
    
    
    [self presentViewController:onboardingVC animated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear");

    
    if (!_firstLoaded) {
        _firstLoaded = YES;
        satellitesShowing = [[NSUserDefaults standardUserDefaults] boolForKey:@"SatellitesOn"];
        [glView toggleSatellites:[[NSUserDefaults standardUserDefaults] boolForKey:@"SatellitesOn"]];
        [glView toggleCompass:NO];
        useCompass = NO;
    }
    
    
    

    //[glView setRenderer];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ARModeOn"] == NO && cameraView) {
        [cameraView setAlpha:0.0];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ARModeOn"] == YES && cameraView) {
        [cameraView setAlpha:[[NSUserDefaults standardUserDefaults] floatForKey:@"CameraValue"]];
    }
    else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ARModeOn"] == YES && !cameraView) {
        self.cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:cameraView];
        [cameraView setUserInteractionEnabled:NO];
        [cameraView setBackgroundColor:[UIColor clearColor]];
        [cameraView setAlpha:[[NSUserDefaults standardUserDefaults] floatForKey:@"CameraValue"]];
        [self setCaptureManager:[[CaptureSessionManager alloc] init]];
        
        [[self captureManager] addVideoInput];
        
        [[self captureManager] addVideoPreviewLayer];
        CGRect layerRect = [[[self view] layer] bounds];
        [[[self captureManager] previewLayer] setBounds:layerRect];
        [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                      CGRectGetMidY(layerRect))];
        [cameraView.layer addSublayer:[[self captureManager] previewLayer]];
        [[captureManager captureSession] startRunning];
        
    }
    if (self.lastContext) {
        [EAGLContext setCurrentContext:self.lastContext];
    }
    [glView startAnimation];
    //[glView drawView:self];
    
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"MusicOn"]) { NSLog(@"MusicOn");
        [_audioPlayer play];
    } else {
        [_audioPlayer pause];
    }
    
    
    _isVisible = YES;
    //[self showIntro];

    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"StarglobeFirstLaunch"]) {
        [self showIntro];
    } else if (_showUpgrade) {
        _showUpgrade = NO;
        [self showUpgradeView];
    } else if (_takeScreenshot) {
        _takeScreenshot = NO;
        UIImage *shareImage = [self screenshot];
        NSArray *items = @[shareImage];
        
        UIActivityViewController *controller = [[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
        
        [self presentViewController:controller animated:YES completion:nil];
    } else if (_showDiscover) {
        _showDiscover = NO;
        [self showStars];
    } else if (_showMore) {
        _showMore = NO;
        [self showAbout];
    } else if ([[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] > 1 && [[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] % 5 == 0 && [[GeneralHelper sharedManager]freeVersion]) {
            [self showUpgradeView];
    } else if ([[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] % 9 == 0) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.3) {
            [SKStoreReviewController requestReview];
        } else {
            [UAAppReviewManager showPrompt];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] + 1 forKey:@"InterstitialCounter"];
}


-(void) viewDidUnload{
}

-(IBAction) switchRedVision: (id)sender{
    redVisionEnabled = !redVisionEnabled;
    
    redVisionDestination = redVisionEnabled ? 1.0f : 0.0f;
}



- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    NSLog(@"viewWillDisappear");
    [glView stopAnimation];
    _isVisible = NO;
}


-(void)showPlanetsWindow:(UIButton*)sender {
    //[glView stopAnimation];

    self.lastContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:nil];
    
    //EAGLContext *thisContext = context; // get the context of this view
    //[EAGLContext setCurrentContext:thisContext];
    
    // do the deletion and cleanup
    
    //glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    //glDeleteRenderbuffersOES(1, &viewFramebuffer);
    //glDeleteRenderbuffersOES(1, &sampleFramebuffer);
    //context = nil;
    
    /*if(lastContext == thisContext)
    {
        // since there was no other context set just destroy this one
        [EAGLContext setCurrentContext:nil];
    }
    else
    {
        // there was another context previously set so let us just set it back
        [EAGLContext setCurrentContext:lastContext];
    }*/
    
    solarVc = [SolarSystemViewController sharedInstance];
    //solarVc = [[SolarSystemViewController alloc] init];
    //UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:solarVc];
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
    [self.navigationController pushViewController:solarVc animated: YES];
    //star3mapAppDelegate *delegate = (star3mapAppDelegate*)[UIApplication sharedApplication].delegate;
    //[delegate.window setRootViewController:nc];
    //[self.navigationController presentViewController:nc animated:YES completion:nil];
    
    /*if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [popOver dismissPopoverAnimated:YES];
        OWOuterSpaceTableViewController *vc = [[OWOuterSpaceTableViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:nc];
        self.popOver = popover;
        [popOver setPopoverContentSize:CGSizeMake(320, 480)];
        popOver.delegate = self;
        [popOver presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }
    else {
        OWOuterSpaceTableViewController *vc = [[OWOuterSpaceTableViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
        vc.navigationController.navigationBarHidden = NO;
        [self.navigationController pushViewController: vc animated: YES];
    }*/

}

-(BOOL) popoverControllerShouldDismissPopover: (UIPopoverController*)popoverController{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ARModeOn"] == NO && cameraView) {
        [cameraView setAlpha:0.0];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ARModeOn"] == YES && cameraView) {
        [cameraView setAlpha:[[NSUserDefaults standardUserDefaults] floatForKey:@"CameraValue"]];
    } else if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ARModeOn"] == YES && !cameraView) {
        self.cameraView = [[UIView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:cameraView];
        [cameraView setUserInteractionEnabled:NO];
        [cameraView setBackgroundColor:[UIColor clearColor]];
        [cameraView setAlpha:[[NSUserDefaults standardUserDefaults] floatForKey:@"CameraValue"]];
        [self setCaptureManager:[[CaptureSessionManager alloc] init]];
        
        [[self captureManager] addVideoInput];
        
        [[self captureManager] addVideoPreviewLayer];
        CGRect layerRect = [[[self view] layer] bounds];
        [[[self captureManager] previewLayer] setBounds:layerRect];
        [[[self captureManager] previewLayer] setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                                                      CGRectGetMidY(layerRect))];
        [cameraView.layer addSublayer:[[self captureManager] previewLayer]];
        [[captureManager captureSession] startRunning];
    }
    return YES;
}

-(NSInteger) numberOfSectionsInTableView: (UITableView*)aTableView{
    return 1;
}


-(NSInteger) tableView: (UITableView*)aTableView numberOfRowsInSection: (NSInteger)section{
    return [popoverButtons count];
}


-(UITableViewCell*) tableView: (UITableView*)tableView cellForRowAtIndexPath: (NSIndexPath*)indexPath{
    static NSString * cellIdentifier = @"CellIdentifier";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier: cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: cellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    [cell.textLabel setFont: [UIFont fontWithName: @"Helvetica Bold" size: 20]];
    
    cell.textLabel.text =[popoverButtons objectAtIndex: indexPath.row];
    return cell;
}

-(IBAction) switchCalibration: (id)sender{
    calibrationEnabled = !calibrationEnabled;
    
    [calibrateButton setTitle: calibrationEnabled ? @"Done" : @"Calibrate" forState: UIControlStateNormal];
    
    if (calibrationEnabled){
        [[UIApplication sharedApplication].delegate performSelector: @selector(startCapture)];
        
        extern r3::VarBool app_useCompass;
        if(!app_useCompass.GetVal())
            r3::ExecuteCommand("toggle app_useCompass");
        
        extern r3::VarBool app_useCoreLocation;
        if(!app_useCoreLocation.GetVal())
            r3::ExecuteCommand("toggle app_useCoreLocation");
    } else {
        [[UIApplication sharedApplication].delegate performSelector: @selector(stopCapture)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void) locationManager: (CLLocationManager*)manager didUpdateToLocation: (CLLocation*)newLocation fromLocation: (CLLocation*)oldLocation{
    if(newLocation.horizontalAccuracy < 0)
        return;
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if(locationAge > 5.0)
        return;
    NSLog(@"≈ %d longitude %d", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    setLocation(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

-(void) locationManager: (CLLocationManager*)manager didUpdateHeading: (CLHeading*)newHeading{
    setHeading(newHeading.x, newHeading.y, newHeading.z, newHeading.trueHeading - newHeading.magneticHeading);
}

-(void) accelerometer: (UIAccelerometer*)accelerometer didAccelerate: (UIAcceleration*)acceleration{
    setAccel(-acceleration.x, acceleration.y, -acceleration.z);
}

- (void)nightModePressed{
    [self switchRedVision:self];
}

- (void)arModePressed{
    extern r3::VarBool app_useCompass;
    if(!app_useCompass.GetVal()) {
        [glView toggleCompass:YES];
    } else {
        [glView toggleCompass:NO];
    }
    useCompass = YES;
}

- (void)infosPressed{
    _showMore = YES;
}

- (UIImage*)screenshot{
    
    self.menuButton.hidden = YES;
    self.gyroButton.hidden = YES;
    self.searchButton.hidden = YES;
    
    CGSize imageSize = CGSizeZero;
    
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.menuButton.hidden = NO;
    self.gyroButton.hidden = NO;
    self.searchButton.hidden = NO;
    
    return image;
}


- (void)cameraPressed{
    /*extern r3::VarBool app_useCoreLocation;
    if(!app_useCoreLocation.GetVal()) {
        r3::ExecuteCommand("toggle app_useCoreLocation");
    } else {
        r3::ExecuteCommand("toggle app_useCoreLocation");
    }
    useCompass = YES;
    extern r3::VarBool app_useCoreLocation;
    if(!app_useCoreLocation.GetVal()) {
        r3::ExecuteCommand("toggle app_changeLocation");
    } else {
        r3::ExecuteCommand("toggle app_changeLocation");
    }
    useCompass = YES;*/
}

- (void)musicPressed{
    if (_audioPlayer.isPlaying) {
        [_audioPlayer pause];
    } else {
        [_audioPlayer play];
    }
}

- (void)satellitesPressed{
    if (satellitesShowing) {
        [glView toggleSatellites:NO];
        satellitesShowing = NO;
    } else {
        [glView toggleSatellites:YES];
        satellitesShowing = YES;
    }
}

- (void)gyroPressed{
    extern r3::VarBool app_useCoreLocation;
    if(!app_useCoreLocation.GetVal()) {
        r3::ExecuteCommand("toggle app_useCoreLocation");
    } else {
        r3::ExecuteCommand("toggle app_useCoreLocation");
    }
    useCompass = YES;
}

- (void)settingsPressed{
    
}

- (void)upgradePressed{
    
}

- (void)changedCameraTime:(float)time{

}

-(void)changedFadeTime:(float)time{
    RampDownTime = time;
}


@end
