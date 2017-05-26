//
//  QuadEntity.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/1/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "QuadEntity.h"

@implementation QuadEntity

const GLuint QuadIndices[] = {
    0, 1, 2,
    2, 3, 0
};

- (id)initWithColor:(CC3Vector4)color
{
    return [self initWithColor1:color color2:color color3:color color4:color];
}

- (id)initWithColor1:(CC3Vector4)c1 color2:(CC3Vector4)c2 color3:(CC3Vector4)c3 color4:(CC3Vector4)c4
{
    if(self = [super init]) {
        
        NSLog(@"%@", NSStringFromCC3Vector4(c1));
        
        const Vertex QuadVertices[] = {
            {{-0.5f, -0.5f,  0.0f}, {c1.x, c1.y, c1.z, c1.w}, {0, 0}},
            {{ 0.5f, -0.5f,  0.0f}, {c2.x, c2.y, c2.z, c2.w}, {1, 0}},
            {{ 0.5f,  0.5f,  0.0f}, {c3.x, c3.y, c3.z, c3.w}, {1, 1}},
            {{-0.5f,  0.5f,  0.0f}, {c4.x, c4.y, c4.z, c4.w}, {0, 1}},
        };
        
        GLuint vb, ib;
        
        glGenBuffers(1, &vb);
        self.vertexBuffer = vb;
        glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(QuadVertices), QuadVertices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &ib);
        self.indexBuffer = ib;
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(QuadIndices), QuadIndices, GL_STATIC_DRAW);
        
        self.numberOfIndices = sizeof(QuadIndices) / sizeof(GLuint);
        self.indicesDataType = GL_UNSIGNED_INT;
        self.drawingMode = GL_TRIANGLES;
        
    }
    return self;
}

@end
