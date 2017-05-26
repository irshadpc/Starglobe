//
//  GSWorldData.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 7/16/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "GSWorldData.h"

#define BODY_JSON_FIELD_IDENTIFIER @"id"
#define BODY_JSON_FIELD_NAME @"name"
#define BODY_JSON_FIELD_PACKAGE @"package"
#define BODY_JSON_FIELD_TYPE @"type"
#define BODY_JSON_FIELD_ENABLED @"enabled"
#define BODY_JSON_FIELD_PARENT @"parent"
#define BODY_JSON_FIELD_RADIUS @"radius"
#define BODY_JSON_FIELD_PERIOD @"period"
#define BODY_JSON_FIELD_ORBIT_DISTANCE @"distance"
#define BODY_JSON_FIELD_TILT @"tilt"
#define BODY_JSON_FIELD_SPIN @"spin"
#define BODY_JSON_FIELD_TEXTURE @"texture"
#define BODY_JSON_FIELD_RINGS @"rings"
#define BODY_JSON_FIELD_GLOW @"glow"
#define BODY_JSON_FIELD_CLOUDS @"clouds"
#define BODY_JSON_FIELD_SCALE @"scale"

#define GLOW_JSON_FIELD_INNER_COLOR @"inner"
#define GLOW_JSON_FIELD_OUTER_COLOR @"outer"

#define RINGS_JSON_FIELD_INNER_RADIUS @"radius0"
#define RINGS_JSON_FIELD_OUTER_RADIUS @"radius1"
#define RINGS_JSON_FIELD_TEXTURE @"texture"
#define RINGS_JSON_FIELD_COLOR @"color"

#define CLOUDS_JSON_FIELD_TEXTURE @"texture"
#define CLOUDS_JSON_FIELD_SPIN @"spin"

CC3Vector getColorFromJSON(id json)
{
    if(!json) {
        return kCC3VectorZero;
    }
    
    NSArray *components = @[@0.0f];
    
    if([json isKindOfClass:[NSNumber class]]) {
        components = @[json];
    }else if([json isKindOfClass:[NSArray class]]) {
        components = json;
    }
    
    if(!components || components.count == 0) {
        return kCC3VectorZero;
    }
    
    CGFloat r = 0.0f, g = 0.0f, b = 0.0f;
    if(components.count == 1) {
        CGFloat val = [components.firstObject floatValue];
        r = val;
        g = val;
        b = val;
    }else if(components.count >= 3) {
        r = [components[0] floatValue];
        g = [components[1] floatValue];
        b = [components[2] floatValue];
    }
    
    return CC3VectorMake(r, g, b);
}

CGFloat getValueFromJSON(id jsonVal)
{
    if(!jsonVal) {
        return 0.0f;
    }
    
    if([jsonVal isKindOfClass:[NSArray class]]) {
        
        // Rereference it to an array
        NSArray *jsonValAry = (NSArray *)jsonVal;
        
        // Determine the scientific notation elements
        CGFloat base = 0.0f, exponent = 0.0f;
        if(jsonValAry.count > 0) {
            base = [[jsonValAry objectAtIndex:0] floatValue];
        }
        if(jsonValAry.count > 1) {
            exponent = [[jsonValAry objectAtIndex:1] floatValue];
        }
        
        // Return the scientific notation value
        return base * powf(10.0f, exponent);
        
    }
    
    // Try the default float value
    return [jsonVal floatValue];
}

BOOL getBoolFromJSON(id jsonVal)
{
    if(!jsonVal) {
        return NO;
    }
    return [jsonVal boolValue];
}

NSString* getTextureFromJSON(id jsonVal, NSInteger textureIndex)
{
    if(!jsonVal) {
        return nil;
    }
    NSArray *textures = nil;
    if([jsonVal isKindOfClass:[NSArray class]]) {
        textures = jsonVal;
    }else if([jsonVal isKindOfClass:[NSString class]]) {
        textures = @[jsonVal];
    }
    if(textureIndex < 0 || textureIndex >= textures.count) {
        return nil;
    }
    return [textures objectAtIndex:textureIndex];
}

BOOL jsonSectionIsEnabled(NSDictionary *json)
{
    if(!json) {
        return NO;
    }
    
    id boolVal = [json objectForKey:@"enabled"];
    
    // If not specified, default to enabled
    if(!boolVal) {
        return YES;
    }
    
    return [boolVal boolValue];
}

NSArray* getArrayFromColor(CC3Vector color)
{
    return @[@(color.x), @(color.y), @(color.z)];
}

