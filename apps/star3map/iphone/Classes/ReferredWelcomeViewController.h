//
//  ReferredWelcomeViewController.h
//  ProPlayer
//
//  Created by Alex on 28/06/16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReferredWelcomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIButton *playButton;
@property BOOL inTabbar;
@property int interstitialNumber;

@end
