//
//  MainViewController.h
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

+ (MainViewController *)sharedInstance;

- (void)reloadAvailableWorlds;
- (void)createWorld;
- (void)editWorldWithIdentifier:(NSString *)identifier;

@end
