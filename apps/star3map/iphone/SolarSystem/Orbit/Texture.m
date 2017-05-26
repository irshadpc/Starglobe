//
//  Texture.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/4/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "Texture.h"

#define DEFAULT_TEXTURE_SIZE CGSizeMake(1536,1536)

@implementation Texture

static OpenGLView *masterView = nil;

+ (void)setMasterView:(OpenGLView *)view
{
    masterView = view;
}

+ (GLuint)setupTexture:(UIImage *)imgRaw inView:(OpenGLView *)view scaleDown:(BOOL)scaleDown scaleSize:(CGSize)size
{
    EAGLContext *oldCurrentContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:view.context];
    
    UIImage *img = nil;
    if(scaleDown) {
        img = [imgRaw fitToSize:size];
    }else{
        img = imgRaw;
    }
    
    // Get a CGImage reference from the image
    CGImageRef spriteImage = img.CGImage;
    
    // Log the error if there is one
    if (!spriteImage) {
        NSLog(@"Failed to load image.");
        exit(1);
    }
    
    // Get the width and the height of the image
    GLuint width = (GLuint)CGImageGetWidth(spriteImage);
    GLuint height = (GLuint)CGImageGetHeight(spriteImage);
    
    GLubyte* spriteData = (GLubyte *)calloc(width * height * 4, sizeof(GLubyte));
    
    // Create an image context for the texture
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGColorSpaceCreateDeviceRGB()/*CGImageGetColorSpace(spriteImage)*/, kCGImageAlphaPremultipliedLast);
    
    // Draw the image to the sprite data
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    // Release the context reference
    CGContextRelease(spriteContext);
    
    // Generate a texture and bind it
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    // Set some params for the texture
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // Load the image data to the texture
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    // Free up the memory used by the texture
    free(spriteData);
    
    [EAGLContext setCurrentContext:oldCurrentContext];
    
    // Return the integer that refers to the texture
    return texName;
}

/*
+ (void)disposeTexturesFromView:(UIView *)view
{
    if(!namedTextures) {
        return;
    }
    for(Texture *texture in namedTextures) {
        if(texture.view == view) {
            [texture dispose];
        }
    }
}
 */

- (id)initWithImageNamed:(NSString *)imageName
{
    return [self initWithImageNamed:imageName inView:masterView];
}

- (id)initWithImageNamed:(NSString *)imageName scaledDown:(BOOL)scaledDown
{
    return [self initWithImageNamed:imageName inView:masterView scaledDown:scaledDown];
}

- (id)initWithImage:(UIImage *)image scaledDown:(BOOL)scaledDown
{
    return [self initWithImage:image inView:masterView scaledDown:scaledDown];
}

- (id)initWithImage:(UIImage *)image
{
    return [self initWithImage:image inView:masterView];
}

- (id)initWithImage:(UIImage *)image inView:(OpenGLView *)view
{
    return [self initWithImage:image inView:view scaledDown:YES];
}

- (id)initWithImage:(UIImage *)image inView:(OpenGLView *)view scaledDown:(BOOL)scaledDown
{
    if(self = [super init]) {
        _view = view;
        _identifier = [Texture setupTexture:image inView:view scaleDown:scaledDown scaleSize:DEFAULT_TEXTURE_SIZE];
    }
    return self;
}

- (id)initWithImageNamed:(NSString *)imageName inView:(OpenGLView *)view
{
    return [self initWithImageNamed:imageName inView:view scaledDown:YES];
}

- (id)initWithImageNamed:(NSString *)imageName inView:(OpenGLView *)view scaledDown:(BOOL)scaledDown
{
    NSString * const docPrefix = @"docs:";
    NSString *imagePath = nil;
    
    if([imageName hasPrefix:docPrefix]) {
        NSString *docsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        imagePath = [docsDir stringByAppendingPathComponent:[imageName substringFromIndex:docPrefix.length]];
    }else{
        imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@""];
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return [self initWithImage:image inView:view scaledDown:scaledDown];
}

@end
