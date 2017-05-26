//
//  RingEntity.m
//  Kepler Explorer
//
//  Created by Conner Douglass on 2/17/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "RingEntity.h"

@implementation RingEntity

- (id)initWithSlices:(NSInteger)slices innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius
{
    return [self initWithSlices:slices innerRadius:innerRadius outerRadius:outerRadius color:cc3v(1.0f, 1.0f, 1.0f)];
}

- (id)initWithSlices:(NSInteger)slices innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius color:(CC3Vector)color
{
    if(self = [super init]) {
        
        [self generateRingWithSlices:(GLuint)slices innerRadius:innerRadius outerRadius:outerRadius color:color];
        
    }
    return self;
}

- (void)generateRingWithSlices:(GLuint)slices innerRadius:(CGFloat)innerRadius outerRadius:(CGFloat)outerRadius color:(CC3Vector)color
{
    GLuint indices[slices * 6];
    Vertex vertices[slices * 4];
    
    GLuint vi = 0;
    GLuint ii = 0;
    
    CGFloat thetaPerSlice = M_PI * 2.0f / (CGFloat)slices;
    
    for(GLuint slice = 0; slice < slices; slice++) {
        
        CGFloat theta1 = (slice) * thetaPerSlice;
        CGFloat theta2 = (slice + 1) * thetaPerSlice;
        
        CGFloat c1 = cosf(theta1);
        CGFloat s1 = sinf(theta1);
        
        CGFloat c2 = cosf(theta2);
        CGFloat s2 = sinf(theta2);
        
        vertices[vi].Position[0] = c1 * innerRadius;
        vertices[vi].Position[1] = 0.0f;
        vertices[vi].Position[2] = s1 * innerRadius;
        
        vertices[vi].Color[0] = color.x;
        vertices[vi].Color[1] = color.y;
        vertices[vi].Color[2] = color.z;
        vertices[vi].Color[3] = 1.0f;
        
        vertices[vi].TexCoord[0] = 1.0f;
        vertices[vi].TexCoord[1] = 0.0f;
        
        vertices[vi].Normal[0] = 0.0f;
        vertices[vi].Normal[1] = 1.0f;
        vertices[vi].Normal[2] = 0.0f;
        
        GLuint bl = vi;
        
        vi++;
        
        vertices[vi].Position[0] = c1 * outerRadius;
        vertices[vi].Position[1] = 0.0f;
        vertices[vi].Position[2] = s1 * outerRadius;
        
        vertices[vi].Color[0] = color.x;
        vertices[vi].Color[1] = color.y;
        vertices[vi].Color[2] = color.z;
        vertices[vi].Color[3] = 1.0f;
        
        vertices[vi].TexCoord[0] = 0.0f;
        vertices[vi].TexCoord[1] = 0.0f;
        
        vertices[vi].Normal[0] = 0.0f;
        vertices[vi].Normal[1] = 1.0f;
        vertices[vi].Normal[2] = 0.0f;
        
        GLuint tl = vi;
        
        vi++;
        
        vertices[vi].Position[0] = c2 * outerRadius;
        vertices[vi].Position[1] = 0.0f;
        vertices[vi].Position[2] = s2 * outerRadius;
        
        vertices[vi].Color[0] = color.x;
        vertices[vi].Color[1] = color.y;
        vertices[vi].Color[2] = color.z;
        vertices[vi].Color[3] = 1.0f;
        
        vertices[vi].TexCoord[0] = 0.0f;
        vertices[vi].TexCoord[1] = 1.0f;
        
        vertices[vi].Normal[0] = 0.0f;
        vertices[vi].Normal[1] = 1.0f;
        vertices[vi].Normal[2] = 0.0f;
        
        GLuint tr = vi;
        
        vi++;
        
        vertices[vi].Position[0] = c2 * innerRadius;
        vertices[vi].Position[1] = 0.0f;
        vertices[vi].Position[2] = s2 * innerRadius;
        
        vertices[vi].Color[0] = color.x;
        vertices[vi].Color[1] = color.y;
        vertices[vi].Color[2] = color.z;
        vertices[vi].Color[3] = 1.0f;
        
        vertices[vi].TexCoord[0] = 1.0f;
        vertices[vi].TexCoord[1] = 1.0f;
        
        vertices[vi].Normal[0] = 0.0f;
        vertices[vi].Normal[1] = 1.0f;
        vertices[vi].Normal[2] = 0.0f;
        
        GLuint br = vi;
        
        vi++;
        
        indices[ii++] = bl;
        indices[ii++] = br;
        indices[ii++] = tr;
        indices[ii++] = bl;
        indices[ii++] = tr;
        indices[ii++] = tl;
        
    }
    
    self.indicesDataType = GL_UNSIGNED_INT;
    
    GLuint vb, ib;
    
    glGenBuffers(1, &vb);
    self.vertexBuffer = vb;
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &ib);
    self.indexBuffer = ib;
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    self.numberOfIndices = ii;
}

@end
