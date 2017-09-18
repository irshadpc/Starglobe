//
//  StarsTableViewController.m
//  Starglobe
//
//  Created by Alex on 27.02.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import "StarsTableViewController.h"
#import "StarListViewController.h"

@interface StarsTableViewController ()

@end

@implementation StarsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Search", nil);
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.navigationController.toolbarHidden = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    [self.tableView setFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 60 )];
    
    if ([[GeneralHelper sharedManager]freeVersion]){
        _bannerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
        _bannerView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
        [self.view addSubview:_bannerView];
        
        _iconView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
        _iconView.image = [UIImage imageNamed:@"Icon-Rounded"];
        [_bannerView addSubview: _iconView];
        
        _headlineLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 10, self.view.frame.size.width - 60, 17)];
        _headlineLabel.numberOfLines = 1;
        _headlineLabel.font = [UIFont boldSystemFontOfSize:16];
        _headlineLabel.textColor = [UIColor whiteColor];
        _headlineLabel.text = NSLocalizedString(@"Starglobe Pro", nil);
        [_bannerView addSubview: _headlineLabel];
        
        _subtitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(55, 27, self.view.frame.size.width - 60, 33)];
        _subtitleLabel.numberOfLines = 2;
        _subtitleLabel.font = [UIFont systemFontOfSize:12];
        _subtitleLabel.textColor = [UIColor whiteColor];
        _subtitleLabel.text = NSLocalizedString(@"Try all of the magical premium features of Starglobe for free right now!", nil);
        [_bannerView addSubview: _subtitleLabel];
        
        _upgradeButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_upgradeButton setFrame:CGRectMake(_headlineLabel.frame.origin.x + _headlineLabel.frame.size.width + 10, 10, 95, 40)];
        [_upgradeButton setTitle:NSLocalizedString(@"Upgrade", nil) forState:UIControlStateNormal];
        [_upgradeButton.titleLabel setFont:[UIFont boldSystemFontOfSize:14]];
        [_upgradeButton setBackgroundColor:[UIColor redColor]];
        [_upgradeButton setTintColor:[UIColor whiteColor]];
        [_upgradeButton addTarget:self action:@selector(upgradePressed) forControlEvents:UIControlEventTouchUpInside];
        [_bannerView addSubview: _upgradeButton];
        
        _overlayButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_overlayButton setBackgroundColor:[UIColor clearColor]];
        [_overlayButton addTarget:self action:@selector(upgradePressed) forControlEvents:UIControlEventTouchDown];
        [_overlayButton setFrame:_bannerView.frame];
        [self.view addSubview:_overlayButton];
        [self.view bringSubviewToFront:_overlayButton];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(succesfulPurchase) name:@"Purchase" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(succesfulPurchase) name:@"RestoredPurchase" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPurchase) name:@"FailedRestoring" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedPurchase) name:@"FailedPurchase" object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([[GeneralHelper sharedManager]freeVersion]){
        [_bannerView setFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width, 60)];
        [_iconView setFrame:CGRectMake(5, 5, 50, 50)];
        [_headlineLabel setFrame:CGRectMake(65, 5, self.view.frame.size.width - 175, 20)];
        [_subtitleLabel setFrame:CGRectMake(65, 24, self.view.frame.size.width - 175, 35)];
        [_upgradeButton setFrame:CGRectMake(_headlineLabel.frame.origin.x + _headlineLabel.frame.size.width + 10, 0, 100, 60)];
        [_overlayButton setFrame:_bannerView.frame];
    }
}

- (void)failedPurchase{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
    }];
}

- (void)succesfulPurchase{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"StarglobePro"];
        [self.bannerView removeFromSuperview];
        [self.tableView setFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height + 60 )];
    }];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)upgradePressed{
    [self.tabBarController setSelectedIndex:2];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] > 1 && [[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] % 5 == 0 && [[GeneralHelper sharedManager]freeVersion]) {
        [self.tabBarController setSelectedIndex:2];
    } else if ([[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] > 1 && [[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] % 9 == 0) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.3) {
            [SKStoreReviewController requestReview];
        } else {
            [UAAppReviewManager showPrompt];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] + 1 forKey:@"InterstitialCounter"];
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
    if (![[GeneralHelper sharedManager]freeVersion]) {
        return 6;
    }
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];

    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.detailTextLabel.hidden = YES;
    cell.detailTextLabel.numberOfLines = 1;
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];

    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Planets", nil);
        cell.imageView.image = [UIImage imageNamed:@"menu_icon_solar_system"];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"Stars", nil);
        cell.imageView.image = [UIImage imageNamed:@"menu_icon_stars"];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    } else if (indexPath.row == 2) {
        cell.textLabel.text = NSLocalizedString(@"Constellations", nil);
        cell.imageView.image = [UIImage imageNamed:@"menu_icon_constellations"];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    } else if (indexPath.row == 3) {
        cell.textLabel.text = NSLocalizedString(@"Satellites", nil);
        cell.imageView.image = [UIImage imageNamed:@"menu_icon_satellite"];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    } else if (indexPath.row == 4) {
        cell.textLabel.text = NSLocalizedString(@"Galaxies", nil);
        cell.imageView.image = [UIImage imageNamed:@"menu_icon_galaxy"];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    } else if (indexPath.row == 5) {
        cell.textLabel.text = NSLocalizedString(@"Dwarf Planets", nil);
        cell.imageView.image = [UIImage imageNamed:@"menu_icon_messier"];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    } else if (indexPath.row == 6) {
        cell.textLabel.text = NSLocalizedString(@"Upgrade", nil);
        cell.imageView.image = [UIImage imageNamed:@"menu_icon_downloads"];
        cell.detailTextLabel.font = [UIFont preferredFontForTextStyle: UIFontTextStyleCaption1];
        cell.detailTextLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0];

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 6) {
        [self.tabBarController setSelectedIndex:2];
    } else {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        StarListViewController *stars = [storyboard instantiateViewControllerWithIdentifier:@"StarListViewController"];
        stars.type = (int)indexPath.row;
        [self.navigationController pushViewController:stars animated:YES];
    }
    
}


- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}

- (NSString*) tableView:(UITableView *) tableView titleForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}


@end
