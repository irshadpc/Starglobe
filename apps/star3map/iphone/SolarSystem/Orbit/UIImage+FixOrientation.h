//
//  UIImage+FixOrientation.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/18/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (fixOrientation)

- (UIImage *)fixOrientation;
- (UIImage *)fitToSize:(CGSize)sizeRaw;

@end