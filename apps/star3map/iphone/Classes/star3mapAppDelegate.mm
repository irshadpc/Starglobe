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
//#import "Starglobe_Free-Swift.h"
#import "MKStoreKit.h"
#import "SolarSystemViewController.h"
#include <string>
using namespace std;

#include "app.h"
#import <StoreKit/StoreKit.h>

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
    [UINavigationBar appearance].barStyle = UIBarStyleBlack;
    [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:40.0/250.0 green:40.0/250.0 blue:40.0/250.0 alpha:1.0];
    [UINavigationBar appearance].translucent = NO;
    [UITabBar appearance].barStyle = UIBarStyleBlack;
    [UITabBar appearance].barTintColor = [UIColor colorWithRed:40.0/250.0 green:40.0/250.0 blue:40.0/250.0 alpha:1.0];;
    [UITabBar appearance].translucent = NO;
    [[UINavigationBar appearance]setTintColor:[UIColor whiteColor]];
    [[UITabBar appearance]setTintColor:[UIColor whiteColor]];
    application.idleTimerDisabled = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithBool:YES], @"StarglobeFirstLaunch", nil]];
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"StarglobeFirstLaunch"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MusicOn"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"SatellitesOn"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"ARModeOn"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"NightModeOn"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"LaunchCounter"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"InterstitialCounter"];
        [[NSUserDefaults standardUserDefaults] setObject:@"$9.99" forKey:@"IAPPrice"];
         
        [[NSUserDefaults standardUserDefaults] setFloat:7.5 forKey:@"FadeTime"];
        [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:@"CameraValue"];
        [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:@"RealCameraValue"];
        [[NSUserDefaults standardUserDefaults] setFloat:0.0 forKey:@"RealCameraValue"];

        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"StarglobePro"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"StarglobeProForLife"];
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults]integerForKey:@"LaunchCounter"] + 1 forKey:@"LaunchCounter"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    //[locationManager requestWhenInUseAuthorization];
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
        
        if([motionManager isGyroAvailable]) {
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
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchasedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"Purchase" object:nil];
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"PurchaseUpgrade" object:nil];

                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoredPurchasesNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Restored Purchases");
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"RestoredPurchase" object:nil];
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"RestoredPurchaseUpgrade" object:nil];
                                                      
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitRestoringPurchasesFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"FailedRestoring" object:nil];
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"FailedRestoringUpgrade" object:nil];
                                                      
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductPurchaseFailedNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Failed restoring purchases with error: %@", [note object]);
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"FailedPurchase" object:nil];
                                                      [[NSNotificationCenter defaultCenter]postNotificationName:@"FailedPurchaseUpgrade" object:nil];

                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitSubscriptionExpiredNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      if(![[NSUserDefaults standardUserDefaults] boolForKey: @"StarglobeProForLife"]){
                                                          NSDate *expiryDate = [[MKStoreKit sharedKit] expiryDateForProduct:[[GeneralHelper sharedManager]purchaseID]];
                                                          
                                                          if (expiryDate != nil) {
                                                              if ([expiryDate compare:[NSDate date]] == NSOrderedDescending) {
                                                                  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"StarglobePro"];
                                                              }
                                                          }
                                                      }
                                                  }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kMKStoreKitProductsAvailableNotification
                                                      object:nil
                                                       queue:[[NSOperationQueue alloc] init]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      NSLog(@"Products available: %@", [[MKStoreKit sharedKit] availableProducts]);
                                                      if ([[MKStoreKit sharedKit] availableProducts].count > 0) {
                                                          SKProduct *product = [[[MKStoreKit sharedKit] availableProducts]objectAtIndex:0];
                                                          
                                                          NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                                                          [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                                                          [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                                                          [numberFormatter setLocale:product.priceLocale];
                                                          NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
                                                          if (formattedPrice != nil && formattedPrice.length > 0) {
                                                              [[NSUserDefaults standardUserDefaults] setObject:formattedPrice forKey:@"IAPPrice"];
                                                          }
                                                          
                                                      }
                                                  }];
        
    
    
    Branch *branch = [Branch getInstance];
    [branch initSessionWithLaunchOptions:launchOptions andRegisterDeepLinkHandler:^(NSDictionary *params, NSError *error) {
        if (!error && params) {
            if ([[params objectForKey:@"StarglobeProForLife"]isEqualToString:@"True"]) {
                if ([[params objectForKey:@"Provider"]isEqualToString:@"AppGratis"]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AppGratis"];
                } else if ([[params objectForKey:@"Provider"]isEqualToString:@"AppTurbo"]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AppTurbo"];
                }
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"StarglobeProForLife"];
            }
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
    NSLog(@"userInfo %@", userInfo);
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
    NSLog(@"userInfo %@", userInfo);
    
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

- (void)applicationDidEnterBackground:(UIApplication *)application{
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(void) applicationWillEnterForeground: (UIApplication*)application{
    if (mainViewController.lastContext) {
        [EAGLContext setCurrentContext:mainViewController.lastContext];
    }
    [glView startAnimation];
    [[SolarSystemViewController sharedInstance]restart];
}

-(void) applicationWillResignActive: (UIApplication*)application{
	[glView stopAnimation];
    [[SolarSystemViewController sharedInstance]cleanUp];
}

-(void) applicationDidBecomeActive: (UIApplication*)application{
    
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
    
    updateRotationMatrix(-attitude.rotationMatrix.m11, -attitude.rotationMatrix.m12, attitude.rotationMatrix.m13,
                         -attitude.rotationMatrix.m21, -attitude.rotationMatrix.m22, attitude.rotationMatrix.m23,
                         -attitude.rotationMatrix.m31, -attitude.rotationMatrix.m32, attitude.rotationMatrix.m33);
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



@end
