//
//  MainViewController.h
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <CoreMotion/CoreMotion.h>

@interface SolarSystemViewController : UIViewController {
    EAGLContext *lastContext;
}

+ (SolarSystemViewController *)sharedInstance;

- (void)reloadAvailableWorlds;

@property (nonatomic, strong) EAGLContext *lastContext;

@end