id valueOrNull(id value)
{
    if(!value) {
        return DATA_NULL;
    }
    return value;
}

@implementation GSGlowData

- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super init]) {
        
        if(!json || !jsonSectionIsEnabled(json)) {
            self.enabled = NO;
            return self;
        }
        
        // Make the glow enabled
        self.enabled = YES;
        
        // Set the colors
        self.innerColor = getColorFromJSON([json objectForKey:GLOW_JSON_FIELD_INNER_COLOR]);
        self.outerColor = getColorFromJSON([json objectForKey:GLOW_JSON_FIELD_OUTER_COLOR]);
        
    }
    return self;
}

- (NSDictionary *)jsonValue
{
    return @{
             BODY_JSON_FIELD_ENABLED: valueOrNull(@(self.enabled)),
             GLOW_JSON_FIELD_INNER_COLOR: getArrayFromColor(self.innerColor),
             GLOW_JSON_FIELD_OUTER_COLOR: getArrayFromColor(self.outerColor)
             };
}

@end

@implementation GSCloudData

- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super init]) {
        
        if(!json || !jsonSectionIsEnabled(json)) {
            self.enabled = NO;
            return self;
        }
        
        self.enabled = YES;
        
        self.spin = getValueFromJSON([json objectForKey:CLOUDS_JSON_FIELD_SPIN]);
        self.texture0 = getTextureFromJSON([json objectForKey:CLOUDS_JSON_FIELD_TEXTURE], 0);
        self.texture1 = getTextureFromJSON([json objectForKey:CLOUDS_JSON_FIELD_TEXTURE], 1);
        
    }
    return self;
}

- (NSDictionary *)jsonValue
{
    NSMutableArray *textures = [NSMutableArray array];
    if(self.texture0) {
        [textures addObject:self.texture0];
    }
    if(self.texture1) {
        [textures addObject:self.texture1];
    }
    return @{
             BODY_JSON_FIELD_ENABLED: valueOrNull(@(self.enabled)),
             CLOUDS_JSON_FIELD_SPIN: valueOrNull([NSNumber numberWithFloat:self.spin]),
             CLOUDS_JSON_FIELD_TEXTURE: valueOrNull(textures)
             };
}

@end

@implementation GSRingData

- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super init]) {
        
        if(!json || !jsonSectionIsEnabled(json)) {
            self.enabled = NO;
            return self;
        }
        
        self.enabled = YES;
        
        self.innerRadius = getValueFromJSON([json objectForKey:RINGS_JSON_FIELD_INNER_RADIUS]);
        self.outerRadius = getValueFromJSON([json objectForKey:RINGS_JSON_FIELD_OUTER_RADIUS]);
        self.texture = getTextureFromJSON([json objectForKey:RINGS_JSON_FIELD_TEXTURE], 0);
        self.color = getColorFromJSON([json objectForKey:RINGS_JSON_FIELD_COLOR]);
        
    }
    return self;
}

- (NSDictionary *)jsonValue
{
    return @{
             BODY_JSON_FIELD_ENABLED: valueOrNull(@(self.enabled)),
             RINGS_JSON_FIELD_INNER_RADIUS: valueOrNull(@(self.innerRadius)),
             RINGS_JSON_FIELD_OUTER_RADIUS: valueOrNull(@(self.outerRadius)),
             RINGS_JSON_FIELD_TEXTURE: valueOrNull(self.texture),
             RINGS_JSON_FIELD_COLOR: valueOrNull(getArrayFromColor(self.color))
             };
}

@end

@implementation GSWorldData

- (id)init
{
    if(self = [super init]) {
        
        self.identifier = nil;
        self.name = nil;
        self.package = nil;
        self.type = nil;
        self.enabled = YES;
        self.parentIdentifier = nil;
        self.texture0 = nil;
        self.texture1 = nil;
        self.radius = 1.0f;
        self.orbitPeriod = 0.0f;
        self.distance = 0.0f;
        self.spin = 0.0f;
        self.tilt = 0.0f;
        self.scale = kCC3VectorUnitCube;
        
        self.glow = [[GSGlowData alloc] init];
        self.glow.innerColor = CC3VectorMake(1.0f, 1.0f, 1.0f);
        self.glow.outerColor = CC3VectorMake(1.0f, 1.0f, 1.0f);
        self.glow.enabled = NO;
        
        self.rings = [[GSRingData alloc] init];
        self.rings.innerRadius = 1.0f;
        self.rings.outerRadius = 2.0f;
        self.rings.color = CC3VectorMake(1.0f, 1.0f, 1.0f);
        self.rings.enabled = NO;
        self.rings.texture = nil;
        
        self.clouds = [[GSCloudData alloc] init];
        self.clouds.texture0 = nil;
        self.clouds.texture1 = nil;
        self.clouds.enabled = NO;
        self.clouds.spin = 0.0f;
        
    }
    return self;
}

- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super init]) {
        
        // Get the rest of the data from the array
        self.identifier = [json valueForKey:BODY_JSON_FIELD_IDENTIFIER];
        self.name = [json valueForKey:BODY_JSON_FIELD_NAME];
        self.package = [json valueForKey:BODY_JSON_FIELD_PACKAGE];
        self.type = [json valueForKey:BODY_JSON_FIELD_TYPE];
        self.enabled = jsonSectionIsEnabled(json);
        self.parentIdentifier = [json valueForKey:BODY_JSON_FIELD_PARENT];
        self.texture0 = getTextureFromJSON([json valueForKey:BODY_JSON_FIELD_TEXTURE], 0);
        self.texture1 = getTextureFromJSON([json valueForKey:BODY_JSON_FIELD_TEXTURE], 1);
        if([json objectForKey:BODY_JSON_FIELD_RADIUS]) {
            self.radius = getValueFromJSON([json objectForKey:BODY_JSON_FIELD_RADIUS]);
        }else{
            self.radius = 1.0f;
        }
        self.orbitPeriod = getValueFromJSON([json objectForKey:BODY_JSON_FIELD_PERIOD]);
        self.distance = getValueFromJSON([json objectForKey:BODY_JSON_FIELD_ORBIT_DISTANCE]);
        self.spin = getValueFromJSON([json objectForKey:BODY_JSON_FIELD_SPIN]);
        self.tilt = getValueFromJSON([json objectForKey:BODY_JSON_FIELD_TILT]);
        if([json objectForKey:BODY_JSON_FIELD_SCALE]) {
            self.scale = getColorFromJSON([json objectForKey:BODY_JSON_FIELD_SCALE]);
        }else{
            self.scale = CC3VectorMake(1.0f, 1.0f, 1.0f);
        }
        
        NSDictionary *worldClouds = [json objectForKey:BODY_JSON_FIELD_CLOUDS];
        NSDictionary *worldRings = [json objectForKey:BODY_JSON_FIELD_RINGS];
        NSDictionary *worldGlow = [json objectForKey:BODY_JSON_FIELD_GLOW];
        
        self.glow = [[GSGlowData alloc] initWithJson:worldGlow];
        self.rings = [[GSRingData alloc] initWithJson:worldRings];
        self.clouds = [[GSCloudData alloc] initWithJson:worldClouds];
        
        if([self.parentIdentifier isKindOfClass:[NSNull class]]) {
            self.parentIdentifier = nil;
        }
        
    }
    return self;
}

- (NSDictionary *)jsonValue
{
    NSMutableArray *textures = [NSMutableArray array];
    if(self.texture0) {
        [textures addObject:self.texture0];
    }
    if(self.texture1) {
        [textures addObject:self.texture1];
    }
    return @{
             BODY_JSON_FIELD_IDENTIFIER: valueOrNull(self.identifier),
             BODY_JSON_FIELD_NAME: valueOrNull(self.name),
             BODY_JSON_FIELD_PACKAGE: valueOrNull(self.package),
             BODY_JSON_FIELD_TYPE: valueOrNull(self.type),
             BODY_JSON_FIELD_ENABLED: valueOrNull(@(self.enabled)),
             BODY_JSON_FIELD_PARENT: valueOrNull(self.parentIdentifier),
             BODY_JSON_FIELD_TEXTURE: valueOrNull(textures),
             BODY_JSON_FIELD_RADIUS: valueOrNull(@(self.radius)),
             BODY_JSON_FIELD_PERIOD: valueOrNull(@(self.orbitPeriod)),
             BODY_JSON_FIELD_ORBIT_DISTANCE: valueOrNull(@(self.distance)),
             BODY_JSON_FIELD_SPIN: valueOrNull(@(self.spin)),
             BODY_JSON_FIELD_TILT: valueOrNull(@(self.tilt)),
             BODY_JSON_FIELD_CLOUDS: valueOrNull(self.clouds.jsonValue),
             BODY_JSON_FIELD_RINGS: valueOrNull(self.rings.jsonValue),
             BODY_JSON_FIELD_GLOW: valueOrNull(self.glow.jsonValue)
             };
}

@end
