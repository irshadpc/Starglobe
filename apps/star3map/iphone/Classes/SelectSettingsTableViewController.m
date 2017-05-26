//
//  SelectSettingsTableViewController.m
//  AVPlayerDemo
//
//  Created by Alex on 19/03/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "SelectSettingsTableViewController.h"

@implementation SelectSettingsTableViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _settingsTitle;
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_subtitlePicker) {
        for (int i = 0; i< _settingsArray.count; i++) {
             if ([[_settingsArray objectAtIndex:i] isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"SubtitleFont"]]) {
                 [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                 break;
        }
        }
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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0];
    cell.tintColor = [UIColor redColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (_subtitlePicker) {
        if ([cell.textLabel.text isEqualToString:[[NSUserDefaults standardUserDefaults]valueForKey:@"SubtitleFont"]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        cell.textLabel.font = [UIFont fontWithName:[_settingsArray objectAtIndex:indexPath.row] size:16.0];
    } else {
        if (_userDefaultValue != nil) {
            if (indexPath.row == [[NSUserDefaults standardUserDefaults]integerForKey:_userDefaultValue] && [[NSUserDefaults standardUserDefaults]integerForKey:_userDefault] == _userDefaultSetValue) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        } else {
            if (indexPath.row == [[NSUserDefaults standardUserDefaults]integerForKey:_userDefault]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *oldIndexPath;
    if (_userDefaultValue != nil) {
        oldIndexPath = [NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults]integerForKey:_userDefaultValue] inSection:0];
        [[NSUserDefaults standardUserDefaults]setInteger:_userDefaultSetValue forKey:_userDefault];
        [[NSUserDefaults standardUserDefaults]setInteger:indexPath.row forKey:_userDefaultValue];
    } else {
        oldIndexPath = [NSIndexPath indexPathForRow:[[NSUserDefaults standardUserDefaults]integerForKey:_userDefault] inSection:0];
        [[NSUserDefaults standardUserDefaults]setInteger:indexPath.row forKey:_userDefault];
    }
    
    [self.tableView cellForRowAtIndexPath:oldIndexPath].accessoryType = UITableViewCellAccessoryNone;
    [self.tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    if (_subtitlePicker) {
    [[NSUserDefaults standardUserDefaults]setValue:[_settingsArray objectAtIndex:indexPath.row] forKey:@"SubtitleFont"];
    }
    if ([_userDefault isEqualToString:@"DisplayMode"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeLayout" object:nil];
    }
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
