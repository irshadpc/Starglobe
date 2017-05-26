//
//  Entity.m
//  Orbit
//
//  Created by Conner Douglass on 2/11/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "Entity.h"

#define VertexPositionComponents 3
#define VertexColorComponents 4
#define VertexTexCoordComponents 2
#define VOffset(t) ((GLvoid*)offsetof(Vertex, t))

// If we change this value, change it in the array definitions in fragment shader as well
#define TEXTURES_TO_PASS 2
/////////////

@interface Entity ()

@property NSMutableArray *texturesArray;

@end

@implementation Entity

static const GLuint TEXTURE_NAMES[] = {
    GL_TEXTURE0,
    GL_TEXTURE1,
    GL_TEXTURE2,
    GL_TEXTURE3,
    GL_TEXTURE4,
    GL_TEXTURE5,
    GL_TEXTURE6,
    GL_TEXTURE7,
    GL_TEXTURE8,
    GL_TEXTURE9,
    GL_TEXTURE10
};

- (id)init
{
    if(self = [super init]) {
        
        self.enabled = YES;
        self.usesExplicitColor = NO;
        self.color = CC3Vector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        
        self.position = cc3v(0.0f, 0.0f, 0.0f);
        self.rotation = cc3v(0.0f, 0.0f, 0.0f);
        self.scale = cc3v(1.0f, 1.0f, 1.0f);
        self.angularVelocity = cc3v(0.0f, 0.0f, 0.0f);
        self.velocity = cc3v(0.0f, 0.0f, 0.0f);
        
        self.drawingMode = GL_TRIANGLES;
        self.indicesDataType = GL_UNSIGNED_INT;
        
        _entities = [NSArray array];
        
        self.texturesArray = [NSMutableArray array];
        
        self.atmosphereGlowEnabled = NO;
        
        self.litBySun = YES;
        
        self.overlayTexture = nil;
        
        self.overlayTextureOffsetX = 0.0f;
        
    }
    return self;
}

- (void)addTexture:(Texture *)texture
{
    if(!texture) {
        return;
    }
    /*
    if(self.scene) {
        [texture reactivate];
    }
     */
    [self.texturesArray addObject:texture];
}

- (void)removeTexture:(Texture *)texture
{
    if(!texture) {
        return;
    }
    // [texture dispose];
    [self.texturesArray removeObject:texture];
}

- (void)removeAllTextures
{
    /*
    for(Texture *texture in self.texturesArray) {
        [texture dispose];
    }
     */
    [self.texturesArray removeAllObjects];
}

- (NSArray *)textures
{
    return [NSArray arrayWithArray:self.texturesArray];
}

- (void)update:(CGFloat)dt
{
    self.position = CC3VectorAdd(self.position, CC3VectorScaleUniform(self.velocity, dt));
    self.rotation = CC3VectorAdd(self.rotation, CC3VectorScaleUniform(self.angularVelocity, dt));
    for(Entity *entity in self.entities) {
        [entity update:dt];
    }
}

