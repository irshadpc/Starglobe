//
//  star3mapAppDelegate.m
//  star3map
//
//  Created by Cass Everitt on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "star3mapAppDelegate.h"
#import "EAGLView.h"
#import "Network.h"
#include "star3map.h"
#import "Branch.h"



#ifdef STARGLOBE_PRO
//#import "Starglobe-Swift.h"
#endif

#ifdef STARGLOBE_FREE
//#import "Starglobe_Free-Swift.h"
#import "IAPManager.h"
#import "FyberSDK.h"
#endif

#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IS_OS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#include <string>
using namespace std;

#include "app.h"

@import Firebase;

double lastUpdate = 0.0;
double currentX = 0.0;
double currentY = 0.0;
double currentZ = 0.0;

bool calibrationEnabled = false;
extern double yRotation;

@implementation star3mapAppDelegate

-(void) initializeCapture
{
    session = [[AVCaptureSession alloc] init];
    [session beginConfiguration];
    session.sessionPreset = AVCaptureSessionPresetLow;

    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType: AVMediaTypeVideo];
    
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice: device error: nil];
    [session addInput: input];

    AVCaptureVideoDataOutput * output = [[AVCaptureVideoDataOutput alloc] init];
    [session addOutput: output];
    
    [output setSampleBufferDelegate: self queue: dispatch_get_main_queue()];
    
    [output setAlwaysDiscardsLateVideoFrames: YES];
    output.videoSettings = [NSDictionary dictionaryWithObject: [NSNumber numberWithInt: kCVPixelFormatType_32BGRA] 
                                                       forKey: (id)kCVPixelBufferPixelFormatTypeKey];
    output.minFrameDuration = CMTimeMake(15, 15);
    [session commitConfiguration];
    [session startRunning];
}

-(void) startCapture
{
    [session startRunning];
}

-(void) stopCapture
{
    [session stopRunning];
}

