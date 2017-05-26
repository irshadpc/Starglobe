//
//  SolarSystemScene.h
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "OpenGLScene.h"

#define ARRAY_TO_FLOAT(ary) ([ary count]==0?0.0f:([ary count]==1?[[ary firstObject] floatValue]:([[ary firstObject] floatValue] * powf(10.0f, [[ary lastObject] floatValue]))))
#define PACKAGE_BASE @"base"
#define PACKAGE_MOONS @"moons"
#define PACKAGE_DWARF_PLANETS @"dwarf-planets"
#define PACKAGE_USERWORLDS @"user"

@interface SolarSystemScene : OpenGLScene

@property CGFloat passageOfTime;
@property CGFloat focusDistanceFactor;
@property NSString *trackedBodyIdentifier;
@property UIPanGestureRecognizer *swipeGesture;
@property CC3Vector cameraAngularVelocity;

- (BOOL)containsPlanetWithIdentifier:(NSString *)identifier;
// - (void)fetchBodyWithIdentifier:(NSString *)bodyIdentifier completion:(void(^)(SphereEntity *planet))completion;
- (void)focusOnBodyWithIdentifier:(NSString *)identifier;

- (void)removeAllBodies;

@end
