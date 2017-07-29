//
//  StarsListViewController.h
//  Starglobe
//
//  Created by Alex on 28/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarListViewController : UITableViewController
@property NSArray *contentArray;
@property int type;
@property(nonatomic, strong) GADBannerView *bannerView;
@end
