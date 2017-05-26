//
//  OBJEntity.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 7/24/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "OBJEntity.h"

#define VERT_COMPONENTS 3
#define NORMAL_COMPONENTS 3
#define TEX_COORD_COMPONENTS 2
#define COLOR_COMPONENTS 4

@interface OBJEntity ()

// @property OpenGLWaveFrontObject *wfObject;

@end

@implementation OBJEntity

+ (OBJEntity *)banana
{
    // return [[OBJEntity alloc] initWithNumVerts:bananaNumVerts vertices:bananaVerts normals:bananaNormals texCoords:bananaTexCoords];
    // return [[OBJEntity alloc] initWithNumVerts:phobosNumVerts vertices:phobosVerts normals:phobosVerts texCoords:phobosTexCoords];
    return nil;
}

- (id)initWithNumVerts:(NSInteger)numVerts
              vertices:(CGFloat *)verts
               normals:(CGFloat *)normals
             texCoords:(CGFloat *)texCoords
{
    if(self = [super init]) {
        
        Vertex vertices[numVerts];
        GLuint indices[numVerts];
        
        // Vertex *vertices = (Vertex *)malloc(sizeof(Vertex) * numVerts);
        // GLuint *indices = (GLuint *)malloc(sizeof(GLuint) * numVerts);
        
        for(GLuint vindex = 0; vindex < numVerts; vindex++) {
            
            for(GLuint pindex = 0; pindex < VERT_COMPONENTS; pindex++) {
                vertices[0].Position[0] = verts[vindex * VERT_COMPONENTS + pindex];
            }
            
            for(GLuint cindex = 0; cindex < COLOR_COMPONENTS; cindex++) {
                vertices[vindex].Color[cindex] = 1.0f;
            }
            
            for(GLuint tindex = 0; tindex < TEX_COORD_COMPONENTS; tindex++) {
                vertices[vindex].TexCoord[tindex] = texCoords[vindex * TEX_COORD_COMPONENTS + tindex];
            }
            
            for(GLuint nindex = 0; nindex < NORMAL_COMPONENTS; nindex++) {
                vertices[vindex].Normal[nindex] = normals[vindex * NORMAL_COMPONENTS + nindex];
            }
            
            indices[vindex] = vindex;
            
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
        
        self.numberOfIndices = numVerts;
        
    }
    return self;
}

/*
- (id)initWithName:(NSString *)name
{
    if(self = [super init]) {
        NSString *nameBase = name;
        NSString *nameExt = @"";
        if([name hasSuffix:[NSString stringWithFormat:@".%@", OBJ_EXTENSION]]) {
            nameBase = [name substringToIndex:(name.length - (OBJ_EXTENSION.length + 1))];
            nameExt = OBJ_EXTENSION;
        }
        
        NSString *filepath = [[NSBundle mainBundle] pathForResource:nameBase ofType:nameExt];
        
        self.wfObject = [[OpenGLWaveFrontObject alloc] initWithPath:filepath];
        
        Vertex vertices[self.wfObject.numberOfVertices];
        GLuint indices[self.wfObject.numberOfVertices];
        
        for(NSInteger vi = 0; vi < self.wfObject.numberOfVertices; vi++) {
            
            vertices[vi].Position[0] = self.wfObject.vertices[vi].x;
            vertices[vi].Position[1] = self.wfObject.vertices[vi].y;
            vertices[vi].Position[2] = self.wfObject.vertices[vi].y;
            
            vertices[vi].Color[0] = 1.0f;
            vertices[vi].Color[1] = 1.0f;
            vertices[vi].Color[2] = 1.0f;
            vertices[vi].Color[3] = 1.0f;
            
            for(NSInteger ti = 0; ti < 2; ti++) {
                vertices[vi].TexCoord[ti] = self.wfObject.textureCoords[vi * self.wfObject.valuesPerCoord + ti];
            }
            
            vertices[vi].Normal[0] = self.wfObject.vertexNormals[vi].x;
            vertices[vi].Normal[1] = self.wfObject.vertexNormals[vi].y;
            vertices[vi].Normal[2] = self.wfObject.vertexNormals[vi].z;
            
            indices[vi] = vi;
            
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
        
        self.numberOfIndices = self.wfObject.numberOfVertices;
    }
    return self;
}
 */

@end
