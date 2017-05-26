//
//  OpenGLView.m
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "OpenGLView.h"

@interface OpenGLView () {
    CAEAGLLayer* _eaglLayer;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
}

@end

@implementation OpenGLView

static NSMutableArray *allViews = nil;

+ (void)setAllViewsPaused:(BOOL)paused
{
    NSArray *allViews = [OpenGLView allActiveViews];
    for(OpenGLView *view in allViews) {
        view.paused = paused;
    }
}

+ (NSArray *)allActiveViews
{
    if(!allViews) {
        allViews = [NSMutableArray array];
    }
    return [NSArray arrayWithArray:allViews];
}

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupLayer];
        [self setupContext];
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self compileShaders];
        [self setupDisplayLink];
        
        self.multipleTouchEnabled = YES;
        self.paused = NO;
        self.backgroundColor = [UIColor blackColor];
        
        if(!allViews) {
            allViews = [NSMutableArray array];
        }
        [allViews addObject:self];
    }
    return self;
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*)self.layer;
    _eaglLayer.opaque = YES;
    _eaglLayer.contentsScale = [UIScreen mainScreen].scale;
    self.contentScaleFactor = [UIScreen mainScreen].scale;
}

- (void)setupContext
{
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupDisplayLink
{
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    // [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}

- (void)setupDepthBuffer
{
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    CGFloat scale = [UIScreen mainScreen].scale;
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, CGRectGetWidth(self.frame) * scale, CGRectGetHeight(self.frame) * scale);
}

- (void)setupFrameBuffer
{
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)render:(CADisplayLink*)displayLink
{
    if(self.paused) {
        return;
    }
    
    EAGLContext *oldContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:self.context];
    
    if(self.scene) {
        [self.scene update:displayLink.duration];
        [self.scene render];
    }
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    glFlush();
    
    [EAGLContext setCurrentContext:oldContext];
}

- (void)presentScene:(OpenGLScene *)scene
{
    if(self.scene) {
        [self.scene didBecomeInactive];
    }
    scene.view = self;
    scene.size = self.bounds.size;
    [scene didBecomeActive];
    _scene = scene;
}

- (void)compileShaders
{
    // Compile shaders of each type
    GLuint vertexShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    // Create a program and attach the shaders
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // Check for the success of the shaders
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // Use the program with the compiled shaders
    glUseProgram(programHandle);
    
    // Enable all of the shader attributes
    glEnableVertexAttribArray(glGetAttribLocation(programHandle, SHADER_ATTRIB_POSITION));
    glEnableVertexAttribArray(glGetAttribLocation(programHandle, SHADER_ATTRIB_NORMAL));
    glEnableVertexAttribArray(glGetAttribLocation(programHandle, SHADER_ATTRIB_SOURCE_COLOR));
    glEnableVertexAttribArray(glGetAttribLocation(programHandle, SHADER_ATTRIB_TEXTURE_COORDINATE));
    
    self.programHandle = programHandle;
    
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType
{
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.scene touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.scene touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.scene touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.scene touchesCancelled:touches withEvent:event];
}

@end
