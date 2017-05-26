//
//  GSWorldData.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 7/16/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATA_NULL [NSNull null]

@interface GSGlowData : NSObject

@property CC3Vector innerColor;
@property CC3Vector outerColor;
@property BOOL enabled;

- (id)initWithJson:(NSDictionary *)json;
- (NSDictionary *)jsonValue;

@end

@interface GSRingData : NSObject

@property CGFloat innerRadius;
@property CGFloat outerRadius;
@property NSString *texture;
@property CC3Vector color;
@property BOOL enabled;

- (id)initWithJson:(NSDictionary *)json;
- (NSDictionary *)jsonValue;

@end

@interface GSCloudData : NSObject

@property CGFloat spin;
@property NSString *texture0;
@property NSString *texture1;
@property BOOL enabled;

- (id)initWithJson:(NSDictionary *)json;
- (NSDictionary *)jsonValue;

@end

@interface GSWorldData : NSObject

@property NSString *identifier;
@property NSString *name;
@property NSString *package;
@property NSString *type;
@property NSString *parentIdentifier;
@property CGFloat radius;
@property CC3Vector scale;
@property CGFloat distance;
@property CGFloat spin;
@property CGFloat tilt;
@property CGFloat orbitPeriod;
@property NSString *texture0;
@property NSString *texture1;
@property BOOL enabled;

@property GSGlowData *glow;
@property GSCloudData *clouds;
@property GSRingData *rings;

- (id)initWithJson:(NSDictionary *)json;
- (NSDictionary *)jsonValue;

@end
