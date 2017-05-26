//
//  SettingsDetailTableViewController.h
//  AVPlayerDemo
//
//  Created by Alex on 19/03/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsDetailTableViewController : UITableViewController
@property (nonatomic, retain) NSArray *settingsArray;
@property (nonatomic, retain) NSArray *userDefaultArray;
@property (nonatomic, retain) NSArray *valueArray;
@property (nonatomic) NSString *settingsTitle;
@property (nonatomic) NSString *userDefault;
@property (nonatomic) NSString *userDefaultValue;
@property BOOL doubleDetail;
@end
