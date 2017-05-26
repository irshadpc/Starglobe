//
//  SphereEntity.m
//  Orbit
//
//  Created by Conner Douglass on 2/14/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "SphereEntity.h"

#define CROSS_SECTIONAL_RADIUS(radius,heightFromCenter) (sqrtf(powf(radius,2.0f)-powf(heightFromCenter,2.0f)))
#define RADIUS_DEFAULT 1.0f

@interface SphereEntity ()

@end

@implementation SphereEntity

- (void)generateSphereWithSize:(GLuint)size color:(CC3Vector4)color
{
    Vertex vertices[(size + 1) * (size + 1)];
    GLuint indices[size * size * 6];
    
    GLuint vi = 0;
    GLuint ii = 0;
    
    for(GLuint yIndex = 0; yIndex <= size; yIndex++) {
        
        CGFloat pctFromBottom = (CGFloat)yIndex / (CGFloat)size;
        CGFloat coordY = pctFromBottom * 2.0f * RADIUS_DEFAULT - RADIUS_DEFAULT; // Ranges from -RADIUS_DEFAULT to +RADIUS_DEFAULT
        
        CGFloat crossRadius = CROSS_SECTIONAL_RADIUS(RADIUS_DEFAULT, coordY);
        
        for(GLuint thetaIndex = 0; thetaIndex <= size; thetaIndex++) {
            
            CGFloat thetaPct = (CGFloat)thetaIndex / (CGFloat)size;
            CGFloat theta = 2.0f * M_PI * thetaPct;
            CGFloat coordX = cosf(theta) * crossRadius;
            CGFloat coordZ = sinf(theta) * crossRadius;
            
            CGFloat tx = thetaPct;
            CGFloat ty = asinf(coordY) / M_PI + 0.5f;
            
            vertices[vi].Position[0] = coordX;
            vertices[vi].Position[1] = coordY;
            vertices[vi].Position[2] = coordZ;
            
            vertices[vi].Normal[0] = coordX / RADIUS_DEFAULT;
            vertices[vi].Normal[1] = coordY / RADIUS_DEFAULT;
            vertices[vi].Normal[2] = coordZ / RADIUS_DEFAULT;
            
            // NSLog(@"(%f, %f, %f)", coordX, coordY, coordZ);
            
            vertices[vi].TexCoord[0] = 1.0f - tx;
            vertices[vi].TexCoord[1] = 1.0f - ty;
            
            vertices[vi].Color[0] = color.x;
            vertices[vi].Color[1] = color.y;
            vertices[vi].Color[2] = color.z;
            vertices[vi].Color[3] = color.w;
            
            // NSLog(@"Point(%f, %f, %f)", coordX, coordY, coordZ);
            
            // CGFloat rad = sqrtf(powf(coordX, 2) + powf(coordY, 2) + powf(coordZ, 2));
            // NSLog(@"Rad: %f", rad);
            
            if(yIndex < size && thetaIndex < size) {
                
                GLuint bl = vi;
                GLuint br = bl + 1;
                GLuint tl = bl + size + 1;
                GLuint tr = br + size + 1;
                
                // NSLog(@"\r%i--------%i\r%i--------%i", tl, tr, bl, br);
                
                indices[ii++] = bl;
                indices[ii++] = br;
                indices[ii++] = tr;
                
                indices[ii++] = bl;
                indices[ii++] = tr;
                indices[ii++] = tl;
            }
            
            vi++;
            
        }
        
    }
    
    for(NSInteger i = 0; i < vi; i++) {
        // NSLog(@"%f, %f, %f", vertices[i].Position[0], vertices[i].Position[1], vertices[i].Position[2]);
    }
    
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

- (id)initWithSize:(GLuint)size
{
    return [self initWithSize:size color:CC3Vector4Make(1.0f, 1.0f, 1.0f, 1.0f)];
}

- (id)initWithSize:(GLuint)size color:(CC3Vector4)color
{
    if(self = [super init]) {
        
        [self generateSphereWithSize:size color:color];
        
    }
    return self;
}

@end
