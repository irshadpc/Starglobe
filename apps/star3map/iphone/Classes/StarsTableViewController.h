//
//  StarsTableViewController.h
//  Starglobe
//
//  Created by Alex on 27.02.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UAAppReviewManager.h"

@interface StarsTableViewController : UITableViewController
@property(nonatomic, strong) GADBannerView *bannerView;
@property(nonatomic, strong) GADInterstitial *interstitial;
@end
