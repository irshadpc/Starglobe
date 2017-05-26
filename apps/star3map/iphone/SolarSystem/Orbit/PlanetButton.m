//
//  PlanetButton.m
//  Kepler Explorer
//
//  Created by Conner Douglass on 2/22/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "PlanetButton.h"

@interface PlanetButton () <UIAlertViewDelegate>

@property UIImageView *backgroundImageView;
@property UILabel *nameLabel;
@property BOOL isCustomWorld;
@property NSString *identifier;
@property UIButton *editButton;

@end

@implementation PlanetButton

+ (void)fetchTextureImageWithIdentifier:(NSString *)identifier completion:(void(^)(UIImage *image))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        UIImage *texture = [PlanetButton textureImageWithIdentifier:identifier];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(texture);
        });
        
    });
}

+ (UIImage *)sunThumbnail
{
    UIImage *textureImage = [PlanetButton imageWithTextureName:@"sun.jpg"];
    
    CC3Vector ringColor = CC3VectorMake(1.0f, 1.0f, 1.0f);
    BOOL hasRings = NO;
    
    return [PlanetButton thumbnailImage:textureImage hasRings:hasRings ringColor:ringColor ringsTemplate:nil];
}

+ (void)fetchSunThumbnailWithCompletion:(void(^)(UIImage *image))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        UIImage *texture = [PlanetButton sunThumbnail];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(texture);
        });
        
    });
}

+ (void)fetchTextureThumbnailWithIdentifier:(NSString *)identifier completion:(void(^)(UIImage *image))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        UIImage *texture = [PlanetButton textureThumbnailWithIdentifier:identifier];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(texture);
        });
        
    });
}

+ (UIImage *)textureImageWithIdentifier:(NSString *)identifier
{
    NSArray *json = [WorldDataManager availableBodyJSON];
    NSDictionary *dictionary = nil;
    for(NSDictionary *d in json) {
        if([d[@"id"] isEqualToString:identifier]) {
            dictionary = d;
            break;
        }
    }
    if(!dictionary) {
        return nil;
    }
    
    GSWorldData *data = [[GSWorldData alloc] initWithJson:dictionary];
    
    UIImage *textureImage = [PlanetButton imageWithTextureName:data.texture0];
    return textureImage;
}

+ (UIImage *)textureThumbnailWithIdentifier:(NSString *)identifier
{
    NSArray *json = [WorldDataManager availableBodyJSON];
    NSDictionary *dictionary = nil;
    for(NSDictionary *d in json) {
        if([d[@"id"] isEqualToString:identifier]) {
            dictionary = d;
            break;
        }
    }
    if(!dictionary) {
        return nil;
    }
    
    GSWorldData *data = [[GSWorldData alloc] initWithJson:dictionary];
    
    UIImage *textureImage = [PlanetButton imageWithTextureName:data.texture0];
    NSString *ringsName = @"rings1-template.png";
    if([data.rings.texture isEqualToString:@"rings2"] || [data.rings.texture isEqualToString:@"uranus-rings.png"]) {
        ringsName = @"rings2-template.png";
    }
    
    return [PlanetButton thumbnailImage:textureImage hasRings:data.rings.enabled ringColor:data.rings.color ringsTemplate:ringsName];
}

+ (void)fetchThumbnailImage:(UIImage *)texture hasRings:(BOOL)hasRings ringColor:(CC3Vector)ringColor ringsTemplate:(NSString *)ringsName completion:(void(^)(UIImage *image))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        UIImage *image = [PlanetButton thumbnailImage:texture hasRings:hasRings ringColor:ringColor ringsTemplate:ringsName];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(image);
        });
        
    });
}

