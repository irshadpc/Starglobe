//
//  UpgradeViewController.m
//  AVPlayerDemo
//
//  Created by Alex on 20/03/16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import "UpgradeViewController.h"
#import "MBProgressHUD.h"
#import "CenterCell.h"
#import "MKStoreKit.h"
#import "ManualViewController.h"

@implementation UpgradeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
        
    self.title = NSLocalizedString(@"Upgrade", nil);
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"iap-background"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];    self.tableView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.navigationController.toolbarHidden = YES;

    [self.tableView setFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 120 - self.navigationController.tabBarController.tabBar.frame.size.height)];
   // self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -self.navigationController.tabBarController.tabBar.frame.size.height - 60, 0);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Restore", nil) style:UIBarButtonItemStylePlain target:self action:@selector(restore)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    NSString * oneMonthPrice = [[NSUserDefaults standardUserDefaults] objectForKey: @"IAPPrice"];
    if (oneMonthPrice == nil || [oneMonthPrice isEqualToString:@""]) {
        oneMonthPrice = @"$9.89";
    }
    
    _priceLabel = [[UILabel alloc]init];
    _priceLabel.numberOfLines = 3;
    _priceLabel.textColor = [UIColor whiteColor];
    _priceLabel.textAlignment = NSTextAlignmentCenter;
    _priceLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Test all these features with a 1 week trial! After that %@/Year.", nil), [[NSUserDefaults standardUserDefaults] objectForKey: @"IAPPrice"]];
    [_priceLabel setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 11, self.view.frame.size.width, 50)];
    [self.view addSubview:_priceLabel];
    [self.view bringSubviewToFront:_priceLabel];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 71, self.view.frame.size.width, 38)];
   // [_playButton setBackgroundColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0]];
    [_playButton setTintColor:[UIColor whiteColor]];
    
    [_playButton setTitle:NSLocalizedString(@"Start Free Trial", nil) forState:UIControlStateNormal];
    [_playButton.titleLabel setFont:[UIFont fontWithName:@"GillSans" size:18]];
    UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    UIImage *normalImage = [[UIImage imageNamed:@"button"] resizableImageWithCapInsets:insets];
    [_playButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(purchase) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_playButton];
    [self.view bringSubviewToFront:_playButton];
    
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.square = NO;
    [self.view addSubview:self.HUD];
    
    [[MKStoreKit sharedKit] startProductRequest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(succesfulPurchase) name:@"PurchaseUpgrade" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(succesfulPurchase) name:@"RestoredPurchaseUpgrade" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPurchase) name:@"FailedRestoringUpgrade" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPurchase) name:@"FailedPurchaseUpgrade" object:nil];
}

- (void)succesfulPurchase{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"StarglobePro"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)failedPurchase{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.HUD hideAnimated:NO];
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
    if ( indexPath.row == 6) {
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
    cell.backgroundColor = [UIColor clearColor];

        if (indexPath.row == 0) {
            cell.textLabel.text = NSLocalizedString(@"Access to full Star Catalog", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Deep zoom to reveal more stars in the new Power Sky View. With animated high-res planets and over 110000 more objects, there’s plenty to explore!", nil);
            cell.imageView.image = [UIImage imageNamed:@"menu_icon_solar_system"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 1) {
            cell.textLabel.text = NSLocalizedString(@"No Ads", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Enjoy the night sky without any ads and interruptions.", nil);
            cell.imageView.image = [UIImage imageNamed:@"menu_icon_rate_app"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 2) {
            cell.textLabel.text = NSLocalizedString(@"All 3D Solar System Planets", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Discover all planets of the solar system and more with beautiful, animated 3D models and detailed images and descriptions.", nil);
            cell.imageView.image = [UIImage imageNamed:@"menu_icon_stars"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 3) {
            cell.textLabel.text = NSLocalizedString(@"Red night mode", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Preserve your dark-adapted eyesight.", nil);
            cell.imageView.image = [UIImage imageNamed:@"menu_icon_constellations"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 4) {
            cell.textLabel.text = NSLocalizedString(@"Satellites", nil);
            cell.detailTextLabel.text = NSLocalizedString(@"Track over 1000 satellites and the Hubble Telescope and the International Space Station.", nil);
            cell.imageView.image = [UIImage imageNamed:@"menu_icon_satellite"];
            cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
            cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
        } else if (indexPath.row == 5) {
            cell.textLabel.text = NSLocalizedString(@"Subscription Infos", nil);
            cell.detailTextLabel.text = nil;
            cell.detailTextLabel.hidden = YES;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    
    
        
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 5) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        ManualViewController *upgradeSettings = [storyboard instantiateViewControllerWithIdentifier:@"ManualViewController"];
        [self.navigationController pushViewController:upgradeSettings animated:YES];
    }
}


- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (NSString*) tableView:(UITableView *) tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (void)purchase{
    [self.HUD showAnimated:YES];
    [FIRAnalytics logEventWithName:@"Upgrade_View_Pressed_Upgrade" parameters:nil];
    
    [[MKStoreKit sharedKit] initiatePaymentRequestForProductWithIdentifier:[[GeneralHelper sharedManager]purchaseID]];
}

- (void)restore{
    [self.HUD showAnimated:YES];
    
    [[MKStoreKit sharedKit]restorePurchases];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if (_inTabbar) {
        [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 120 )];
    } else {
        [self.tableView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 120)];
    }
    [_priceLabel setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 11, self.view.frame.size.width - 40, 50)];

    [_playButton setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 71, self.view.frame.size.width - 40, 38)];
}


- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        if (_inTabbar) {
            [self.tableView setFrame:CGRectMake(0, 0, size.width, size.height - 120 - self.navigationController.tabBarController.tabBar.frame.size.height)];
        } else {
           [self.tableView setFrame:CGRectMake(0, 0, size.width, size.height - 120)];
        }
        [_priceLabel setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 11, self.view.frame.size.width - 40, 50)];

        [_playButton setFrame:CGRectMake(20, self.tableView.frame.origin.y + self.tableView.frame.size.height + 71, self.view.frame.size.width - 40, 38)];
    } completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

@end
