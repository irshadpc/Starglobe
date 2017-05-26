//
//  OpenGLView.h
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#define SHADER_ATTRIB_POSITION "Position"
#define SHADER_ATTRIB_SOURCE_COLOR "ColorRaw"
#define SHADER_ATTRIB_TEXTURE_COORDINATE "TexCoordRaw"
#define SHADER_ATTRIB_NORMAL "Normal"

#define SHADER_UNIFORM_PROJECTION "Projection"
#define SHADER_UNIFORM_MODELVIEW "Modelview"

#define SHADER_UNIFORM_TEXTURES "Textures"
#define SHADER_UNIFORM_TEXTURES_ENABLED "TexturesEnabled"
#define SHADER_UNIFORM_OVERLAY_TEXTURE_COORDINATE "OverlayTexCoord"

#define SHADER_UNIFORM_SUN_LIT "SunLit"
#define SHADER_UNIFORM_SUN_POSITION "SunPosition"
#define SHADER_UNIFORM_BASE_MODELVIEW "BaseModelview"
#define SHADER_UNIFORM_ENTITY_POSITION "EntityPosition"

#define SHADER_UNIFORM_SHADOWS "ShadowsValue"
#define SHADER_UNIFORM_GLOW_VALUE "GlowValue"
#define SHADER_UNIFORM_CLOUDS_VALUE "CloudsValue"

#define SHADER_UNIFORM_ATMOSPHERE_GLOW_ENABLED "AtmosphereGlowEnabled"
#define SHADER_UNIFORM_ATMOSPHERE_GLOW_FACTOR "AtmosphereGlowFactor"
#define SHADER_UNIFORM_ATMOSPHERE_GLOW_INNER_COLOR "AtmosphereColorInner"
#define SHADER_UNIFORM_ATMOSPHERE_GLOW_OUTER_COLOR "AtmosphereColorOuter"

#define SHADER_UNIFORM_COLOR_OVERRIDE "ColorOverride"
#define SHADER_UNIFORM_COLOR_OVERRIDE_ENABLED "ColorOverrideEnabled"

@interface OpenGLView : UIView

@property (readonly) OpenGLScene *scene;
@property (readonly) EAGLContext *context;

@property BOOL paused;

@property GLuint programHandle;

+ (NSArray *)allActiveViews;
+ (void)setAllViewsPaused:(BOOL)paused;

- (void)presentScene:(OpenGLScene *)scene;

@end
