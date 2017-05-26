//
//  UpgradeViewController.h
//  AVPlayerDemo
//
//  Created by Alex on 20/03/16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface UpgradeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) UIButton *playButton;
@property BOOL inTabbar;
@property (nonatomic, retain)MBProgressHUD *HUD;
@end
