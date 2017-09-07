//
//  StarsTableViewController.h
//  Starglobe
//
//  Created by Alex on 27.02.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAAppReviewManager.h"

@interface StarsTableViewController : UIViewController
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIView *bannerView;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *headlineLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UIButton *upgradeButton;
@property (nonatomic, retain) UIButton *overlayButton;
@end
