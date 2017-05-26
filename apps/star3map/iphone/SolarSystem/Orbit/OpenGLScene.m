//
//  OpenGLScene.m
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "OpenGLScene.h"

@implementation OpenGLScene

- (id)init
{
    if(self = [super init]) {
        self.cameraPosition = cc3v(0.0f, 0.0f, 0.0f);
        self.cameraRotation = cc3v(0.0f, 0.0f, 0.0f);
        _entities = [NSArray array];
        self.backgroundColor = cc3v(0.0f, 0.0f, 0.0f);
        self.renderDistance = 2000.0f;
        self.scale = 1.0f;
        
        self.shadowsValue = [AppSettings dynamicLightingEnabled] ? 1.0f : 0.0f;
        self.glowValue = [AppSettings glowEnabled] ? 1.0f : 0.0f;
        self.cloudsValue = [AppSettings cloudsEnabled] ? 1.0f : 0.0f;
        
        self.projectionRect = CGRectNull;
    }
    return self;
}

- (void)didBecomeActive
{
    
}

- (void)didBecomeInactive
{
    
}

- (void)update:(CGFloat)dt
{
    for(Entity *entity in self.entities) {
        [entity update:dt];
    }
}

- (CC3GLMatrix *)baseModelviewMatrix
{
    CC3GLMatrix *baseModelView = [CC3GLMatrix matrix];
    CC3Vector lookFrom = self.cameraPosition;
    CC3Vector lookAt = CC3VectorAdd(lookFrom, self.cameraFacingVector);
    [baseModelView populateToLookAt:CC3VectorScaleUniform(lookAt, self.scale)
                          withEyeAt:CC3VectorScaleUniform(lookFrom, self.scale)
                             withUp:CC3VectorMake(0.0f, 1.0f, 0.0f)];
    
    [baseModelView scaleUniformlyBy:self.scale];
    
    return baseModelView;
}

- (void)render
{
    GLint backingWidth, backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    glViewport(0.0f, 0.0f, backingWidth, backingHeight);
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);

    glClearColor(self.backgroundColor.x, self.backgroundColor.y, self.backgroundColor.z, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    if(CGRectIsNull(self.projectionRect)) {
        const CGFloat projectionWidth = 2.0f;
        const CGFloat projectionHeight = projectionWidth * backingHeight / backingWidth;
        self.projectionRect = CGRectMake(
                                         -projectionWidth / 2.0f,
                                         -projectionHeight / 2.0f,
                                         projectionWidth,
                                         projectionHeight);
    }
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    [projection populateFromFrustumLeft:CGRectGetMinX(self.projectionRect)
                               andRight:CGRectGetMaxX(self.projectionRect)
                              andBottom:CGRectGetMinY(self.projectionRect)
                                 andTop:CGRectGetMaxY(self.projectionRect)
                                andNear:2.0f
                                 andFar:(self.renderDistance * self.scale)];
    glUniformMatrix4fv([self shaderUniformWithName:SHADER_UNIFORM_PROJECTION], 1, 0, projection.glMatrix);
    
    glUniform1f([self shaderUniformWithName:SHADER_UNIFORM_SHADOWS], self.shadowsValue);
    glUniform1f([self shaderUniformWithName:SHADER_UNIFORM_GLOW_VALUE], self.glowValue);
    glUniform1f([self shaderUniformWithName:SHADER_UNIFORM_CLOUDS_VALUE], self.cloudsValue);
    
    CC3GLMatrix *baseModelView = [self baseModelviewMatrix];
    
    for(Entity *entity in self.entities) {
        CC3GLMatrix *modelView = [CC3GLMatrix matrixFromGLMatrix:baseModelView.glMatrix];
        [entity render:modelView];
    }
}

- (GLuint)shaderAttributeWithName:(const GLchar *)name
{
    return glGetAttribLocation(((OpenGLView *)self.view).programHandle, name);
}

- (GLuint)shaderUniformWithName:(const GLchar *)name
{
    return glGetUniformLocation(((OpenGLView *)self.view).programHandle, name);
}

- (CC3Vector)cameraFacingVector
{
    CGFloat lookingAtX =  sinf(DegreesToRadians(self.cameraRotation.y));
    CGFloat lookingAtY =  sinf(DegreesToRadians(self.cameraRotation.x));
    CGFloat lookingAtZ = -cosf(DegreesToRadians(self.cameraRotation.y));
    CC3Vector facing = cc3v(lookingAtX, lookingAtY, lookingAtZ);
    facing = CC3VectorNormalize(facing);
    return facing;
}

- (void)addEntity:(Entity *)entity
{
    if([self.entities containsObject:entity]) {
        return;
    }
    NSMutableArray *entitiesNew = [NSMutableArray arrayWithArray:self.entities];
    [entity assignScene:self];
    /*
    for(Texture *t in entity.textures) {
        [t reactivate];
    }
     */
    [entitiesNew addObject:entity];
    _entities = [NSArray arrayWithArray:entitiesNew];
}

- (void)removeEntity:(Entity *)entity
{
    NSMutableArray *entitiesNew = [NSMutableArray arrayWithArray:self.entities];
    [entity assignScene:nil];
    /*
    for(Texture *t in entity.textures) {
        if([t canBeReactivated]) {
            [t dispose];
        }
    }
     */
    [entitiesNew removeObject:entity];
    _entities = [NSArray arrayWithArray:entitiesNew];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

@end
