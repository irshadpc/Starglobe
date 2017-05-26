//
//  AppSettings.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/27/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppSettings : NSObject

+ (BOOL)gyroEnabled;
+ (void)saveGyroEnabled:(BOOL)enabled;

+ (BOOL)dynamicLightingEnabled;
+ (void)saveDynamicLightingEnabled:(BOOL)enabled;

+ (void)saveGlowEnabled:(BOOL)enabled;
+ (BOOL)glowEnabled;

+ (void)saveCloudsEnabled:(BOOL)enabled;
+ (BOOL)cloudsEnabled;

@end
