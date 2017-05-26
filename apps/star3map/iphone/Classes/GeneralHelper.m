//
//  GeneralHelper.m
//  ProPlayer
//
//  Created by Alex on 07/05/16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import "GeneralHelper.h"
#import "IAPManager.h"
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

- (BOOL)freeVersion{
#ifdef PROPLAYER_PRO
    return NO;
#endif
#ifdef PROPLAYER_FREE
    return YES;
#endif
    return YES;
}

- (NSString*)appstoreLink{
    if ([self freeVersion]) {
        return @"https://itunes.apple.com/us/app/starglobe-free-discover-stars-planets-galaxies-night/id703554364?mt=8&at=11lS6z";
    }
    return @"https://itunes.apple.com/us/app/starglobe-discover-stars-planets-galaxies-night-sky/id501980012?mt=8&at=11lS6z";
}


- (void)updatePrice{
#ifdef STARGLOBE_FREE
    if ([[[NSUserDefaults standardUserDefaults]valueForKey:@"IAPPrice"] isEqualToString:@""]) {
        [[IAPManager sharedIAPManager] getProductsForIds:@[@"starglobe.pro"]
                                              completion:^(NSArray *products) {
                                                  BOOL hasProducts = [products count] != 0;
                                                  if(hasProducts) {
                                                      SKProduct *premium = products[0];
                                                      
                                                      NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];                                                                                                                 [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
                                                      [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
                                                      [numberFormatter setLocale:premium.priceLocale];
                                                      NSString *formattedPrice = [numberFormatter stringFromNumber:premium.price];
                                                      [[NSUserDefaults standardUserDefaults] setValue:formattedPrice forKey:@"IAPPrice"];
                                                  }
                                              } error:^(NSError *error) {
                                                  
                                              }];
    }
    
#endif
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

- (void)handlePasteboardString:(NSString *)pasteBoardString{
  /*  NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [detect matchesInString:pasteBoardString options:0 range:NSMakeRange(0, [pasteBoardString length])];
    if (matches.count > 0) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"New Database" message:@"Would you like to import your new database and replace the existing one?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Replace Database", nil) style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       NSString *stringURL = [matches objectAtIndex:0];
                                                       NSURL *url = [NSURL URLWithString:stringURL];
                                                       NSString *path = [url path];
                                                       NSString *extension = [path pathExtension];
                                                       if (extension != nil && ![extension isEqualToString:@""]) {
                                                           
                                                       }
                                                   }];
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alert addAction:cancel];
        [alert addAction:ok];
        [alert show];
    }
    
    */
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
