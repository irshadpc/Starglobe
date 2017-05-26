//
//  GeneralHelper.h
//  ProPlayer
//
//  Created by Alex on 07/05/16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralHelper : NSObject
+ (id)sharedManager;
- (BOOL)freeVersion;
- (NSString*)appstoreLink;
- (void)updatePrice;
- (UIImage *)imageWithColor:(UIColor *)color;
@end
