//
//  OpenGLScene.h
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

typedef struct {
    CGFloat Position[3];
    CGFloat Color[4];
    CGFloat TexCoord[2];
    CGFloat Normal[3];
} Vertex;

@interface OpenGLScene : NSObject

@property CGSize size;
@property UIView *view;

@property CC3Vector cameraPosition;
@property CC3Vector cameraRotation;

@property CC3Vector backgroundColor;

@property CGFloat renderDistance;

@property NSArray *entities;

@property CGFloat scale;
@property CGFloat shadowsValue;
@property CGFloat glowValue;
@property CGFloat cloudsValue;

@property CGRect projectionRect;

- (void)didBecomeActive;
- (void)didBecomeInactive;
- (void)update:(CGFloat)dt;
- (void)render;

- (CC3Vector)cameraFacingVector;
- (CC3GLMatrix *)baseModelviewMatrix;

- (GLuint)shaderAttributeWithName:(const GLchar *)name;
- (GLuint)shaderUniformWithName:(const GLchar *)name;

- (void)addEntity:(Entity *)entity;
- (void)removeEntity:(Entity *)entity;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
