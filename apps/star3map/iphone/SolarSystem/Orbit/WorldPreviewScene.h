//
//  WorldPreviewScene.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/4/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "OpenGLScene.h"

@interface WorldPreviewScene : OpenGLScene

@property SphereEntity *planet;

- (void)setPlanetTexture:(Texture *)texture;
- (void)setRingTexture:(Texture *)texture;
- (void)setCloudTexture:(Texture *)texture;
- (void)setAxisTilt:(CGFloat)tilt;
- (void)setCloudsEnabled:(BOOL)enabled;
- (void)setRingsEnabled:(BOOL)enabled;
- (void)setRingColor:(CC3Vector4)color;

@end
