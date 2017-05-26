//
//  MainViewController.h
//  star3map
//
//  Created by Dmitry Fadeev on 11.01.12.
//  Copyright 2012 knightmare@ether-engine.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "EAGLView.h"
#import <STPopup/STPopup.h>
#import "SettingsPopupViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <AVFoundation/AVFoundation.h>

#ifdef STARGLOBE_FREE
//#import "Starglobe_Free-Swift.h"
#import "AdHelper.h"
#import "FyberSDK.h"
#import "FYBAdMob.h"
#import "FYBFacebookAudienceNetwork.h"
//#import "FYBTaypjoy.h"
//#import "FYBInneractive.h"
#import "FYBInMobi.h"
#import "FYBIntegrationAnalyzerViewController.h"
#endif

@class CaptureSessionManager;
@class MLPAutoCompleteTextField;
@class SolarSystemViewController;
@class SearchDataSource;

#ifdef STARGLOBE_FREE
#define Delegates UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, UITextFieldDelegate, SettingsPopupDelegate, CLLocationManagerDelegate
#endif
#ifdef STARGLOBE_PRO
#define Delegates UITableViewDataSource, UITableViewDelegate, UIPopoverControllerDelegate, UITextFieldDelegate, SettingsPopupDelegate, CLLocationManagerDelegate
#endif

@interface MainViewController : UIViewController <Delegates> {
    IBOutlet UIButton     * redVisionEnableButton;
    IBOutlet UIButton     * redVisionDisableButton;
    IBOutlet UIButton     * optionsButton;
    IBOutlet UIButton     * shareButton;
    IBOutlet UIButton     * newsButton;
    IBOutlet UIView       * postingView;
    IBOutlet EAGLView     * glView;
    IBOutlet UIView       * fadeMessageView;
    IBOutlet UILabel      * calibrateLabel;
    IBOutlet UITextView   * calibrateInfo;
    IBOutlet UIImageView  * calibrateTarget;
    UIView                * calibrateView;
    UIButton              * calibrateButton;
    NSMutableArray        * popoverButtons;
    UIPopoverController   * popOver;
    UIImageView           * cameraImageView;
    BOOL                    redVisionEnabled;
    CaptureSessionManager * captureManager;
    UIView                *cameraView;
    
    UIButton              *searchButton;
    BOOL satellitesShowing;
    BOOL useCompass;
    EAGLContext *lastContext;
    EAGLContext *nextContext;
    SolarSystemViewController *solarVc;
    MLPAutoCompleteTextField *searchField;
}
@property BOOL firstLoaded;
@property BOOL takeScreenshot;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) CLLocationManager      * locationManager;
@property (nonatomic, strong) STPopupController *popupViewController;
@property (nonatomic, strong) UIButton              *menuButton;
@property (nonatomic, strong) UIButton              *gyroButton;
@property (nonatomic, strong) UIScrollView *infoView;
@property (nonatomic, strong) NSMutableArray *infoViewsShown;
@property (strong, nonatomic) SearchDataSource *searchDataSource;
@property (nonatomic, strong) MLPAutoCompleteTextField *searchField;
@property (nonatomic) BOOL searchToogled;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) EAGLContext *lastContext, *nextContext;
@property (readwrite, strong) UIPopoverController *popOver;
@property(strong) EAGLView             * glView;
@property(strong) CaptureSessionManager * captureManager;
@property(strong) IBOutlet UIImageView * cameraImageView;
@property(strong) IBOutlet UIButton    * calibrateButton;
@property(strong) IBOutlet UIView      * calibrateView;
@property(strong) IBOutlet UIView      * cameraView;

- (UIImage*)screenshot;
-(IBAction) toggleMenu:(id)sender;
-(IBAction) switchRedVision:(id)sender;
-(IBAction) showOptionsWindow:(id)sender;
-(IBAction) switchCalibration:(id)sender;
-(IBAction) showWebView:(id)sender;

@end