- (void)resetViews {
    platformQuit();
    if (window) {
        window = nil;
    }
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor redColor];
    
    [glView setRenderer];
    [window setRootViewController:navigationController];
    window.frame = [[UIScreen mainScreen] bounds];
    [navigationController.view setFrame:window.frame];
    
    
    [window makeKeyAndVisible];
    
    /*
    
    //[navigationController.view setFrame:[[UIScreen mainScreen] bounds]];
    //glView.backgroundColor = [UIColor redColor];
    // create navigation controller
    
    //window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //window.backgroundColor = [UIColor whiteColor];
    [window makeKeyAndVisible];
    //[window addSubview: navigationController.view];
    
    // start application
    platformMain();
    [glView startAnimation];
    
    // create location manager
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if (IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }
    [locationManager startUpdatingLocation];
    [locationManager startUpdatingHeading];
    
    // initialize accelerometer
    UIAccelerometer * accelerometer = [UIAccelerometer sharedAccelerometer];
    accelerometer.delegate = self;
    accelerometer.updateInterval = 0.1;
    
    // enable gyroscope
    gyroEnabled = NO;
    NSString * reqiredSystemVersion = @"4.0";
    NSString * currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    if([currentSystemVersion compare: reqiredSystemVersion options: NSNumericSearch] != NSOrderedAscending
       && [[UIDevice currentDevice].model isEqualToString: @"iPod touch"])
    {
        motionManager = [[CMMotionManager alloc] init];
        [motionManager startDeviceMotionUpdates];
        
        if([motionManager isGyroAvailable])
        {
            if([motionManager isGyroActive] == NO)
            {
                CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
                CMAttitude *attitude = deviceMotion.attitude;
                referenceAttitude = attitude;
                
                [motionManager setGyroUpdateInterval: 0.1];
                
                [motionManager startGyroUpdates];
                
                gyroEnabled = YES;
            }
            
            calibrationEnabled = true;
            
            [self initializeCapture];
            mainViewController.calibrateView.hidden   = NO;
            mainViewController.calibrateButton.hidden = NO;
        }
    }
    */
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], @"FirstLaunch", nil]];
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"FirstLaunch"] == YES){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MusicOn"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SatellitesOn"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ARModeOn"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NightModeOn"];

        [[NSUserDefaults standardUserDefaults] setFloat:7.5 forKey:@"FadeTime"];
        [[NSUserDefaults standardUserDefaults] setFloat:0.9 forKey:@"CameraValue"];




        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"BackgroundPlayback"];
    }
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults]integerForKey:@"HomePopupCounter"]+1 forKey:@"HomePopupCounter"];
    
    [UINavigationBar appearance].barStyle = UIBarStyleBlack;
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:40.0/250.0 green:40.0/250.0 blue:40.0/250.0 alpha:1.0];
    [UINavigationBar appearance].translucent = NO;
    [UITabBar appearance].barStyle = UIBarStyleBlack;
    [UITabBar appearance].barTintColor = [UIColor colorWithRed:40.0/250.0 green:40.0/250.0 blue:40.0/250.0 alpha:1.0];;
    [UITabBar appearance].translucent = NO;
    
    [[UINavigationBar appearance]setTintColor:[UIColor blueColor]];
    [[UIToolbar appearance]setTintColor:[UIColor blueColor]];
    
    application.idleTimerDisabled = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    BOOL hasCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"ARModeOn"] == nil && hasCamera) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ARModeOn"];
        //[[NSUserDefaults standardUserDefaults] setFloat:0.2 forKey:@"CameraValue"];
        [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:@"CameraValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    // create main view controller
    //mainViewController = [[MainViewController alloc] initWithNibName: UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? @"MainViewController-iPad" : @"MainViewController"
    //                                                          bundle: nil];
    
    NSArray *windows = [[UIApplication sharedApplication] windows];
    for(UIWindow *awindow in windows) {
        //NSLog(@"window: %@",awindow.description);
        if(awindow.rootViewController == nil){
            window = awindow;
            break;
        }
    }
    
    //window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    window.backgroundColor = [UIColor redColor];
    
    mainViewController = [[MainViewController alloc] init];
    
    // getting GL view
    glView = (EAGLView*)mainViewController.view;
    
    //[navigationController.view setFrame:[[UIScreen mainScreen] bounds]];
    //glView.backgroundColor = [UIColor redColor];
    // create navigation controller
    navigationController = [[UINavigationController alloc] initWithRootViewController: mainViewController];
    [navigationController setNavigationBarHidden: YES];
    
    //window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    //window.backgroundColor = [UIColor whiteColor];
    [glView setAutoresizesSubviews:YES];
    [glView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight)];
    //[window setRootViewController:navigationController];
    window.frame = [[UIScreen mainScreen] bounds];
    [navigationController.view setFrame:window.frame];
    [window setRootViewController:navigationController];
    
    [window makeKeyAndVisible];
    //[window addSubview: navigationController.view];
    
    NSNumber * value = [[NSUserDefaults standardUserDefaults] objectForKey: @"FadeTime"];
    if(value.floatValue != 0.0f) {
        RampDownTime = value.floatValue;
    } else {
        RampDownTime = 7.5;
    }
    
	platformMain();
	[glView startAnimation];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    if (IS_OS_8_OR_LATER) {
        [locationManager requestWhenInUseAuthorization];
    }
	[locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];

	// initialize accelerometer
	//UIAccelerometer * accelerometer = [UIAccelerometer sharedAccelerometer];
	//accelerometer.delegate = self;
	//accelerometer.updateInterval = 0.1;
    
    // enable gyroscope
    gyroEnabled = NO;
    NSString * reqiredSystemVersion = @"4.0";
    NSString * currentSystemVersion = [[UIDevice currentDevice] systemVersion];
    if([currentSystemVersion compare: reqiredSystemVersion options: NSNumericSearch] != NSOrderedAscending
       && [[UIDevice currentDevice].model isEqualToString: @"iPod touch"])
    {
        motionManager = [[CMMotionManager alloc] init];
        [motionManager startDeviceMotionUpdates];

        if([motionManager isGyroAvailable])
        {
            if([motionManager isGyroActive] == NO)
            {
                CMDeviceMotion *deviceMotion = motionManager.deviceMotion;      
                CMAttitude *attitude = deviceMotion.attitude;
                referenceAttitude = attitude;

                [motionManager setGyroUpdateInterval: 0.1];
                
                [motionManager startGyroUpdates];
                
                gyroEnabled = YES;
            }
            calibrationEnabled = true;
            
            [self initializeCapture];
            mainViewController.calibrateView.hidden   = NO;
            mainViewController.calibrateButton.hidden = NO;
        }
    } else {
        motionManager = [[CMMotionManager alloc] init];
        [motionManager startDeviceMotionUpdates];
        
        if([motionManager isGyroAvailable])
        {
            if([motionManager isGyroActive] == NO)
            {
                CMDeviceMotion *deviceMotion = motionManager.deviceMotion;
                CMAttitude *attitude = deviceMotion.attitude;
                referenceAttitude = attitude;
                
                [motionManager setGyroUpdateInterval: 0.1];
                
                [motionManager startGyroUpdates];
                
                gyroEnabled = YES;
            }
        }
    }
    
    Kiip *kiip;
    
#ifdef STARGLOBE_FREE
    FYBSDKOptions *options = [FYBSDKOptions optionsWithAppId:@"99578" securityToken:@"eeadc14f33237288c3fff36e7c03ed61"];
    [FyberSDK startWithOptions:options];
    
    [[GeneralHelper sharedManager] updatePrice];
    
    kiip = [[Kiip alloc] initWithAppKey:@"b1a59360704605fdb60ebca05feb3479" andSecret:@"c01e1a72d1034ae072f643a76760ccbb"];
    
#endif
    
#ifdef STARGLOBE_PRO
    kiip = [[Kiip alloc] initWithAppKey:@"8dc6d41d8bbcaacacba9a93582e9911d" andSecret:@"4dc8857e3a9601b0a93ad4df6755ee27"];
#endif
    
    kiip.delegate = self;
    [Kiip setSharedInstance:kiip];
    
    FIROptions *firebaseOptions;
    
