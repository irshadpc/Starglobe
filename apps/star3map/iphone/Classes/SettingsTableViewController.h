//
//  SettingsTableViewController.h
//  AVPlayerDemo
//
//  Created by Alex on 08/03/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@interface SettingsTableViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property (nonatomic, retain)MBProgressHUD *HUD;
@end
