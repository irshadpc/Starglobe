//
//  QuadEntity.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/1/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "Entity.h"

@interface QuadEntity : Entity

- (id)initWithColor:(CC3Vector4)color;
- (id)initWithColor1:(CC3Vector4)c1 color2:(CC3Vector4)c2 color3:(CC3Vector4)c3 color4:(CC3Vector4)c4;

@end
