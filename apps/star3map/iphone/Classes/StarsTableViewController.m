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
    
#ifdef STARGLOBE_FREE
    self.bannerView.adUnitID = @"ca-app-pub-1395183894711219/1007000083";
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-1395183894711219/8530266883"];
#endif
    
#ifdef STARGLOBE_PRO
    self.bannerView.adUnitID = @"ca-app-pub-1395183894711219/1354749203";
    self.interstitial = [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-1395183894711219/8583691902"];
#endif
    
    self.bannerView.rootViewController = self;
    
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"LaunchCounter"] %2 == 0 && [[GeneralHelper sharedManager]freeVersion]) {NSLog(@"yoyo 0");
        [self.view addSubview:self.bannerView];
        [self.bannerView loadRequest:[GADRequest request]];
        [self.interstitial loadRequest:[GADRequest request]];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] > 1 && [[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] % 3 == 0 && [[GeneralHelper sharedManager]freeVersion]) {
        if (self.interstitial.isReady) {
            [self.interstitial presentFromRootViewController:self];
            [self.interstitial loadRequest:[GADRequest request]];
        } else if ([[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] % 6 == 0) {
            if ([UIDevice currentDevice].systemVersion.floatValue >= 10.3) {
                [SKStoreReviewController requestReview];
            } else {
                [UAAppReviewManager showPrompt];
            }
        } else {
            [self.tabBarController setSelectedIndex:2];
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

- (void)viewDidLayoutSubviews {
    [self.bannerView setFrame:CGRectMake(0, self.view.frame.size.height - _bannerView.frame.size.height, _bannerView.frame.size.width, _bannerView.frame.size.height)];
    
}

@end
