//
//  SolarSystemScene.m
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "SolarSystemScene.h"

typedef enum {
    SolarSystemSceneModeCurrent,
    SolarSystemSceneModeComparison
} SolarSystemSceneMode;

@interface SolarSystemScene ()

@property NSMutableArray *bodies;
@property CGFloat currentDistanceFromOrigin;
@property SphereEntity *spaceBg;
@property SolarSystemSceneMode mode;

@property BOOL focusedOnParent;

@property CGPoint mostRecentTranslation;

@end

@implementation SolarSystemScene

- (Texture *)textureWithImageNamed:(NSString *)name
{
    NSString *prefix = @"docs:";
    
    if([name hasPrefix:prefix]) {
        NSString *nameShort = [name substringFromIndex:prefix.length];
        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *filePath = [docs stringByAppendingPathComponent:nameShort];
        UIImage *img = [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
        return [[Texture alloc] initWithImage:img inView:self.view];
    }
    
    return [[Texture alloc] initWithImageNamed:name inView:self.view];
}

- (id)init
{
    if(self = [super init]) {
        self.bodies = [NSMutableArray array];
        self.trackedBodyIdentifier = nil;
        self.focusedOnParent = NO;
        self.focusDistanceFactor = 5.0f;
        self.cameraAngularVelocity = CC3VectorMake(0.0f, 0.0f, 0.0f);
        
        self.swipeGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeFinger:)];
        self.swipeGesture.maximumNumberOfTouches = 1;
        self.swipeGesture.minimumNumberOfTouches = 1;
        
        self.scale = 1000.0f;
    }
    return self;
}

- (void)didTapScene:(UITapGestureRecognizer *)tap
{
    self.focusedOnParent = YES;
}

- (void)didBecomeActive
{
    const CGFloat colorVal = 0.3f;
    
    self.spaceBg = [[SphereEntity alloc] initWithSize:10 color:CC3Vector4Make(colorVal, colorVal, colorVal, 1.0f)];
    self.spaceBg.litBySun = NO;
    self.spaceBg.scale = CC3VectorScaleUniform(kCC3VectorUnitCube, self.renderDistance / 2.0f);
    
    Texture *backgroundTexture = [[Texture alloc] initWithImageNamed:@"star-map.jpg" inView:self.view scaledDown:NO];
    [self.spaceBg addTexture:backgroundTexture];
    
    [self addEntity:self.spaceBg];
    
    [self.view addGestureRecognizer:self.swipeGesture];
    
}

- (void)addEntity:(Entity *)entity
{
    [super addEntity:entity];
    if([entity isKindOfClass:[GSWorld class]]) {
        [self.bodies addObject:entity];
    }
}

- (BOOL)planetHasRings:(GSWorld *)planet
{
    for(Entity *entity in planet.entities) {
        if([entity isKindOfClass:[RingEntity class]]) {
            return YES;
        }
    }
    return NO;
}

- (void)removeAllBodies
{
    for(GSWorld *body in self.bodies) {
        [self removeEntity:body];
    }
}

- (void)didSwipeFinger:(UIPanGestureRecognizer *)pan
{
    // Only do this if the gyro feature is off
    if(![AppSettings gyroEnabled]) {
        
        CGPoint trans = [pan translationInView:self.view];
        
        if(pan.state == UIGestureRecognizerStateBegan) {
            self.mostRecentTranslation = trans;
        }
        
        CGFloat dx = trans.x - self.mostRecentTranslation.x;
        CGFloat dy = trans.y - self.mostRecentTranslation.y;
        
        static const CGFloat dragSensitivityX = 0.4f;
        static const CGFloat dragSensitivityY = 0.2f;
        
        CGFloat rotY = self.cameraRotation.y + dx * dragSensitivityX;
        CGFloat rotX = self.cameraRotation.x - dy * dragSensitivityY;
        
        rotX = CLAMP(rotX, -90.0f, 90.0f);
        
        self.focusedOnParent = NO;
        
        if(pan.state == UIGestureRecognizerStateEnded) {
            
            CGPoint vel = [pan velocityInView:self.view];
            self.cameraAngularVelocity = CC3VectorMake(-vel.y * dragSensitivityY, vel.x * dragSensitivityX, 0.0f);
        }
        
        self.cameraRotation = CC3VectorMake(rotX, rotY, self.cameraRotation.z);
        self.mostRecentTranslation = trans;
    }
}

