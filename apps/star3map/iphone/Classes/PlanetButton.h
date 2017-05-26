//
//  PlanetButton.h
//  Kepler Explorer
//
//  Created by Conner Douglass on 2/22/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlanetButton : UIView

+ (void)fetchTextureImageWithIdentifier:(NSString *)identifier completion:(void(^)(UIImage *image))completion;
+ (void)fetchTextureThumbnailWithIdentifier:(NSString *)identifier completion:(void(^)(UIImage *image))completion;
+ (UIImage *)textureImageWithIdentifier:(NSString *)identifier;
+ (UIImage *)textureThumbnailWithIdentifier:(NSString *)identifier;
+ (void)fetchSunThumbnailWithCompletion:(void(^)(UIImage *image))completion;

@property (copy) void(^wasTapped)(void);
@property UIColor *baseBackgroundColor;
@property (copy) void(^editBlock)(NSString *identifier);
@property (copy) void(^deleteBlock)(NSString *identifier);

@property (readonly) GSWorldData *data;

- (id)initWithFrame:(CGRect)frame json:(NSDictionary *)json;

@end