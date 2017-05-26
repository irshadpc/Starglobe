//
//  Network.h
//  star3map
//
//  Created by Dmitry Fadeev on 13.01.12.
//  Copyright (c) 2012 knightmare@ether-engine.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Network : NSObject

+(BOOL) connectionAvailable;
+(void) showUnavailableMessage: (NSString*)message;

@end
