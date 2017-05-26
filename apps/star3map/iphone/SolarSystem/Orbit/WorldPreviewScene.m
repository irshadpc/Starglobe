//
//  WorldPreviewScene.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/4/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "WorldPreviewScene.h"

#define PREVIEW_DISTANCE 7.0f

@interface WorldPreviewScene ()

@property SphereEntity *clouds;
@property RingEntity *rings;

@end

@implementation WorldPreviewScene

- (id)init
{
    if(self = [super init]) {
        
        self.planet = [[SphereEntity alloc] initWithSize:48];
        self.planet.angularVelocity = cc3v(0.0f, 20.0f, 0.0f);
        self.planet.litBySun = YES;
        
        self.clouds = [[SphereEntity alloc] initWithSize:48];
        self.clouds.scale = cc3v(1.02f, 1.02f, 1.02f);
        self.clouds.litBySun = YES;
        self.clouds.enabled = NO;
        
        self.rings = [[RingEntity alloc] initWithSlices:48 innerRadius:1.2f outerRadius:2.4f];
        self.rings.litBySun = YES;
        self.rings.litBySunAbsoluteValue = YES;
        self.rings.enabled = NO;
        
        self.cameraRotation = cc3v(-20.0f, -30.0f, 0.0f);
        
    }
    return self;
}

- (void)render
{
    self.cameraPosition = CC3VectorScaleUniform(self.cameraFacingVector, -PREVIEW_DISTANCE);
    [super render];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint loc = [touch locationInView:self.view];
    CGPoint prevLoc = [touch previousLocationInView:self.view];
    
    CGFloat dx = loc.x - prevLoc.x;
    CGFloat dy = loc.y - prevLoc.y;
    
    if(touches.count == 1) {
        CC3Vector rot = self.cameraRotation;
        
        CGFloat dragSensitivity = 0.6f;
        
        CGFloat rotY = rot.y + dx * dragSensitivity;
        CGFloat rotX = rot.x - dy * dragSensitivity;
        
        rotX = CLAMP(rotX, -90.0f, 90.0f);
        
        self.cameraRotation = CC3VectorMake(rotX, rotY, rot.z);
        
    }
}

- (void)setCloudsEnabled:(BOOL)enabled
{
    self.clouds.enabled = enabled;
}

- (void)setRingsEnabled:(BOOL)enabled
{
    self.rings.enabled = enabled;
    self.rings.usesExplicitColor = enabled;
}

- (void)setPlanetTexture:(Texture *)texture
{
    [self.planet removeAllTextures];
    [self.planet addTexture:texture];
}

- (void)setRingTexture:(Texture *)texture
{
    [self.rings removeAllTextures];
    [self.rings addTexture:texture];
}

- (void)setCloudTexture:(Texture *)texture
{
    [self.clouds removeAllTextures];
    [self.clouds addTexture:texture];
}

- (void)setAxisTilt:(CGFloat)tilt
{
    self.planet.rotation = cc3v(tilt, self.planet.rotation.y, self.planet.rotation.z);
}

- (void)setRingColor:(CC3Vector4)color
{
    self.rings.color = color;
}

- (void)didBecomeActive
{
    SphereEntity *spaceBg = [[SphereEntity alloc] initWithSize:10];
    spaceBg.litBySun = NO;
    CGFloat spaceBgScale = 100.0f;
    spaceBg.scale = cc3v(spaceBgScale, spaceBgScale, spaceBgScale);
    spaceBg.position = cc3v(0.0f, 0.0f, 0.0f);
    
    Texture *spaceTexture = [[Texture alloc] initWithImageNamed:@"star-map.jpg" inView:self.view];
    [spaceBg addTexture:spaceTexture];
    [self addEntity:spaceBg];
    
    [self.planet addEntity:self.clouds];
    [self.planet addEntity:self.rings];
    [self addEntity:self.planet];
}

@end
