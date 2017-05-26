//
//  SettingsDetailTableViewController.m
//  AVPlayerDemo
//
//  Created by Alex on 19/03/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "SettingsDetailTableViewController.h"
#import "SelectSettingsTableViewController.h"

@implementation SettingsDetailTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _settingsTitle;
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_settingsArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsTableViewCell"];
    }
    cell.textLabel.text = [_settingsArray objectAtIndex:indexPath.row];

    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    if (_doubleDetail) {
        cell.accessoryView = nil;
        if (indexPath.row == [[NSUserDefaults standardUserDefaults]integerForKey:_userDefault]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 0 ||indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 || indexPath.row == 6) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } else {
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    } else {
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    [cell setTintColor:[UIColor redColor]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (_doubleDetail){
        if (indexPath.row == 1 || indexPath.row == 2 ) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = @[NSLocalizedString(@"10 Seconds", nil), NSLocalizedString(@"30 Seconds", nil), NSLocalizedString(@"1 Minute", nil), NSLocalizedString(@"5 Minutes", nil), NSLocalizedString(@"15 Minutes", nil), NSLocalizedString(@"30 Minutes", nil) ];

            gestures.settingsTitle = [_settingsArray objectAtIndex:indexPath.row];
            gestures.userDefault = _userDefault;
            gestures.userDefaultValue = _userDefaultValue;
            gestures.userDefaultSetValue = (int)indexPath.row;
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 7 || indexPath.row == 8) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = @[NSLocalizedString(@"+5%", nil), NSLocalizedString(@"+10%", nil), NSLocalizedString(@"+25%", nil), NSLocalizedString(@"100%", nil), NSLocalizedString(@"-5%", nil), NSLocalizedString(@"-10%", nil), NSLocalizedString(@"-25%", nil), NSLocalizedString(@"0%", nil)];
            

            gestures.settingsTitle = [_settingsArray objectAtIndex:indexPath.row];
            gestures.userDefault = _userDefault;
            gestures.userDefaultValue = _userDefaultValue;
            gestures.userDefaultSetValue = (int)indexPath.row;
            [self.navigationController pushViewController:gestures animated:YES];
        } else {
            [[NSUserDefaults standardUserDefaults] setInteger:indexPath.row forKey:_userDefault];
            [self.tableView reloadData];
        }
    } else {
            SettingsDetailTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsDetail"];
            gestures.settingsArray = @[NSLocalizedString(@"Not Used", nil), NSLocalizedString(@"Jump Forward", nil), NSLocalizedString(@"Jump Backward", nil), NSLocalizedString(@"Increase Playback Speed", nil), NSLocalizedString(@"Decrease Playback Speed", nil), NSLocalizedString(@"Play", nil), NSLocalizedString(@"Pause", nil), NSLocalizedString(@"Display Brightness", nil), NSLocalizedString(@"Volume Boost", nil)];
            gestures.settingsTitle = [_settingsArray objectAtIndex:indexPath.row];
            gestures.userDefault = [_userDefaultArray objectAtIndex:indexPath.row];
            gestures.userDefaultValue = [_valueArray objectAtIndex:indexPath.row];;
            gestures.doubleDetail = YES;
            [self.navigationController pushViewController:gestures animated:YES];
    }
    if (indexPath.row != 0) {
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}


@end
