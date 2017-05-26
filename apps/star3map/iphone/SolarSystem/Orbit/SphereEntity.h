//
//  SphereEntity.h
//  Orbit
//
//  Created by Conner Douglass on 2/14/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "Entity.h"

@interface SphereEntity : Entity

- (id)initWithSize:(GLuint)size;
- (id)initWithSize:(GLuint)size color:(CC3Vector4)color;

@end
