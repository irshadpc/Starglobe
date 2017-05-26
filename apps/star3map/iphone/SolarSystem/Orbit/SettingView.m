//
//  SettingView.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/27/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "SettingView.h"

@implementation SettingView

+ (SettingView *)settingViewWithTitle:(NSString *)title control:(UIView *)control
{
    static const NSInteger spacing = 20;
    static NSInteger y = spacing / 2;
    
    // Generate a frame for the view
    CGRect frame;
    frame.origin.x = 0;
    frame.origin.y = y;
    frame.size.width = 320;
    frame.size.height = 50;
    
    // Generate a view
    SettingView *view = [[self alloc] initWithFrame:frame title:title control:control];
    
    y = CGRectGetMaxY(view.frame) + spacing;
    
    // Return the view
    return view;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title control:(UIView *)control
{
    if(self = [super initWithFrame:frame]) {
        
        _title = title;
        _control = control;
        
        const NSInteger paddingSides = 6;
        
        CGRect titleFrame;
        titleFrame.origin.x = paddingSides;
        titleFrame.origin.y = 0;
        titleFrame.size.width = CGRectGetWidth(frame) / 2.0f - paddingSides;
        titleFrame.size.height = CGRectGetHeight(frame);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:titleLabel];
        
        CGRect controlFrame;
        controlFrame.size = control.frame.size;
        controlFrame.origin.x = CGRectGetWidth(frame) - CGRectGetWidth(control.frame) - paddingSides;
        controlFrame.origin.y = (CGRectGetHeight(frame) - CGRectGetHeight(control.frame)) / 2.0f;
        control.frame = controlFrame;
        [self addSubview:control];
        
    }
    return self;
}

@end