+ (UIImage *)thumbnailImage:(UIImage *)texture hasRings:(BOOL)hasRings ringColor:(CC3Vector)ringColor ringsTemplate:(NSString *)ringsName
{
    static const CGSize size = CGSizeMake(128.0f, 128.0f);
    static const CGRect withRingsPlanetFrame = CGRectMake(0.37f * size.width,
                                                          0.33f * size.height,
                                                          0.27f * size.width,
                                                          0.27f * size.height);
    static const CGFloat withoutRingsPlanetScale = 0.6f;
    static const CGRect withoutRingsPlanetFrame = CGRectMake((1.0f - withoutRingsPlanetScale) / 2.0f * size.width,
                                                             (1.0f - withoutRingsPlanetScale) / 2.0f * size.height,
                                                             size.width * withoutRingsPlanetScale,
                                                             size.height * withoutRingsPlanetScale);
    static const CGFloat scaleX = 2.0f;
    
    CGRect planetPosRect;
    UIImage *rings;
    
    if(hasRings) {
        planetPosRect = withRingsPlanetFrame;
        rings = [UIImage imageNamed:(ringsName ? ringsName : @"rings1-template.png")];
        rings = [PlanetButton maskedImage:rings color:[UIColor colorWithRed:ringColor.x green:ringColor.y blue:ringColor.z alpha:1.0f]];
    }else{
        planetPosRect = withoutRingsPlanetFrame;
    }
    
    CGFloat textureDrawWidth = CGRectGetWidth(planetPosRect) * scaleX;
    CGRect textureRect = CGRectMake(CGRectGetMinX(planetPosRect) + (CGRectGetWidth(planetPosRect) - textureDrawWidth) / 2.0f,
                                    CGRectGetMinY(planetPosRect),
                                    textureDrawWidth,
                                    CGRectGetHeight(planetPosRect));
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    [[UIBezierPath bezierPathWithRoundedRect:planetPosRect cornerRadius:CGRectGetWidth(planetPosRect) / 2.0f] addClip];
    [texture drawInRect:textureRect];
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
    
    if(hasRings) {
        [rings drawInRect:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    }
    
    UIImage *thumb = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return thumb;
}

+ (UIImage *)maskedImage:(UIImage *)image color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef c = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(c, 0, image.size.height);
    CGContextScaleCTM(c, 1.0, -1.0);
    
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    
    // draw black background to preserve color of transparent pixels
    CGContextSetBlendMode(c, kCGBlendModeNormal);
    [[UIColor blackColor] setFill];
    CGContextFillRect(c, rect);
    
    // draw original image
    CGContextSetBlendMode(c, kCGBlendModeNormal);
    CGContextDrawImage(c, rect, image.CGImage);
    
    // tint image (loosing alpha) - the luminosity of the original image is preserved
    CGContextSetBlendMode(c, kCGBlendModeColor);
    [color setFill];
    CGContextFillRect(c, rect);
    
    // mask by alpha values of original image
    CGContextSetBlendMode(c, kCGBlendModeDestinationIn);
    CGContextDrawImage(c, rect, image.CGImage);
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

+ (void)fetchImageWithTextureName:(NSString *)name completion:(void(^)(UIImage *image))completion
{
    if(!completion) {
        return;
    }
    dispatch_async(GALILEO_DATA_QUEUE, ^{
        
        UIImage *image = [PlanetButton imageWithTextureName:name];
        
        dispatch_async(GALILEO_MAIN_QUEUE, ^{
            completion(image);
        });
        
    });
}

+ (UIImage *)imageWithTextureName:(NSString *)name
{
    NSString *prefix = @"docs:";
    
    NSString *filePath = @"";
    
    if([name hasPrefix:prefix]) {
        NSString *nameShort = [name substringFromIndex:prefix.length];
        NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        filePath = [docs stringByAppendingPathComponent:nameShort];
    }else{
        filePath = [[NSBundle mainBundle] pathForResource:name ofType:@""];
    }
    
    return [UIImage imageWithContentsOfFile:filePath];
}

- (id)initWithFrame:(CGRect)frame json:(NSDictionary *)json
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.editBlock = nil;
        self.deleteBlock = nil;
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        
        _data = [[GSWorldData alloc] initWithJson:json];
        
        self.isCustomWorld = [self.data.package isEqualToString:PACKAGE_USERWORLDS];
        
        UIImage *textureImage = [PlanetButton imageWithTextureName:self.data.texture0];
        
        self.identifier = self.data.identifier;
        
        
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 64, CGRectGetHeight(frame))];
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFit;
        // self.backgroundImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@-thumb", [json valueForKey:@"id"]]];
        
        self.nameLabel = [[UILabel alloc] init];
        self.nameLabel.frame = CGRectMake(CGRectGetHeight(self.backgroundImageView.frame), 0, CGRectGetWidth(frame) - CGRectGetHeight(frame) - (self.isCustomWorld ? CGRectGetHeight(frame) : 0), CGRectGetHeight(frame));
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = self.isCustomWorld ? [UIColor orangeColor] : [UIColor whiteColor];
        self.nameLabel.text = self.data.name;
        self.nameLabel.alpha = 0.0f;
        [self addSubview:self.nameLabel];
        
        if(self.isCustomWorld) {
            
            CGFloat size = CGRectGetHeight(frame);
            CGSize buttonSize = CGSizeMake(40, 20);
            
            self.editButton = [UIButton buttonWithType:UIButtonTypeCustom];
            self.editButton.frame = CGRectMake(CGRectGetWidth(frame) - buttonSize.width - 10, (size - buttonSize.height) / 2.0f, buttonSize.width, buttonSize.height);
            self.editButton.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
            self.editButton.layer.cornerRadius = 3.0f;
            [self.editButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.editButton.titleLabel.font = [UIFont systemFontOfSize:9.0f];
            [self.editButton setTitle:@"EDIT" forState:UIControlStateNormal];
            [self.editButton addTarget:self action:@selector(didTapEdit) forControlEvents:UIControlEventTouchUpInside];
            self.editButton.alpha = 0.0f;
            [self addSubview:self.editButton];
            
        }
        
        [PlanetButton fetchImageWithTextureName:self.data.texture0 completion:^(UIImage *image) {
            
            NSString *ringsName = @"rings1-template.png";
            if([self.data.rings.texture isEqualToString:@"rings2.png"] || [self.data.rings.texture isEqualToString:@"uranus-rings.png"]) {
                ringsName = @"rings2-template.png";
            }
            
            [PlanetButton fetchThumbnailImage:textureImage hasRings:self.data.rings.enabled ringColor:self.data.rings.color ringsTemplate:ringsName completion:^(UIImage *image) {
                self.backgroundImageView.alpha = 0.0f;
                self.nameLabel.alpha = 0.0f;
                self.backgroundImageView.image = image;
                [UIView animateWithDuration:0.6f animations:^{
                    self.backgroundImageView.alpha = 1.0f;
                    self.nameLabel.alpha = 1.0f;
                    if(self.editButton) {
                        self.editButton.alpha = 1.0f;
                    }
                }];
            }];
        }];

        [self addSubview:self.backgroundImageView];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped)]];
        
    }
    return self;
}

- (void)didTapEdit
{
    NSString *message = [NSString stringWithFormat:@"\"%@\"\rYou may edit or delete this world.", self.nameLabel.text];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"World Options" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Edit", @"Delete", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Edit"]) {
        if(self.editBlock) {
            self.editBlock(self.identifier);
        }
    }else if([title isEqualToString:@"Delete"]) {
        if(self.deleteBlock) {
            self.deleteBlock(self.identifier);
        }
    }
}

- (void)tapped
{
    if(self.wasTapped) {
        self.wasTapped();
    }
}

@end
