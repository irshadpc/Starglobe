//
//  CubeEntity.m
//  Orbit
//
//  Created by Conner Douglass on 2/11/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "CubeEntity.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

const Vertex CubeVertices[] = {
    // Front
    {{ 0.5f, -0.5f,  0.5f}, {1, 0, 0, 1}, {1, 0}},
    {{ 0.5f,  0.5f,  0.5f}, {1, 0, 0, 1}, {1, 1}},
    {{-0.5f,  0.5f,  0.5f}, {1, 0, 0, 1}, {0, 1}},
    {{-0.5f, -0.5f,  0.5f}, {1, 0, 0, 1}, {0, 0}},
    // Back
    {{ 0.5f,  0.5f, -0.5f}, {1, 0, 0, 1}, {1, 0}},
    {{-0.5f, -0.5f, -0.5f}, {1, 0, 0, 1}, {1, 1}},
    {{ 0.5f, -0.5f, -0.5f}, {1, 0, 0, 1}, {0, 1}},
    {{-0.5f,  0.5f, -0.5f}, {1, 0, 0, 1}, {0, 0}},
    // Left
    {{-0.5f, -0.5f,  0.5f}, {0, 1, 0, 1}, {1, 0}},
    {{-0.5f,  0.5f,  0.5f}, {0, 1, 0, 1}, {1, 1}},
    {{-0.5f,  0.5f, -0.5f}, {0, 1, 0, 1}, {0, 1}},
    {{-0.5f, -0.5f, -0.5f}, {0, 1, 0, 1}, {0, 0}},
    // Right
    {{ 0.5f, -0.5f, -0.5f}, {0, 1, 0, 1}, {1, 0}},
    {{ 0.5f,  0.5f, -0.5f}, {0, 1, 0, 1}, {1, 1}},
    {{ 0.5f,  0.5f,  0.5f}, {0, 1, 0, 1}, {0, 1}},
    {{ 0.5f, -0.5f,  0.5f}, {0, 1, 0, 1}, {0, 0}},
    // Top
    {{ 0.5f,  0.5f,  0.5f}, {0, 0, 1, 1}, {1, 0}},
    {{ 0.5f,  0.5f, -0.5f}, {0, 0, 1, 1}, {1, 1}},
    {{-0.5f,  0.5f, -0.5f}, {0, 0, 1, 1}, {0, 1}},
    {{-0.5f,  0.5f,  0.5f}, {0, 0, 1, 1}, {0, 0}},
    // Bottom
    {{ 0.5f, -0.5f, -0.5f}, {0, 0, 1, 1}, {1, 0}},
    {{ 0.5f, -0.5f,  0.5f}, {0, 0, 1, 1}, {1, 1}},
    {{-0.5f, -0.5f,  0.5f}, {0, 0, 1, 1}, {0, 1}},
    {{-0.5f, -0.5f, -0.5f}, {0, 0, 1, 1}, {0, 0}}
};

const GLuint CubeIndices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    6, 5, 7,
    6, 7, 4,
    // Left
    8, 9, 10,
    10, 11, 8,
    // Right
    12, 13, 14,
    14, 15, 12,
    // Top
    16, 17, 18,
    18, 19, 16,
    // Bottom
    20, 21, 22,
    22, 23, 20
};

@interface CubeEntity ()

@end

@implementation CubeEntity

- (id)init
{
    if(self = [super init]) {
        
        GLuint vb, ib;
        
        glGenBuffers(1, &vb);
        self.vertexBuffer = vb;
        glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, sizeof(CubeVertices), CubeVertices, GL_STATIC_DRAW);
        
        glGenBuffers(1, &ib);
        self.indexBuffer = ib;
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(CubeIndices), CubeIndices, GL_STATIC_DRAW);
        
        self.numberOfIndices = sizeof(CubeIndices) / sizeof(GLuint);
        self.indicesDataType = GL_UNSIGNED_INT;
        self.drawingMode = GL_TRIANGLES;
        
    }
    return self;
}

@end
