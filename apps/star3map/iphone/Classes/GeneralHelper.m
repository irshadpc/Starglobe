//
//  GeneralHelper.m
//  ProPlayer
//
//  Created by Alex on 07/05/16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import "GeneralHelper.h"
#import "UIAlertController+Window.h"

static GeneralHelper *sharedManager = nil;

@import Firebase;

@implementation GeneralHelper
#pragma mark Singleton Methods
+ (id) sharedManager{
    static dispatch_once_t pred;
    static GeneralHelper *sharedManager = nil;
    
    dispatch_once(&pred, ^{
        sharedManager = [[GeneralHelper alloc] init];
    });
    return sharedManager;
}

- (id) init{
    if (self = [super init]){
       
    }
    return self;
}

- (NSString*)appstoreLink{
#ifdef STARGLOBE_FREE
    return @"https://itunes.apple.com/us/app/starglobe-free-discover-stars-planets-galaxies-night/id703554364?mt=8&at=11lS6z";
#endif
    
#ifdef STARGLOBE_PRO
    return @"https://itunes.apple.com/us/app/starglobe-discover-stars-planets-galaxies-night-sky/id501980012?mt=8&uo=4";
#endif
    
   
}

- (NSString*)purchaseID{
#ifdef STARGLOBE_FREE
    return @"StarglobeProSubscription";
#endif
    
#ifdef STARGLOBE_PRO
    return @"StarglobeSubscription";
#endif
    
    return @"StarglobeProSubscription";
}

- (BOOL)freeVersion{
    //return NO;
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"StarglobeProForLife"]){
        return NO;
    }
    
    if([[NSUserDefaults standardUserDefaults] boolForKey: @"StarglobePro"]){
        return NO;
    }
    return YES;
}


- (NSString*)downloadsDirectory{
    NSString *documentDirectory = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *downloadsDirectory = [documentDirectory stringByAppendingPathComponent:@"Downloads"];
    BOOL isDir;
    NSError *error;
    if(![[NSFileManager defaultManager] fileExistsAtPath:downloadsDirectory isDirectory:&isDir]){
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    return downloadsDirectory;
}

- (NSString*)cachesDirectory{
    return NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
}

- (NSString*)customDownloadPath:(NSString*)fileName{
    NSString* extension = [fileName pathExtension];
    NSString *originalFullPath = [[self downloadsDirectory]stringByAppendingPathComponent:fileName];
    NSString *fullPath = [[self downloadsDirectory]stringByAppendingPathComponent:fileName];
    
    int counter = 1;
    while ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        if (extension != nil && ![extension isEqualToString:@""]) {
            fullPath = [[[originalFullPath stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"-%d", counter]]stringByAppendingPathExtension:[originalFullPath pathExtension]];
        } else {
            fullPath = [originalFullPath stringByAppendingString:[NSString stringWithFormat:@"-%d", counter]];
        }
        counter++;
    }
    return [fullPath lastPathComponent];
}

- (NSString*)customVideoDownloadPath:(NSString*)fileName{
    fileName = [fileName stringByDeletingPathExtension];
    fileName = [fileName stringByAppendingPathExtension:@"mp4"];
    NSString* extension = [fileName pathExtension];
    NSString *originalFullPath = [[self downloadsDirectory]stringByAppendingPathComponent:fileName];
    NSString *fullPath = [[self downloadsDirectory]stringByAppendingPathComponent:fileName];
    
    int counter = 1;
    while ([[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        if (extension != nil && ![extension isEqualToString:@""]) {
            fullPath = [[[originalFullPath stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"-%d", counter]]stringByAppendingPathExtension:[originalFullPath pathExtension]];
        } else {
            fullPath = [originalFullPath stringByAppendingString:[NSString stringWithFormat:@"-%d", counter]];
        }
        counter++;
    }
    return [fullPath lastPathComponent];
}


- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
