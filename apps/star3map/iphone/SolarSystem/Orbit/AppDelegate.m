//
//  AppDelegate.m
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property OpenGLView *glView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    application.statusBarHidden = YES;
    self.window.rootViewController = [MainViewController sharedInstance];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [OpenGLView setAllViewsPaused:YES];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [OpenGLView setAllViewsPaused:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Get the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // Set the latest launched version integer
    [defaults setInteger:GALILEO_VERSION_MAJOR forKey:DEFAULTS_LATEST_LAUNCH_VERSION_KEY];
    
    // Increment the number of loads
    [defaults setInteger:(GALILEO_NUMBER_LAUNCHES + 1) forKey:DEFAULTS_NUMBER_LAUNCHES_KEY];
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAll;
}

@end