#ifdef STARGLOBE_FREE
    firebaseOptions = [[FIROptions alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"StarglobeFree-GoogleService-Info" ofType:@"plist"]];
    firebaseOptions.deepLinkURLScheme = @"starglobefree";
    
#endif
#ifdef STARGLOBE_PRO
    firebaseOptions = [[FIROptions alloc]initWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"GoogleService-Info" ofType:@"plist"]];
    firebaseOptions.deepLinkURLScheme = @"starglobe";
#endif
    
    [FIRApp configureWithOptions:firebaseOptions];
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && params) {
            NSLog(@"params: %@", params.description);
        }
    }];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    if (userInfo[@""]) {
        NSLog(@"Message ID: %@", userInfo[@""]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // Print message ID.
    if (userInfo[@""]) {
        NSLog(@"Message ID: %@", userInfo[@""]);
    }
    
    // Print full message.
    NSLog(@"%@", userInfo);
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)tokenRefreshNotification:(NSNotification *)notification {
    // Note that this callback will be fired everytime a new token is generated, including the first
    // time. So if you need to retrieve the token as soon as it is available this is where that
    // should be done.
    NSString *refreshedToken = [[FIRInstanceID instanceID] token];
    NSLog(@"InstanceID token: %@", refreshedToken);
    
    // Connect to FCM since connection may have failed when attempted before having a token.

    
    // TODO: If necessary send token to application server.
}
    
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
        // pass the url to the handle deep link call
        [[Branch getInstance] handleDeepLink:url];
        
        // do other deep link routing for the Facebook SDK, Pinterest SDK, etc
        return YES;
    }
    
    // Respond to Universal Links
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray *restorableObjects))restorationHandler {
    BOOL handledByBranch = [[Branch getInstance] continueUserActivity:userActivity];
    
    return handledByBranch;
}


-(BOOL) gyroAvailable{
    return [motionManager isGyroActive];
}

-(void) applicationWillEnterForeground: (UIApplication*)application{
}

-(void) applicationWillResignActive: (UIApplication*)application{
	[glView stopAnimation];
}

-(void) applicationDidBecomeActive: (UIApplication*)application{
	[glView startAnimation];
}

-(void) applicationWillTerminate: (UIApplication*)application{
	[glView stopAnimation];
	platformQuit();
}


-(void) locationManager: (CLLocationManager*)manager didUpdateToLocation: (CLLocation*)newLocation fromLocation: (CLLocation*)oldLocation{
    if(newLocation.horizontalAccuracy < 0) 
        return;
    
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    if(locationAge > 5.0) 
        return;
	
	setLocation(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
}

-(void) locationManager: (CLLocationManager*)manager didUpdateHeading: (CLHeading*)newHeading{
	setHeading(newHeading.x, newHeading.y, newHeading.z, newHeading.trueHeading - newHeading.magneticHeading);
}

-(void) accelerometer: (UIAccelerometer*)accelerometer didAccelerate: (UIAcceleration*)acceleration{
	setAccel(acceleration.x, acceleration.y, acceleration.z);
}

-(void) updateGyroscope{
    if(!gyroEnabled)
        return;
    
    CMDeviceMotion * deviceMotion = motionManager.deviceMotion;      
    CMAttitude     * attitude     = deviceMotion.attitude;

    updateRotationMatrix(attitude.rotationMatrix.m11, attitude.rotationMatrix.m12, attitude.rotationMatrix.m13,
                         attitude.rotationMatrix.m21, attitude.rotationMatrix.m22, attitude.rotationMatrix.m23,
                         attitude.rotationMatrix.m31, attitude.rotationMatrix.m32, attitude.rotationMatrix.m33);
}

-(UIImage*) imageFromSampleBuffer: (CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer); 
    
    CVPixelBufferLockBaseAddress(imageBuffer, 0); 

    void   * baseAddress = CVPixelBufferGetBaseAddress(imageBuffer); 
    size_t   bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    size_t   width       = CVPixelBufferGetWidth(imageBuffer); 
    size_t   height      = CVPixelBufferGetHeight(imageBuffer); 
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst); 

    CGImageRef quartzImage = CGBitmapContextCreateImage(context); 

    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    CGContextRelease(context); 
    CGColorSpaceRelease(colorSpace);

    UIImage * image = [UIImage imageWithCGImage: quartzImage];

    CGImageRelease(quartzImage);
    
    return image;
}

-(void) captureOutput: (AVCaptureOutput*)captureOutput didOutputSampleBuffer: (CMSampleBufferRef)sampleBuffer fromConnection: (AVCaptureConnection*)connection{
    UIImage * image = [self imageFromSampleBuffer: sampleBuffer];
    [mainViewController.cameraImageView setImage: image];
    
    mainViewController.cameraImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI / 2);
    mainViewController.cameraImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    mainViewController.cameraImageView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
}

-(void) applicationDidReceiveMemoryWarning: (UIApplication*)application{
}

- (void) kiip:(Kiip *)kiip didReceiveContent:(NSString *)contentId quantity:(int)quantity transactionId:(NSString *)transactionId signature:(NSString *)signature {

}

@end
