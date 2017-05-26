//
//  SettingView.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 6/27/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingView : UIView

@property (readonly) NSString *title;
@property (readonly) UIView *control;

+ (SettingView *)settingViewWithTitle:(NSString *)title control:(UIView *)control;

@end
