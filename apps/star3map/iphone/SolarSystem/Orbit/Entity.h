//
//  Entity.h
//  Orbit
//
//  Created by Conner Douglass on 2/11/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OpenGLScene;

@interface Entity : NSObject

@property BOOL usesExplicitColor;
@property CC3Vector4 color;

@property CC3Vector velocity;
@property CC3Vector angularVelocity;

@property CC3Vector position;
@property CC3Vector rotation;
@property CC3Vector scale;

@property BOOL hasTransparency;

@property GLuint vertexBuffer, indexBuffer;
@property GLuint numberOfIndices;
@property GLenum drawingMode;
@property GLenum indicesDataType;

@property BOOL litBySun;
@property BOOL litBySunAbsoluteValue; // Lit by a dot product of -1 or 1

@property OpenGLScene *scene;

@property BOOL atmosphereGlowEnabled;
@property CC3Vector atmosphereGlowInnerColor, atmosphereGlowOuterColor;

@property Texture *overlayTexture;
@property CGFloat overlayTextureOffsetX;

@property (readonly) NSArray *entities;
@property BOOL enabled;

- (void)render:(CC3GLMatrix *)modelView;
- (void)update:(CGFloat)dt;

- (void)addEntity:(Entity *)entity;
- (void)removeEntity:(Entity *)entity;

- (void)assignScene:(OpenGLScene *)scene;

- (void)addTexture:(Texture *)texture;
- (void)removeTexture:(Texture *)texture;
- (void)removeAllTextures;
- (NSArray *)textures;

@end