- (BOOL)containsPlanetWithIdentifier:(NSString *)identifier
{
    for(GSWorld *e in self.bodies) {
        if([e.data.identifier isEqualToString:identifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)focusOnBodyWithIdentifier:(NSString *)identifier
{
    [self removeAllBodies];
    self.trackedBodyIdentifier = identifier;
    
    return;
    
    [WorldDataManager fetchParentIdentifierOfIdentifier:self.trackedBodyIdentifier completion:^(NSString *parentIdentifier) {
        
        if(parentIdentifier) {
            self.focusedOnParent = YES;
        }
        
    }];
}

- (void)transitionToZeroForKey:(NSString *)key
{
    [self transitionShadowsValueTo:0.0f forKey:key];
}

- (void)transitionToOneForKey:(NSString *)key
{
    [self transitionShadowsValueTo:1.0f forKey:key];
}

- (void)transitionShadowsValueTo:(CGFloat)targetValue forKey:(NSString *)key
{
    const CGFloat duration = 0.5f;
    
    const CGFloat pctPerSecond = 1.0f / duration;
    
    const CGFloat shadowsValueStarting = [[self valueForKeyPath:key] floatValue];
    
    CGFloat percent = 0.0f;
    
    CFTimeInterval previousTime = CACurrentMediaTime();
    
    while(percent < 0.995f) {
        
        CFTimeInterval currentTime = CACurrentMediaTime();
        CGFloat dt = currentTime - previousTime;
        previousTime = currentTime;
        
        percent += pctPerSecond * dt;
        
        CGFloat shadowVal = shadowsValueStarting + (targetValue - shadowsValueStarting) * percent;
        
        [self setValue:@(shadowVal) forKeyPath:key];
        
    }
    
    [self setValue:@(targetValue) forKeyPath:key];
}

- (void)checkKey:(NSString *)key forNeedToChangeInRangeMin:(CGFloat)min max:(CGFloat)max givenEnabled:(BOOL)enabled
{
    const CGFloat padding = 0.025f;
    
    CGFloat value = [[self valueForKeyPath:key] floatValue];
    
    if(value > (max - padding) && !enabled) {
        
        [self setValue:@(max - (padding * 2.0f)) forKeyPath:key];
        [self performSelectorInBackground:@selector(transitionToZeroForKey:) withObject:key];
        
    }else if(value < padding && enabled) {
        
        [self setValue:@(min + (padding * 2.0f)) forKeyPath:key];
        [self performSelectorInBackground:@selector(transitionToOneForKey:) withObject:key];
        
    }
}

- (void)update:(CGFloat)dt
{
    [super update:(dt * self.passageOfTime)];
    
    [self checkKey:@"shadowsValue" forNeedToChangeInRangeMin:0.0f max:1.0f givenEnabled:[AppSettings dynamicLightingEnabled]];
    [self checkKey:@"glowValue" forNeedToChangeInRangeMin:0.0f max:1.0f givenEnabled:[AppSettings glowEnabled]];
    [self checkKey:@"cloudsValue" forNeedToChangeInRangeMin:0.0f max:1.0f givenEnabled:[AppSettings cloudsEnabled]];
    
    // Begin inertial panning code
    self.cameraRotation = CC3VectorAdd(self.cameraRotation, CC3VectorScaleUniform(self.cameraAngularVelocity, dt));
    if(self.cameraRotation.x > 90.0f || self.cameraRotation.x < -90.0f) {
        self.cameraAngularVelocity = CC3VectorMake(-0.2f * self.cameraAngularVelocity.x,
                                                   self.cameraAngularVelocity.y,
                                                   self.cameraAngularVelocity.z);
    }
    self.cameraRotation = CC3VectorMake(CLAMP(self.cameraRotation.x, -90.0f, 90.0f),
                                        self.cameraRotation.y,
                                        self.cameraRotation.z);
    if(CC3VectorLength(self.cameraAngularVelocity) > 1.0f) {
        self.cameraAngularVelocity = CC3VectorDifference(self.cameraAngularVelocity, CC3VectorScaleUniform(self.cameraAngularVelocity, 4.0f * dt));
    }else{
        self.cameraAngularVelocity = kCC3VectorZero;
    }
    // End inertial panning code
    
    [self trackBody:(dt * self.passageOfTime)];
}

- (void)trackBody:(CGFloat)dt
{
    
    if(self.trackedBodyIdentifier) {
        
        GSWorld *trackedWorld = [GSWorld worldWithIdentifier:self.trackedBodyIdentifier];
        [self addEntity:trackedWorld];
        
        // Put the tracked body at the origin
        trackedWorld.position = cc3v(0.0f, 0.0f, 0.0f);
        trackedWorld.velocity = cc3v(0.0f, 0.0f, 0.0f);
        
        // If the parent is present
        if(trackedWorld.data.parentIdentifier) {
            
            // Calculate motion and update position of the parent
            CGFloat deltaTheta = dt / trackedWorld.data.orbitPeriod * M_PI * 2.0f;
            trackedWorld.orbitTheta -= deltaTheta;
            
            // Get the parent
            GSWorld *trackedParent = [GSWorld worldWithIdentifier:trackedWorld.data.parentIdentifier];
            
            // Add the parent if needed
            [self addEntity:trackedParent];
            
            // If the option to focus on the parent is ON
            if(self.focusedOnParent) {
                CGFloat rotX = -10.0f * (1.0f - self.focusDistanceFactor / 100.0f);
                CC3Vector bodyToParent = CC3VectorDifference(trackedParent.position, trackedWorld.position);
                CGFloat rotY = 90.0f + RadiansToDegrees(atan2f(bodyToParent.z, bodyToParent.x));
                CGFloat rotZ = 0.0f;
                self.cameraRotation = cc3v(rotX, rotY, rotZ);
                if([AppSettings gyroEnabled]) {
                    self.focusedOnParent = NO;
                }
            }
            
            [trackedWorld updateOrbitPosition];
        }
        
        // Get the JSON data for the coolest of the friends to be shown
        NSArray *importantFriends = [WorldDataManager jsonForPeersOfIdentifier:self.trackedBodyIdentifier];
        
        // Loop through each friend's JSON data
        for(NSDictionary *friendJson in importantFriends) {
            
            GSWorldData *friendData = [[GSWorldData alloc] initWithJson:friendJson];
            
            // Find the orbital radius relative to parent
            CGFloat orbitRadius = friendData.distance;
            
            GSWorld *friendEntity = [GSWorld worldWithIdentifier:friendData.identifier];
            
            // Calculate the change in theta necessary to keep motion
            friendEntity.orbitTheta -= dt / friendData.orbitPeriod * 2.0f * M_PI;
            
            // Get the parent
            GSWorld *trackedParent = [GSWorld worldWithIdentifier:friendEntity.data.parentIdentifier];
            
            // Update the position of the entity
            friendEntity.position = CC3VectorAdd(trackedParent.position, cc3v(orbitRadius * cosf(friendEntity.orbitTheta), 0.0f, orbitRadius * sinf(friendEntity.orbitTheta)));
            
            // Add the friend to the scene if it isn't already there
            [self addEntity:friendEntity];
            
            [friendEntity updateOrbitPosition];
            
        }
        
        // Make the camera lock onto the target
        CC3Vector dp = CC3VectorScaleUniform(self.cameraFacingVector, -trackedWorld.data.radius * self.focusDistanceFactor);
        self.cameraPosition = CC3VectorAdd(trackedWorld.position, dp);
        
        [self removeEntity:trackedWorld];
        [self addEntity:trackedWorld];
        
    }
    self.spaceBg.position = self.cameraPosition;
}

@end
