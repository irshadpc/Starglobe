//
//  StarsListViewController.m
//  Starglobe
//
//  Created by Alex on 28/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import "StarListViewController.h"
#import "StarDetailViewController.h"
#import "TDBadgedCell.h"

@interface StarListViewController ()

@end

@implementation StarListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.navigationController.toolbarHidden = YES;
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    NSString* fileName;

    if (_type == 0) {
        fileName = @"Planets";
    } else if (_type == 1) {
        fileName = @"Stars";
    } else if (_type == 2) {
        fileName = @"Constellations";
    } else if (_type == 3) {
        fileName = @"Satellites";
    } else if (_type == 4) {
        fileName = @"Galaxies";
    } else if (_type == 5) {
        fileName = @"DwarfPlanets";
    }
    
    NSString* title;

    
    if (_type == 0) {
        title = NSLocalizedString(@"Planets", nil);
    } else if (_type == 1) {
        title = NSLocalizedString(@"Stars", nil);
    } else if (_type == 2) {
        title = NSLocalizedString(@"Constellations", nil);
    } else if (_type == 3) {
        title = NSLocalizedString(@"Satellites", nil);
    } else if (_type == 4) {
        title = NSLocalizedString(@"Galaxies", nil);
    } else if (_type == 5) {
        title = NSLocalizedString(@"Dwarf Planets", nil);
    }
    
    self.title = title;
    

    _contentArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"]];
    [self.tableView registerClass:[TDBadgedCell class] forCellReuseIdentifier:@"BadgeCell"];
    
    if ([[GeneralHelper sharedManager]freeVersion]) {
        self.bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
#ifdef STARGLOBE_FREE
        self.bannerView.adUnitID = @"ca-app-pub-1395183894711219/1007000083";
#endif
        
#ifdef STARGLOBE_PRO
        self.bannerView.adUnitID = @"ca-app-pub-1395183894711219/1354749203";
        
#endif
        self.bannerView.rootViewController = self;
        [self.view addSubview:self.bannerView];
        [self.bannerView loadRequest:[GADRequest request]];
    }
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
    return _contentArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > _contentArray.count/4 && [[GeneralHelper sharedManager]freeVersion]) {
        TDBadgedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BadgeCell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.detailTextLabel.hidden = YES;
        cell.detailTextLabel.numberOfLines = 1;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        cell.badgeColor = [UIColor redColor];
        cell.badgeString = NSLocalizedString(@"Pro", nil);

        NSDictionary *dictionary = [_contentArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [dictionary objectForKey:@"Name"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0];
        
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.detailTextLabel.hidden = YES;
        cell.detailTextLabel.numberOfLines = 1;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
        cell.detailTextLabel.textColor = [UIColor lightGrayColor];
        
        NSDictionary *dictionary = [_contentArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [dictionary objectForKey:@"Name"];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0];
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row > _contentArray.count/4 && [[GeneralHelper sharedManager]freeVersion]) {
        [self.tabBarController setSelectedIndex:2];
    } else {
        NSDictionary *dictionary = [_contentArray objectAtIndex:indexPath.row];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
        StarDetailViewController *stars = [storyboard instantiateViewControllerWithIdentifier:@"StarDetailViewController"];
        NSLog(@"stars.contentFile %@", [dictionary objectForKey:@"Name"]);
        
        if (_type == 4) {
            stars.contentFile = [NSString stringWithFormat:@"m%d", (int)indexPath.row + 1];
        } else {
            stars.contentFile = [[[[dictionary objectForKey:@"Name"]lowercaseString]stringByReplacingOccurrencesOfString:@" " withString:@"_"]stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        }
        
        
        stars.viewTitle = [dictionary objectForKey:@"Name"];
        
        [self.navigationController pushViewController:stars animated:YES];
    }
}

- (void)viewDidLayoutSubviews {
    [self.bannerView setFrame:CGRectMake(0, self.view.frame.size.height - _bannerView.frame.size.height, _bannerView.frame.size.width, _bannerView.frame.size.height)];
    
}

@end
