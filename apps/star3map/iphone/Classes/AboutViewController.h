//
//  AboutViewController.h
//  CarbonWorkout
//
//  Created by Kevin Carbone on 5/13/14.
//  Copyright (c) 2014 Kevin Carbone. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface AboutViewController : UITableViewController <MFMailComposeViewControllerDelegate>
@property (nonatomic, retain)UIImageView *logoView;
@property (nonatomic, retain)UILabel *descriptionLabel;
@end
