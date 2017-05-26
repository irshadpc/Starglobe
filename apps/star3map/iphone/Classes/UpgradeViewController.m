//
//  UpgradeViewController.m
//  AVPlayerDemo
//
//  Created by Alex on 20/03/16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import "UpgradeViewController.h"
#import "IAPManager.h"
#import "MBProgressHUD.h"
#import "CenterCell.h"


@implementation UpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Upgrade", nil);
    
   /* self.view.backgroundColor = tableViewCellBackgroundColor;
    self.tableView.backgroundColor = blackBackgroundColor;*/
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.navigationController.toolbarHidden = YES;

    [self.tableView setFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 60 - self.navigationController.tabBarController.tabBar.frame.size.height)];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -self.navigationController.tabBarController.tabBar.frame.size.height, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Restore", nil) style:UIBarButtonItemStylePlain target:self action:@selector(restore)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    NSString * oneMonthPrice = [[NSUserDefaults standardUserDefaults] objectForKey: @"IAPPrice"];
    if (oneMonthPrice == nil || [oneMonthPrice isEqualToString:@""]) {
        oneMonthPrice = @"$4.99";
    }
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 11, self.view.frame.size.width-40, 38)];
   // [_playButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
    [_playButton setTintColor:[UIColor whiteColor]];
    
    [_playButton setTitle:[NSString stringWithFormat:@"%@ - %@", NSLocalizedString(@"Upgrade", nil), oneMonthPrice] forState:UIControlStateNormal];
    [_playButton.titleLabel setFont:[UIFont fontWithName:@"GillSans" size:18]];
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    UIImage *normalImage = [[UIImage imageNamed:@"button_invitepeople_share.png"] resizableImageWithCapInsets:insets];
    [_playButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(purchase) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    [self.view bringSubviewToFront:_playButton];
    
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.square = NO;
    [self.view addSubview:self.HUD];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [[CenterCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CenterCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.hidden = NO;
    cell.detailTextLabel.numberOfLines = 4;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    
    cell.detailTextLabel.textColor = [UIColor whiteColor];
   // cell.backgroundColor = tableViewCellBackgroundColor;
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Upgrade now to get the most from Starglobe and enable all of these awesome features!", nil);
        cell.textLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        cell.textLabel.numberOfLines = 4;
        cell.imageView.image = nil;
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        
        if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
            [cell setPreservesSuperviewLayoutMargins:NO];
        }
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
    }
        if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"Automatic Subtitles", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Add subtitles to your videos in seconds with free, one-tap downloads from Opensubtitles.org.", nil);
            cell.imageView.image = [UIImage imageNamed:@"subtitle-upgrade"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"No Ads", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Enjoy your videos without any ads and interruptions.", nil);
            cell.imageView.image = [UIImage imageNamed:@"ads-upgrade"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Passcode Protection", nil);
            cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Use a Passcode to protect ProPlayer from unauthorized access, e.g. when you lend someone your %@.", @"%@ stands for iPhone/iPad"), [UIDevice currentDevice].model];
            cell.imageView.image = [UIImage imageNamed:@"passcode-upgrade"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Gestures", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Quickly control video playback with several customizable swipe and tap gestures, e.g. swipe to fast forward.", nil);
            cell.imageView.image = [UIImage imageNamed:@"gestures-upgrade"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 5) {
            cell.textLabel.text = NSLocalizedString(@"Background Playback", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Watching a music video but just want to listen to the audio? ProPlayer can play the audio in the background and continues even when you locked your device.", nil);
            cell.imageView.image = [UIImage imageNamed:@"background-upgrade"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        }
        
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

}


- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (NSString*) tableView:(UITableView *) tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (void)purchase{
    [self.HUD showAnimated:YES];
  //  [FIRAnalytics logEventWithName:@"Upgrade_View_Pressed_Upgrade" parameters:nil];

    [[IAPManager sharedIAPManager] purchaseProductForId:@"starglobe.pro"  completion:^(SKPaymentTransaction *transaction) {
        [self.HUD hideAnimated:YES];
    //    [FIRAnalytics logEventWithName:@"Upgrade_View_Upgrade_Successful" parameters:nil];

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ProEnabled"];
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.square = NO;
        self.HUD.label.text = NSLocalizedString(@"Thank you for upgrading. Enjoy ProPlayer Pro!", nil);
        [self.HUD hideAnimated:YES afterDelay:2.f];
    } error:^(NSError *err) {
        [self.HUD hideAnimated:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.square = NO;
        self.HUD.label.text = NSLocalizedString(@"An error occured. Please try again.", nil);
        [self.HUD hideAnimated:YES afterDelay:1.f];
    }];
}

- (void)restore{
    [self.HUD showAnimated:YES];
    [[IAPManager sharedIAPManager] restorePurchasesWithCompletion:^{
        
        [self.HUD hideAnimated:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ProEnabled"];
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.square = NO;
        self.HUD.label.text = NSLocalizedString(@"Thank you for upgrading. Enjoy ProPlayer Pro!", nil);
        [self.HUD hideAnimated:YES afterDelay:2.f];
    } error:^(NSError *err) {
        [self.HUD hideAnimated:YES];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.square = NO;
        self.HUD.label.text = NSLocalizedString(@"An error occured. Please try again.", nil);
        [self.HUD hideAnimated:YES afterDelay:1.f];
    }];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_inTabbar) {
        [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60 - self.navigationController.tabBarController.tabBar.frame.size.height)];
    } else {
        [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 60)];
    }
     [_playButton setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 11, self.view.frame.size.width-40, 38)];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (_inTabbar) {
            [self.tableView setFrame:CGRectMake(0, 0, size.width, size.height - 60 - self.navigationController.tabBarController.tabBar.frame.size.height)];
        } else {
           [self.tableView setFrame:CGRectMake(0, 0, size.width, size.height - 60)];
        }
        
       [_playButton setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 11, self.view.frame.size.width-40, 38)];
    } completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

@end
