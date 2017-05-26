//
//  RingEntity.h
//  Kepler Explorer
//
//  Created by Conner Douglass on 2/17/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "Entity.h"

@interface RingEntity : Entity

- (id)initWithSlices:(NSInteger)slices innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius;
- (id)initWithSlices:(NSInteger)slices innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius color:(CC3Vector)color;

@end
