//
//  AppSettings.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/27/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "AppSettings.h"

#define SETTINGS_GYRO_KEY @"uses-gyro"
#define SETTINGS_DYNAMIC_LIGHTING_KEY @"uses-plain-lighting"
#define SETTINGS_GLOW_KEY @"uses-no-glow"
#define SETTINGS_CLOUDS_KEY @"clouds-disabled"

@implementation AppSettings

+ (NSUserDefaults *)defaults
{
    return [NSUserDefaults standardUserDefaults];
}

+ (BOOL)gyroEnabled
{
    return [[self defaults] boolForKey:SETTINGS_GYRO_KEY];
}

+ (void)saveGyroEnabled:(BOOL)enabled
{
    [[self defaults] setBool:enabled forKey:SETTINGS_GYRO_KEY];
}

+ (BOOL)dynamicLightingEnabled
{
    return ![[self defaults] boolForKey:SETTINGS_DYNAMIC_LIGHTING_KEY];
}

+ (void)saveDynamicLightingEnabled:(BOOL)enabled
{
    [[self defaults] setBool:!enabled forKey:SETTINGS_DYNAMIC_LIGHTING_KEY];
}

+ (BOOL)glowEnabled
{
    return ![[self defaults] boolForKey:SETTINGS_GLOW_KEY];
}

+ (void)saveGlowEnabled:(BOOL)enabled
{
    [[self defaults] setBool:!enabled forKey:SETTINGS_GLOW_KEY];
}

+ (BOOL)cloudsEnabled
{
    return ![[self defaults] boolForKey:SETTINGS_CLOUDS_KEY];
}

+ (void)saveCloudsEnabled:(BOOL)enabled
{
    [[self defaults] setBool:!enabled forKey:SETTINGS_CLOUDS_KEY];
}

@end
