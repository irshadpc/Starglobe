//
//  star3mapAppDelegate.h
//  star3map
//
//  Created by Cass Everitt on 1/30/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MainViewController.h"
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>
#import <KiipSDK/KiipSDK.h>

@class EAGLView;

@interface star3mapAppDelegate : NSObject <UIApplicationDelegate, CLLocationManagerDelegate, UIAccelerometerDelegate, UIAlertViewDelegate, AVCaptureVideoDataOutputSampleBufferDelegate, KiipDelegate>
{
    EAGLView               * glView;
    CLLocationManager      * locationManager;
    IBOutlet UIWindow      * window;
    UINavigationController * navigationController;
    MainViewController     * mainViewController;
    CMMotionManager        * motionManager;
    AVCaptureSession       * session;
    CMAttitude             * referenceAttitude;
    BOOL                     gyroEnabled;
}

-(BOOL) gyroAvailable;
- (void)resetViews;
@end

