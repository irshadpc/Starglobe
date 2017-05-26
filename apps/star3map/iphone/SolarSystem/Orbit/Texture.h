//
//  Texture.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/4/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <Foundation/Foundation.h>

@class OpenGLView;

@interface Texture : NSObject

@property (readonly) OpenGLView *view;
@property (readonly) GLuint identifier;

+ (void)setMasterView:(OpenGLView *)view;

- (id)initWithImageNamed:(NSString *)imageName inView:(UIView *)view scaledDown:(BOOL)scaledDown;
- (id)initWithImage:(UIImage *)image inView:(UIView *)view scaledDown:(BOOL)scaledDown;
- (id)initWithImageNamed:(NSString *)imageName inView:(UIView *)view;
- (id)initWithImage:(UIImage *)image inView:(UIView *)view;

- (id)initWithImageNamed:(NSString *)imageName;
- (id)initWithImageNamed:(NSString *)imageName scaledDown:(BOOL)scaledDown;
- (id)initWithImage:(UIImage *)image scaledDown:(BOOL)scaledDown;
- (id)initWithImage:(UIImage *)image;

@end
