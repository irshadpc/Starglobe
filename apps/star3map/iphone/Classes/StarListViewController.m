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
    
    [self.tableView setFrame:CGRectMake(0, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height - 60)];
    
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (void)upgradePressed{
    [self.tabBarController setSelectedIndex:2];
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


@end
