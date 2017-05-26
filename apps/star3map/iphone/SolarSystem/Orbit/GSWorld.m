//
//  GSWorld.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 7/20/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "GSWorld.h"

@implementation GSWorld

static NSMutableArray *allWorlds = nil;

+ (void)clearCacheForWorldWithIdentifier:(NSString *)identifier
{
    GSWorld *idWorld = nil;
    
    for(GSWorld *world in allWorlds) {
        if([world.data.identifier isEqualToString:identifier]) {
            
            idWorld = world;
            break;
            
        }
    }
    
    if(!idWorld) {
        return;
    }
    
    [allWorlds removeObject:idWorld];
}

+ (GSWorld *)worldWithIdentifier:(NSString *)identifier
{
    if(!allWorlds) {
        allWorlds = [NSMutableArray array];
    }
    
    for(GSWorld *world in allWorlds) {
        if([world.data.identifier isEqualToString:identifier]) {
            return world;
        }
    }
    
    GSWorld *world = [self createWorldWithIdentifier:identifier];
    [allWorlds addObject:world];
    
    return world;
}

+ (GSWorld *)createWorldWithIdentifier:(NSString *)identifier
{
    return [[GSWorld alloc] initWithIdentifier:identifier];
}

- (id)initWithIdentifier:(NSString *)identifier
{
    NSDictionary *json = [WorldDataManager jsonForBodyWithIdentifier:identifier];
    return [self initWithJSON:json];
}

- (id)initWithJSON:(NSDictionary *)json
{
    if(self = [super init]) {
        
        self.data = [[GSWorldData alloc] initWithJson:json];
        [self createWorld];
        
    }
    return self;
}

- (void)createWorld
{
    // Save some properties
    self.orbitTheta = RAND_0_1 * M_PI * 2.0f;
    self.rotation = CC3VectorMake(self.data.tilt, self.rotation.y, self.rotation.z);
    self.angularVelocity = CC3VectorMake(self.angularVelocity.x, self.data.spin, self.angularVelocity.z);
    self.scale = CC3VectorScaleUniform(self.data.scale, self.data.radius);
    
    // Create the sphere
    self.body = [[SphereEntity alloc] initWithSize:64];
    
    [self addEntity:self.body];
    
    // If the world is the moon, correct the rotation to be properly tidally locked.
    // We only do this because people will recognize the near side of the moon from the far side
    if([self.data.type isEqualToString:@"moon"]) {
        self.rotation = CC3VectorMake(self.rotation.x, RadiansToDegrees(self.orbitTheta), self.rotation.z);
    }
    
    // Tidally lock moons
    if([self.data.type isEqualToString:@"moon"] && self.data.parentIdentifier) {
        
        // Get the parent entity
        // self.parent = [GSWorld worldWithIdentifier:self.data.parentIdentifier];
            
        // If there is a parent entity
        // if(self.parent) {
            
            // Calculate the angular velocity
            self.angularVelocity = CC3VectorMake(self.angularVelocity.x, 360.0f / self.data.orbitPeriod, self.angularVelocity.z);
            
        // }
        
    }
    
    // Add the textures
    if(self.data.texture0) {
        [self.body addTexture:[[Texture alloc] initWithImageNamed:self.data.texture0]];
    }
    if(self.data.texture1) {
        [self.body addTexture:[[Texture alloc] initWithImageNamed:self.data.texture1]];
    }
    
    // Make the glow
    self.body.atmosphereGlowEnabled = self.data.glow.enabled;
    self.body.atmosphereGlowInnerColor = self.data.glow.innerColor;
    self.body.atmosphereGlowOuterColor = self.data.glow.outerColor;
    
    // Setup rings
    if(self.data.rings.enabled) {
        
        // Tell OpenGL to render this world after the rest of the scene
        self.hasTransparency = YES;
        
        // Divide by two at the end of the dimensions below to compensate for the fact that the radius is 0.5f, not 1.0f, and the
        // provided values from the JSON are based on 1.0f
        self.rings = [[RingEntity alloc] initWithSlices:100 innerRadius:self.data.rings.innerRadius outerRadius:self.data.rings.outerRadius];
        
        // Get the texture name
        [self.rings addTexture:[[Texture alloc] initWithImageNamed:self.data.rings.texture]];
        
        self.rings.hasTransparency = YES;
        self.rings.litBySun = YES;
        self.rings.litBySunAbsoluteValue = YES;
        
        self.rings.color = CC3Vector4Make(self.data.rings.color.x, self.data.rings.color.y, self.data.rings.color.z, 1.0f);
        self.rings.usesExplicitColor = YES;
        
        [self addEntity:self.rings];
    }
    
    // Setup the clouds
    if(self.data.clouds.enabled) {
        
        self.body.overlayTexture = [[Texture alloc] initWithImageNamed:self.data.clouds.texture0];
        
        /*
        // Give the world transparence just like for rings
        self.hasTransparency = YES;
         
        // Create a sphere
        self.clouds = [[SphereEntity alloc] initWithSize:32 color:CC3Vector4Make(1.0f, 1.0f, 1.0f, 0.8f)];
        
        // Add textures
        if(self.data.clouds.texture0) {
            [self.clouds addTexture:[[Texture alloc] initWithImageNamed:self.data.clouds.texture0]];
        }
        if(self.data.clouds.texture1) {
            [self.clouds addTexture:[[Texture alloc] initWithImageNamed:self.data.clouds.texture1]];
        }
        
        // Set other properties
        self.clouds.angularVelocity = CC3VectorMake(self.clouds.angularVelocity.x, self.data.clouds.spin, self.clouds.angularVelocity.z);
        static const CGFloat cloudScale = 1.02f;
        self.clouds.scale = cc3v(cloudScale, cloudScale, cloudScale);
        self.clouds.hasTransparency = YES;
        self.clouds.litBySun = YES;
        
        [self addEntity:self.clouds];
         */
    }
}

- (void)updateOrbitPosition
{
    if(!self.data.parentIdentifier) {
        self.position = CC3VectorMake(0.0f, 0.0f, 0.0f);
        return;
    }
    
    GSWorld *trackedParent = [GSWorld worldWithIdentifier:self.data.parentIdentifier];
    
    CGFloat relPosX = self.data.distance * cosf(self.orbitTheta);
    CGFloat relPosY = 0.0f;
    CGFloat relPosZ = self.data.distance * sinf(self.orbitTheta);
    
    CC3Vector relPos = CC3VectorMake(relPosX, relPosY, relPosZ);
    
    CGFloat tilt = DegreesToRadians(trackedParent.data.tilt);
    
    CGFloat yPrime = relPos.y * cosf(tilt) - relPos.z * sinf(tilt);
    CGFloat zPrime = relPos.y * sinf(tilt) + relPos.z * cosf(tilt);
    CGFloat xPrime = relPos.x;
    
    relPos = CC3VectorMake(xPrime, yPrime, zPrime);
    
    self.position = CC3VectorAdd(trackedParent.position, relPos);
    self.rotation = CC3VectorMake(self.data.tilt + trackedParent.data.tilt, self.rotation.y, self.rotation.z);
}

- (void)update:(CGFloat)dt
{
    [super update:dt];
    
    self.body.overlayTextureOffsetX += self.data.clouds.spin * dt / 360.0f;
}

@end
