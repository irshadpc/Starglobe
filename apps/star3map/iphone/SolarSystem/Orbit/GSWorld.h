//
//  GSWorld.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 7/20/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "Entity.h"

@interface GSWorld : Entity

// @property GSWorld *parent;

@property GSWorldData *data;

@property Entity *body;
@property RingEntity *rings;
// @property SphereEntity *clouds;

@property CGFloat orbitTheta;

+ (void)clearCacheForWorldWithIdentifier:(NSString *)identifier;
+ (GSWorld *)worldWithIdentifier:(NSString *)identifier;

- (void)updateOrbitPosition;

@end