- (void)render:(CC3GLMatrix *)modelView
{
    if(!self.enabled) {
        return;
    }
    
    // [modelView translateBy:self.position rotateBy:self.rotation scaleBy:self.scale];
    [modelView translateBy:self.position];
    
    // CC3GLMatrix *baseModelviewMatrix = [CC3GLMatrix matrixFromGLMatrix:modelView.glMatrix];
    
    [modelView rotateByX:self.rotation.x];
    [modelView rotateByY:self.rotation.y];
    [modelView rotateByZ:self.rotation.z];
    [modelView scaleBy:self.scale];
    
    // [baseModelviewMatrix scaleBy:self.scale];
    
    if(self.numberOfIndices > 0) {
        
        glEnable(GL_BLEND);
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
        // Setup the matrix with OpenGL for rendering
        glUniformMatrix4fv([self.scene shaderUniformWithName:SHADER_UNIFORM_MODELVIEW], 1, 0, modelView.glMatrix);
        
        // Bind the index and vertex buffers
        glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBuffer);
        
        GLint texturesToPass[TEXTURES_TO_PASS + 1];
        GLint texturesEnabled[TEXTURES_TO_PASS + 1];
        
        NSInteger textureIndex = 0;
        for(Texture *texture in self.textures) {
            
            glActiveTexture(TEXTURE_NAMES[textureIndex]);
            glBindTexture(GL_TEXTURE_2D, texture.identifier);
            texturesToPass[textureIndex] = textureIndex;
            texturesEnabled[textureIndex] = 1;// texture.enabled;
            textureIndex++;
            
        }
        while(textureIndex < TEXTURES_TO_PASS) {
            glActiveTexture(TEXTURE_NAMES[textureIndex]);
            glBindTexture(GL_TEXTURE_2D, NULL);
            texturesToPass[textureIndex] = textureIndex;
            texturesEnabled[textureIndex] = 0;
            textureIndex++;
        }
        
        // Overlay texture (for clouds on planets)
        glActiveTexture(TEXTURE_NAMES[textureIndex]);
        if(self.overlayTexture) {
            glBindTexture(GL_TEXTURE_2D, self.overlayTexture.identifier);
            texturesToPass[textureIndex] = textureIndex;
            texturesEnabled[textureIndex] = 1;// self.overlayTexture.enabled;
        }else{
            glBindTexture(GL_TEXTURE_2D, NULL);
            texturesToPass[textureIndex] = textureIndex;
            texturesEnabled[textureIndex] = 0;
        }
        textureIndex++;
        
        glUniform2f([self.scene shaderUniformWithName:SHADER_UNIFORM_OVERLAY_TEXTURE_COORDINATE], (self.overlayTextureOffsetX - floorf(self.overlayTextureOffsetX)), 0.0f);
        
        glUniform1iv([self.scene shaderUniformWithName:SHADER_UNIFORM_TEXTURES], (TEXTURES_TO_PASS + 1), texturesToPass);
        glUniform1iv([self.scene shaderUniformWithName:SHADER_UNIFORM_TEXTURES_ENABLED], (TEXTURES_TO_PASS + 1), texturesEnabled);
        
        glUniform1i([self.scene shaderUniformWithName:SHADER_UNIFORM_SUN_LIT], self.litBySun ? (self.litBySunAbsoluteValue ? -1 : 1) : 0);
        
        // For now, a random sun position
        CC3Vector sunPos = cc3v(1.0f, 0.0f, 0.0f);
        sunPos = CC3VectorNormalize(sunPos);
        glUniform3f([self.scene shaderUniformWithName:SHADER_UNIFORM_SUN_POSITION], sunPos.x, sunPos.y, sunPos.z);
        
        glUniformMatrix4fv([self.scene shaderUniformWithName:SHADER_UNIFORM_BASE_MODELVIEW], 1, 0, self.scene.baseModelviewMatrix.glMatrix);
        glUniform3f([self.scene shaderUniformWithName:SHADER_UNIFORM_ENTITY_POSITION], self.position.x, self.position.y, self.position.z);
        
        if(self.atmosphereGlowEnabled) {
            
            GLfloat dist = 7.0f;
            if([self.scene isKindOfClass:[SolarSystemScene class]]) {
                dist = ((SolarSystemScene *)self.scene).focusDistanceFactor;
            }
            
            GLfloat glowFactor = MAX(1.0f - dist / 200.0f, 0.3f);
            
            if([self.scene isKindOfClass:[SolarSystemScene class]] && [self isKindOfClass:[GSWorld class]]) {
                if(![((SolarSystemScene *)self.scene).trackedBodyIdentifier isEqualToString:((GSWorld *)self).data.identifier]) {
                    glowFactor *= 0.6f;
                }
            }
            
            glUniform1i([self.scene shaderUniformWithName:SHADER_UNIFORM_ATMOSPHERE_GLOW_ENABLED], 1);
            glUniform1f([self.scene shaderUniformWithName:SHADER_UNIFORM_ATMOSPHERE_GLOW_FACTOR], glowFactor);
            glUniform4f([self.scene shaderUniformWithName:SHADER_UNIFORM_ATMOSPHERE_GLOW_INNER_COLOR], self.atmosphereGlowInnerColor.x, self.atmosphereGlowInnerColor.y, self.atmosphereGlowInnerColor.z, 1.0f);
            glUniform4f([self.scene shaderUniformWithName:SHADER_UNIFORM_ATMOSPHERE_GLOW_OUTER_COLOR], self.atmosphereGlowOuterColor.x, self.atmosphereGlowOuterColor.y, self.atmosphereGlowOuterColor.z, 1.0f);
            
        }else{
            
            glUniform1i([self.scene shaderUniformWithName:SHADER_UNIFORM_ATMOSPHERE_GLOW_ENABLED], 0);
            
        }
        
        if(self.usesExplicitColor) {
            glUniform1i([self.scene shaderUniformWithName:SHADER_UNIFORM_COLOR_OVERRIDE_ENABLED], 1);
            glUniform4f([self.scene shaderUniformWithName:SHADER_UNIFORM_COLOR_OVERRIDE], self.color.x, self.color.y, self.color.z, self.color.w);
        }else{
            glUniform1i([self.scene shaderUniformWithName:SHADER_UNIFORM_COLOR_OVERRIDE_ENABLED], 0);
        }
        
        // Point the position slot to the position, and the color slot to the color
        GLsizei vec = sizeof(Vertex);
        glVertexAttribPointer([self.scene shaderAttributeWithName:SHADER_ATTRIB_POSITION], 3, GL_FLOAT, GL_FALSE, vec, VOffset(Position));
        glVertexAttribPointer([self.scene shaderAttributeWithName:SHADER_ATTRIB_SOURCE_COLOR], 4, GL_FLOAT, GL_FALSE, vec, VOffset(Color));
        glVertexAttribPointer([self.scene shaderAttributeWithName:SHADER_ATTRIB_TEXTURE_COORDINATE], 2, GL_FLOAT, GL_FALSE, vec, VOffset(TexCoord));
        glVertexAttribPointer([self.scene shaderAttributeWithName:SHADER_ATTRIB_NORMAL], 3, GL_FLOAT, GL_FALSE, vec, VOffset(Normal));
        
        // Draw the elements!
        glDrawElements(self.drawingMode, self.numberOfIndices, self.indicesDataType, 0);
    }
    
    for(Entity *entity in self.entities) {
        CC3GLMatrix *modelView2 = [CC3GLMatrix matrixFromGLMatrix:modelView.glMatrix];
        [entity render:modelView2];
    }
}

- (void)assignScene:(OpenGLScene *)scene
{
    self.scene = scene;
    /*
    for(Texture *t in self.textures) {
        if(scene) {
            [t reactivate];
        }else{
            [t dispose];
        }
    }
     */
    for(Entity *entity in self.entities) {
        [entity assignScene:scene];
    }
}

- (void)addEntity:(Entity *)entity
{
    NSMutableArray *entitiesNew = [NSMutableArray arrayWithArray:self.entities];
    [entitiesNew addObject:entity];
    [entity assignScene:self.scene];
    /*
    for(Texture *t in entity.textures) {
        [t reactivate];
    }
     */
    _entities = [NSArray arrayWithArray:entitiesNew];
}

- (void)removeEntity:(Entity *)entity
{
    NSMutableArray *entitiesNew = [NSMutableArray arrayWithArray:self.entities];
    [entitiesNew removeObject:entity];
    [entity assignScene:nil];
    /*
    for(Texture *t in entity.textures) {
        if([t canBeReactivated]) {
            [t dispose];
        }
    }
     */
    _entities = [NSArray arrayWithArray:entitiesNew];
}

@end
