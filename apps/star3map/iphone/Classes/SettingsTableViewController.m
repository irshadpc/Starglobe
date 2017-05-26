//
//  SettingsTableViewController.m
//  AVPlayerDemo
//
//  Created by Alex on 08/03/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "SettingsDetailTableViewController.h"
#import "SelectSettingsTableViewController.h"
#import "UpgradeViewController.h"
#import "TDBadgedCell.h"
#import "AboutViewController.h"
#import "UIAlertController+Blocks.h"
#import "SupportViewController.h"

@interface SettingsTableViewController ()

@end

@implementation SettingsTableViewController

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Settings", nil);
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.navigationController.toolbarHidden = YES;
    
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.square = NO;
    self.HUD.minShowTime = 1.f;
    self.HUD.userInteractionEnabled = YES;
    
    [self.view addSubview:self.HUD];
        
#ifdef STARGLOBE_FREE
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Upgrade", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showUpgrade)];
#endif    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData]; // to reload selected cell
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
    if ([[GeneralHelper sharedManager]freeVersion]) {
        return 7;
    } else {
        return 6;
    }
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 3;
    } else if (section == 1) {
        if ([[GeneralHelper sharedManager]freeVersion]) {
            return 2;
        } else {
            return 2;
        }
    } else if (section == 2) {
#ifdef STARGLOBE_FREE
        return 2;
#endif
#ifdef PROPLAYER_PRO
        return 2;
#endif
    } else if (section == 3) {
#ifdef STARGLOBE_FREE
        return 2;
#endif
#ifdef PROPLAYER_PRO
        return 4;
#endif
    } else if (section == 4){
#ifdef STARGLOBE_FREE
        return 4;
#endif
#ifdef PROPLAYER_PRO
        return 4;
#endif
    } else if (section == 5){
#ifdef STARGLOBE_FREE
        return 4;
#endif
#ifdef PROPLAYER_PRO
        return 4;
#endif
    } else if (section == 6){
#ifdef STARGLOBE_FREE
        return 4;
#endif
#ifdef PROPLAYER_PRO
        return 4;
#endif
    }
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    TDBadgedCell *badgeCell;// = [[TDBadgedCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BadgedCell"];

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Fetch Metadata", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *playNextSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            playNextSwitch.onTintColor = [UIColor redColor];
            cell.accessoryView = playNextSwitch;
            if ([[NSUserDefaults standardUserDefaults]integerForKey:@"FetchMetadata"] == 0) {
                [playNextSwitch setOn:NO animated:NO];
            } else {
                [playNextSwitch setOn:YES animated:NO];
            }
            [playNextSwitch addTarget:self action:@selector(fetchMetadata:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Metadata Help", nil);
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Clear Metadata", nil);
            cell.textLabel.textColor = [UIColor redColor];
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    
#ifdef PROPLAYER_PRO
    if (indexPath.section == 1) {
        
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Use Passcode", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *passCodeSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            passCodeSwitch.onTintColor = [UIColor redColor];
            cell.accessoryView = passCodeSwitch;
            if ([[NSUserDefaults standardUserDefaults]integerForKey:@"UsePasscode"] == 0) {
                [passCodeSwitch setOn:NO animated:NO];
            } else {
                [passCodeSwitch setOn:YES animated:NO];
            }
            [passCodeSwitch addTarget:self action:@selector(enablePasscode:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Change Passcode", nil);
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryView = nil;
        }
    }
    
    if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Automatically Play Next Video", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *playNextSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            playNextSwitch.onTintColor = [UIColor redColor];
            cell.accessoryView = playNextSwitch;
            if ([[NSUserDefaults standardUserDefaults]integerForKey:@"AutoPlayNextVideo"] == 0) {
                [playNextSwitch setOn:NO animated:NO];
            } else {
                [playNextSwitch setOn:YES animated:NO];
            }
            [playNextSwitch addTarget:self action:@selector(enableAutoPlay:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Background Playback", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *backgroundPlaybackSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            backgroundPlaybackSwitch.onTintColor = [UIColor redColor];
            cell.accessoryView = backgroundPlaybackSwitch;
            if ([[NSUserDefaults standardUserDefaults]integerForKey:@"BackgroundPlayback"] == 0) {
                [backgroundPlaybackSwitch setOn:NO animated:NO];
            } else {
                [backgroundPlaybackSwitch setOn:YES animated:NO];
            }
            [backgroundPlaybackSwitch addTarget:self action:@selector(enableBackgroundPlayback:) forControlEvents:UIControlEventValueChanged];
        }
    }
    
    if (indexPath.section == 3) {
        NSArray *colorArray = @[NSLocalizedString(@"White", nil), NSLocalizedString(@"Black", nil), NSLocalizedString(@"Red", nil), NSLocalizedString(@"Blue", nil), NSLocalizedString(@"Green", nil), NSLocalizedString(@"Yellow", nil), NSLocalizedString(@"Gray", nil), NSLocalizedString(@"Purple", nil)];
        NSArray *backgroundColorArray = @[NSLocalizedString(@"Transparent", nil), NSLocalizedString(@"White", nil), NSLocalizedString(@"Black", nil), NSLocalizedString(@"Red", nil), NSLocalizedString(@"Blue", nil), NSLocalizedString(@"Green", nil), NSLocalizedString(@"Yellow", nil), NSLocalizedString(@"Gray", nil), NSLocalizedString(@"Purple", nil)];
        NSArray *subtitleEncoding = @[@"Universal (UTF-8)", @"Eastern European (Windows-1250)", @"Cyrillic (Windows-1251)", @"Western European (Windows-1252)", @"Greek (Windows-1253)", @"Turkish (Windows-1254)", @"Baltic (Windows-1257)", @"Russian (KOI8-R)", @"Russian (KOI8-RU)", @"Ukrainian (KOI8-U)", @"ASCII"]; //@[@"Universal (UTF-8)", @"Universal (UTF-16)", @"Universal (big endian UTF-16)", @"Universal (little endian UTF-16)", @"Western (Mac OS Roman)",@"Western European (Latin-9)", @"Western European (Windows-1252)", @"Eastern European (Latin-2)", @"Eastern European (Windows-1250)", @"Esperanto (Latin-3)", @"Nordic (Latin-6)", @"South-Eastern European (Latin-10)", @"Baltic (Latin-7)", @"Baltic (Windows-1257)", @"Celtic (Latin-8)", @"Greek (Windows-1253)", @"Greek (ISO 8859-7)", @"Universal, Chinese (GB 18030)", @"Simplified Chinese (ISO-2022-CN-EXT)", @"Simplified Chinese Unix (EUC-CN)", @"Traditional Chinese (Big 5)", @"Traditional Chinese Unix (EUC-TW)", @"Hong-Kong Supplementary (HKSCS)", @"Japanese (7-bits JIS/ISO-2022-JP-2)", @"Japanese Unix (EUC-JP)", @"Japanese (Shift JIS)", @"Cyrillic (Windows-1251)", @"Russian (KOI8-R)", @"Ukrainian (KOI8-U)", @"Arabic (ISO 8859-6)", @"Arabic (Windows-1256)", @"Hebrew (ISO 8859-8)", @"Hebrew (Windows-1255)", @"Turkish (ISO 8859-9)", @"Turkish (Windows-1254)", @"Thai (TIS 620-2533/ISO 8859-11)", @"Thai (Windows-874)", @"Korean (EUC-KR/CP949)", @"Korean (ISO-2022-KR)", @"Vietnamese (VISCII)", @"Vietnamese (Windows-1258)"];
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Subtitle Text Color", nil);
            cell.detailTextLabel.text = [colorArray objectAtIndex:[[NSUserDefaults standardUserDefaults]integerForKey:@"SubtitleTextColor"]];
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Subtitle Background Color", nil);
            cell.detailTextLabel.text = [backgroundColorArray objectAtIndex:[[NSUserDefaults standardUserDefaults]integerForKey:@"SubtitleBackgroundColor"]];
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Subtitle Font", nil);
            cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults]valueForKey:@"SubtitleFont"];
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Subtitle Encoding", nil);
            cell.detailTextLabel.text = [subtitleEncoding objectAtIndex:[[NSUserDefaults standardUserDefaults]integerForKey:@"SubtitleEncoding"]];
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.accessoryView = nil;
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Use Gestures", nil);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UISwitch *playNextSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
            playNextSwitch.onTintColor = [UIColor redColor];
            cell.accessoryView = playNextSwitch;
            if ([[NSUserDefaults standardUserDefaults]integerForKey:@"UseGestures"] == 0) {
                [playNextSwitch setOn:NO animated:NO];
            } else {
                [playNextSwitch setOn:YES animated:NO];
            }
            [playNextSwitch addTarget:self action:@selector(enableGestures:) forControlEvents:UIControlEventValueChanged];
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"1-Finger Gestures", nil);
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryView = nil;
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"2-Finger Gestures", nil);
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryView = nil;
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"3-Finger Gestures", nil);
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.accessoryView = nil;
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Rate ProPlayer on the App Store", nil);
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Share with Friends", nil);
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"About", nil);
            cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsNoDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Contact Us", nil);
            cell.accessoryView = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
        cell.accessoryView = nil;
    }
    
    cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0];

    
    if (indexPath.section == 5) {
        if (indexPath.row == 3) {
            cell.textLabel.textColor = [UIColor redColor];
        }
    }
#endif
    
    return cell;
}

- (void)fetchMetadata:(id)sender {
    UISwitch *switchControl = sender;
    if (switchControl.isOn) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"FetchMetadata"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"FetchMetadata"];
    }
}

- (void)enableFileExtension:(id)sender {
    UISwitch *switchControl = sender;
    if (switchControl.isOn) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"ShowFileExtension"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"ShowFileExtension"];
    }
}

- (void)enableFileInfo:(id)sender {
    UISwitch *switchControl = sender;
    if (switchControl.isOn) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"ShowFileInfo"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"ShowFileInfo"];
    }
}



- (void)enableAutoPlay:(id)sender {
    UISwitch *switchControl = sender;
    if (switchControl.isOn) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"AutoPlayNextVideo"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"AutoPlayNextVideo"];
    }
}

- (void)enableBackgroundPlayback:(id)sender {
    UISwitch *switchControl = sender;
    if (switchControl.isOn) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"BackgroundPlayback"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MADParameterAllowBackgroundVideoPlayback"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"MADParameterAllowBackgroundAudioPlayback"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"BackgroundPlayback"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MADParameterAllowBackgroundVideoPlayback"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"MADParameterAllowBackgroundAudioPlayback"];
    }
}

- (void)enableGestures:(id)sender {
    UISwitch *switchControl = sender;
    if (switchControl.isOn) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"UseGestures"];
    } else {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"UseGestures"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if (indexPath.section == 0) {
        if (indexPath.row == 1) {

            
        }
}
    
#ifdef STARGLOBE_FREE
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self showUpgrade];
        } else if (indexPath.row == 1) {
            [self restorePurchase];
        }
    }
    
    if (indexPath.section == 2) {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ProEnabled"] == NO) {
            [self showUpgrade];
        } else {
        if (indexPath.row == 1) {
            
        }
        }
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 1) {
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ProEnabled"] == NO) {
                [self showUpgrade];
            }
        }
    }
    
   
    if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = @[NSLocalizedString(@"White", nil), NSLocalizedString(@"Black", nil), NSLocalizedString(@"Red", nil), NSLocalizedString(@"Blue", nil), NSLocalizedString(@"Green", nil), NSLocalizedString(@"Yellow", nil), NSLocalizedString(@"Gray", nil), NSLocalizedString(@"Purple", nil)];
            gestures.settingsTitle = NSLocalizedString(@"Subtitle Text Color", nil);
            gestures.userDefault = @"SubtitleTextColor";
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 1) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = @[NSLocalizedString(@"Transparent", nil), NSLocalizedString(@"White", nil), NSLocalizedString(@"Black", nil), NSLocalizedString(@"Red", nil), NSLocalizedString(@"Blue", nil), NSLocalizedString(@"Green", nil), NSLocalizedString(@"Yellow", nil), NSLocalizedString(@"Gray", nil), NSLocalizedString(@"Purple", nil)];
            gestures.settingsTitle = NSLocalizedString(@"Subtitle Background Color", nil);
            gestures.userDefault = @"SubtitleBackgroundColor";
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 2) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = [UIFont familyNames];
            gestures.settingsTitle = NSLocalizedString(@"Subtitle Font", nil);
            gestures.userDefault = @"SubtitleFontNumber";
            gestures.subtitlePicker = YES;
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 3) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = @[@"Universal (UTF-8)", @"Eastern European (Windows-1250)", @"Cyrillic (Windows-1251)", @"Western European (Windows-1252)", @"Greek (Windows-1253)", @"Turkish (Windows-1254)", @"Baltic (Windows-1257)", @"Russian (KOI8-R)", @"Russian (KOI8-RU)", @"Ukrainian (KOI8-U)", @"ASCII"];//@[@"Universal (UTF-8)", @"Universal (UTF-16)", @"Universal (big endian UTF-16)", @"Universal (little endian UTF-16)", @"Western (Mac OS Roman)",@"Western European (Latin-9)", @"Western European (Windows-1252)", @"Eastern European (Latin-2)", @"Eastern European (Windows-1250)", @"Esperanto (Latin-3)", @"Nordic (Latin-6)", @"South-Eastern European (Latin-10)", @"Baltic (Latin-7)", @"Baltic (Windows-1257)", @"Celtic (Latin-8)", @"Greek (Windows-1253)", @"Greek (ISO 8859-7)", @"Universal, Chinese (GB 18030)", @"Simplified Chinese (ISO-2022-CN-EXT)", @"Simplified Chinese Unix (EUC-CN)", @"Traditional Chinese (Big 5)", @"Traditional Chinese Unix (EUC-TW)", @"Hong-Kong Supplementary (HKSCS)", @"Japanese (7-bits JIS/ISO-2022-JP-2)", @"Japanese Unix (EUC-JP)", @"Japanese (Shift JIS)", @"Cyrillic (Windows-1251)", @"Russian (KOI8-R)", @"Ukrainian (KOI8-U)", @"Arabic (ISO 8859-6)", @"Arabic (Windows-1256)", @"Hebrew (ISO 8859-8)", @"Hebrew (Windows-1255)", @"Turkish (ISO 8859-9)", @"Turkish (Windows-1254)", @"Thai (TIS 620-2533/ISO 8859-11)", @"Thai (Windows-874)", @"Korean (EUC-KR/CP949)", @"Korean (ISO-2022-KR)", @"Vietnamese (VISCII)", @"Vietnamese (Windows-1258)"];
            gestures.settingsTitle = NSLocalizedString(@"Subtitle Encoding", nil);
            gestures.userDefault = @"SubtitleEncoding";
            [self.navigationController pushViewController:gestures animated:YES];
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0 && [[NSUserDefaults standardUserDefaults]boolForKey:@"ProEnabled"] == NO) {
            [self showUpgrade];
        }
        if (indexPath.row == 1) {
            SettingsDetailTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsDetail"];
            gestures.settingsTitle = NSLocalizedString(@"1-Finger Gestures", nil);
            gestures.settingsArray = @[NSLocalizedString(@"1-Finger Swipe Left", nil), NSLocalizedString(@"1-Finger Swipe Right", nil), NSLocalizedString(@"1-Finger Swipe Up", nil), NSLocalizedString(@"1-Finger Swipe Down", nil), NSLocalizedString(@"1-Finger Triple Tap", nil)];
            gestures.userDefaultArray = @[@"1FingerSwipeLeft", @"1FingerSwipeRight", @"1FingerSwipeUp", @"1FingerSwipeDown", @"1FingerTripleTap",];
            gestures.valueArray = @[@"1FingerSwipeLeftValue", @"1FingerSwipeRightValue", @"1FingerSwipeUpValue", @"1FingerSwipeDownValue", @"1FingerTripleTapValue"];
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 2) {
            SettingsDetailTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsDetail"];
            gestures.settingsTitle = NSLocalizedString(@"2-Finger Gestures", nil);
            gestures.settingsArray = @[NSLocalizedString(@"2-Finger Swipe Left", nil), NSLocalizedString(@"2-Finger Swipe Right", nil), NSLocalizedString(@"2-Finger Swipe Up", nil), NSLocalizedString(@"2-Finger Swipe Down", nil), NSLocalizedString(@"2-Finger Tap", nil), NSLocalizedString(@"2-Finger Double Tap", nil), NSLocalizedString(@"2-Finger Triple Tap", nil)];
            gestures.userDefaultArray = @[@"2FingerSwipeLeft", @"2FingerSwipeRight", @"2FingerSwipeUp", @"2FingerSwipeDown", @"2FingerTap", @"2FingerDoubleTap", @"2FingerTripleTap"];
            gestures.valueArray = @[@"2FingerSwipeLeftValue", @"2FingerSwipeRightValue", @"2FingerSwipeUpValue", @"2FingerSwipeDownValue", @"2FingerTapValue", @"2FingerDoubleTapValue", @"2FingerTripleTapValue"];
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 3) {
            SettingsDetailTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsDetail"];
            gestures.settingsTitle = NSLocalizedString(@"3-Finger Gestures", nil);
            gestures.settingsArray = @[NSLocalizedString(@"3-Finger Swipe Left", nil), NSLocalizedString(@"3-Finger Swipe Right", nil), NSLocalizedString(@"3-Finger Swipe Up", nil), NSLocalizedString(@"3-Finger Swipe Down", nil), NSLocalizedString(@"3-Finger Tap", nil), NSLocalizedString(@"3-Finger Double Tap", nil), NSLocalizedString(@"3-Finger Triple Tap", nil)];
            gestures.userDefaultArray = @[@"3FingerSwipeLeft", @"3FingerSwipeRight", @"3FingerSwipeUp", @"3FingerSwipeDown", @"3FingerTap", @"3FingerDoubleTap", @"3FingerTripleTap"];
            gestures.valueArray = @[@"3FingerSwipeLeftValue", @"3FingerSwipeRightValue", @"3FingerSwipeUpValue", @"3FingerSwipeDownValue", @"3FingerTapValue", @"3FingerDoubleTapValue", @"3FingerTripleTapValue"];
            [self.navigationController pushViewController:gestures animated:YES];
        }
    }
    
    if (indexPath.section == 6) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/proplayer-free-video-player/id1092587916?mt=8&at=11lS6z&ct=ProPlayerFree"]];
        } else if (indexPath.row == 1) {
            NSString *textToShare = NSLocalizedString(@"Check out ProPlayer for iOS - this app lets you play & stream video files of any type - without conversion.", nil);
            NSURL *urlToShare = [NSURL URLWithString:@"http://azurcoding.com/proplayer"];
            UIImage *shareImage = [UIImage imageNamed:@"sharebanner"];
            NSArray *itemsToShare = @[textToShare, urlToShare,shareImage];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
                activityVC.popoverPresentationController.sourceView = self.view;
                activityVC.popoverPresentationController.sourceRect = self.view.bounds;
                [activityVC.popoverPresentationController setPermittedArrowDirections:0];
            }
            [self presentViewController:activityVC animated:YES completion:nil];
        } else if (indexPath.row == 2) {
            [self showAbout];
        } else if (indexPath.row == 3){
            [self contactUs];
        }
    }
#endif
    
#ifdef PROPLAYER_PRO
    
    if (indexPath.section == 1) {
        if (indexPath.row == 1) {
            
        }
    }
    
    if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = @[NSLocalizedString(@"White", nil), NSLocalizedString(@"Black", nil), NSLocalizedString(@"Red", nil), NSLocalizedString(@"Blue", nil), NSLocalizedString(@"Green", nil), NSLocalizedString(@"Yellow", nil), NSLocalizedString(@"Gray", nil), NSLocalizedString(@"Purple", nil)];
            gestures.settingsTitle = NSLocalizedString(@"Subtitle Text Color", nil);
            gestures.userDefault = @"SubtitleTextColor";
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 1) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = @[NSLocalizedString(@"Transparent", nil), NSLocalizedString(@"White", nil), NSLocalizedString(@"Black", nil), NSLocalizedString(@"Red", nil), NSLocalizedString(@"Blue", nil), NSLocalizedString(@"Green", nil), NSLocalizedString(@"Yellow", nil), NSLocalizedString(@"Gray", nil), NSLocalizedString(@"Purple", nil)];
            gestures.settingsTitle = NSLocalizedString(@"Subtitle Background Color", nil);
            gestures.userDefault = @"SubtitleBackgroundColor";
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 2) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = [UIFont familyNames];
            gestures.settingsTitle = NSLocalizedString(@"Subtitle Font", nil);
            gestures.userDefault = @"SubtitleFontNumber";
            gestures.subtitlePicker = YES;
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 3) {
            SelectSettingsTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsSelect"];
            gestures.settingsArray = @[@"Universal (UTF-8)", @"Eastern European (Windows-1250)", @"Cyrillic (Windows-1251)", @"Western European (Windows-1252)", @"Greek (Windows-1253)", @"Turkish (Windows-1254)", @"Baltic (Windows-1257)", @"Russian (KOI8-R)", @"Russian (KOI8-RU)", @"Ukrainian (KOI8-U)", @"ASCII"];//@[@"Universal (UTF-8)", @"Universal (UTF-16)", @"Universal (big endian UTF-16)", @"Universal (little endian UTF-16)", @"Western (Mac OS Roman)",@"Western European (Latin-9)", @"Western European (Windows-1252)", @"Eastern European (Latin-2)", @"Eastern European (Windows-1250)", @"Esperanto (Latin-3)", @"Nordic (Latin-6)", @"South-Eastern European (Latin-10)", @"Baltic (Latin-7)", @"Baltic (Windows-1257)", @"Celtic (Latin-8)", @"Greek (Windows-1253)", @"Greek (ISO 8859-7)", @"Universal, Chinese (GB 18030)", @"Simplified Chinese (ISO-2022-CN-EXT)", @"Simplified Chinese Unix (EUC-CN)", @"Traditional Chinese (Big 5)", @"Traditional Chinese Unix (EUC-TW)", @"Hong-Kong Supplementary (HKSCS)", @"Japanese (7-bits JIS/ISO-2022-JP-2)", @"Japanese Unix (EUC-JP)", @"Japanese (Shift JIS)", @"Cyrillic (Windows-1251)", @"Russian (KOI8-R)", @"Ukrainian (KOI8-U)", @"Arabic (ISO 8859-6)", @"Arabic (Windows-1256)", @"Hebrew (ISO 8859-8)", @"Hebrew (Windows-1255)", @"Turkish (ISO 8859-9)", @"Turkish (Windows-1254)", @"Thai (TIS 620-2533/ISO 8859-11)", @"Thai (Windows-874)", @"Korean (EUC-KR/CP949)", @"Korean (ISO-2022-KR)", @"Vietnamese (VISCII)", @"Vietnamese (Windows-1258)"];
            gestures.settingsTitle = NSLocalizedString(@"Subtitle Encoding", nil);
            gestures.userDefault = @"SubtitleEncoding";
            [self.navigationController pushViewController:gestures animated:YES];
        }
    }
    
    if (indexPath.section == 4) {
        if (indexPath.row == 1) {
            SettingsDetailTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsDetail"];
            gestures.settingsTitle = NSLocalizedString(@"1-Finger Gestures", nil);
            gestures.settingsArray = @[NSLocalizedString(@"1-Finger Swipe Left", nil), NSLocalizedString(@"1-Finger Swipe Right", nil), NSLocalizedString(@"1-Finger Swipe Up", nil), NSLocalizedString(@"1-Finger Swipe Down", nil), NSLocalizedString(@"1-Finger Triple Tap", nil)];
            gestures.userDefaultArray = @[@"1FingerSwipeLeft", @"1FingerSwipeRight", @"1FingerSwipeUp", @"1FingerSwipeDown", @"1FingerTripleTap",];
            gestures.valueArray = @[@"1FingerSwipeLeftValue", @"1FingerSwipeRightValue", @"1FingerSwipeUpValue", @"1FingerSwipeDownValue", @"1FingerTripleTapValue"];
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 2) {
            SettingsDetailTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsDetail"];
            gestures.settingsTitle = NSLocalizedString(@"2-Finger Gestures", nil);
            gestures.settingsArray = @[NSLocalizedString(@"2-Finger Swipe Left", nil), NSLocalizedString(@"2-Finger Swipe Right", nil), NSLocalizedString(@"2-Finger Swipe Up", nil), NSLocalizedString(@"2-Finger Swipe Down", nil), NSLocalizedString(@"2-Finger Tap", nil), NSLocalizedString(@"2-Finger Double Tap", nil), NSLocalizedString(@"2-Finger Triple Tap", nil)];
            gestures.userDefaultArray = @[@"2FingerSwipeLeft", @"2FingerSwipeRight", @"2FingerSwipeUp", @"2FingerSwipeDown", @"2FingerTap", @"2FingerDoubleTap", @"2FingerTripleTap"];
            gestures.valueArray = @[@"2FingerSwipeLeftValue", @"2FingerSwipeRightValue", @"2FingerSwipeUpValue", @"2FingerSwipeDownValue", @"2FingerTapValue", @"2FingerDoubleTapValue", @"2FingerTripleTapValue"];
            [self.navigationController pushViewController:gestures animated:YES];
        } else if (indexPath.row == 3) {
            SettingsDetailTableViewController *gestures = [storyboard instantiateViewControllerWithIdentifier:@"settingsDetail"];
            gestures.settingsTitle = NSLocalizedString(@"3-Finger Gestures", nil);
            gestures.settingsArray = @[NSLocalizedString(@"3-Finger Swipe Left", nil), NSLocalizedString(@"3-Finger Swipe Right", nil), NSLocalizedString(@"3-Finger Swipe Up", nil), NSLocalizedString(@"3-Finger Swipe Down", nil), NSLocalizedString(@"3-Finger Tap", nil), NSLocalizedString(@"3-Finger Double Tap", nil), NSLocalizedString(@"3-Finger Triple Tap", nil)];
            gestures.userDefaultArray = @[@"3FingerSwipeLeft", @"3FingerSwipeRight", @"3FingerSwipeUp", @"3FingerSwipeDown", @"3FingerTap", @"3FingerDoubleTap", @"3FingerTripleTap"];
            gestures.valueArray = @[@"3FingerSwipeLeftValue", @"3FingerSwipeRightValue", @"3FingerSwipeUpValue", @"3FingerSwipeDownValue", @"3FingerTapValue", @"3FingerDoubleTapValue", @"3FingerTripleTapValue"];
            [self.navigationController pushViewController:gestures animated:YES];
        }
    }
    
    if (indexPath.section == 5) {
        if (indexPath.row == 0) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/proplayer-the-video-player/id454180376?mt=8&at=11lS6z&ct=ProPlayerPro"]];
        } else if (indexPath.row == 1) {
            NSString *textToShare = NSLocalizedString(@"Check out ProPlayer for iOS - this app lets you play & stream video files of any type - without conversion.", nil);
            NSURL *urlToShare = [NSURL URLWithString:@"http://azurcoding.com/proplayer"];
            UIImage *shareImage = [UIImage imageNamed:@"sharebanner"];
            NSArray *itemsToShare = @[textToShare, urlToShare,shareImage];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
            activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll]; //or whichever you don't need
            if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad){
                activityVC.popoverPresentationController.sourceView = self.view;
                activityVC.popoverPresentationController.sourceRect = self.view.bounds;
                [activityVC.popoverPresentationController setPermittedArrowDirections:0];
            }

            [self presentViewController:activityVC animated:YES completion:nil];
        } else if (indexPath.row == 2) {
            [self showAbout];
        } else if (indexPath.row == 3){
            [self contactUs];
        }
    }
#endif
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section{
#ifdef STARGLOBE_FREE
    if (section == 0) {
        return NSLocalizedString(@"Metadata", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Pro Upgrade", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Passcode", nil);
    } else if (section == 3) {
        return NSLocalizedString(@"Video Playback", nil);
    } else if (section == 4) {
        return NSLocalizedString(@"Subtitles", nil);
    } else if (section == 5) {
        return NSLocalizedString(@"Gestures", nil);
    }
    return NSLocalizedString(@"More", nil);
#endif
#ifdef PROPLAYER_PRO
    if (section == 0) {
        return NSLocalizedString(@"Metadata", nil);
    } else if (section == 1) {
        return NSLocalizedString(@"Passcode", nil);
    } else if (section == 2) {
        return NSLocalizedString(@"Video Playback", nil);
    } else if (section == 3) {
        return NSLocalizedString(@"Subtitles", nil);
    } else if (section == 4) {
        return NSLocalizedString(@"Gestures", nil);
    }
    return NSLocalizedString(@"More", nil);
#endif
}

- (NSString*) tableView:(UITableView *) tableView titleForFooterInSection:(NSInteger)section{
    #ifdef STARGLOBE_FREE
    if (section == 0) {
        return NSLocalizedString(@"ProPlayer can automatically fetch movie and tv series metadata like movie posters, descriptions etc.", nil);
    } else if (section == 2) {
        return [NSString stringWithFormat:NSLocalizedString(@"Use a Passcode to protect ProPlayer from unauthorized access, e.g. when you lend someone your %@.", @"%@ stands for iPhone/iPad"), [UIDevice currentDevice].model];
    } else if (section == 3) {
        return NSLocalizedString(@"Background Playback means that when you switch to another app while playing a video in ProPlayer, the audio continues to play in the background.", nil);
    }
    #endif
    #ifdef PROPLAYER_PRO
    if (section == 0) {
        return NSLocalizedString(@"ProPlayer can automatically fetch movie and tv series metadata like movie posters, descriptions etc.", nil);
    } else if (section == 1) {
        return [NSString stringWithFormat:NSLocalizedString(@"Use a Passcode to protect ProPlayer from unauthorized access, e.g. when you lend someone your %@.", @"%@ stands for iPhone/iPad"), [UIDevice currentDevice].model];
    } else if (section == 2) {
        return NSLocalizedString(@"Background Playback means that when you switch to another app while playing a video in ProPlayer, the audio continues to play in the background.", nil);
    }
    #endif
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

-(void)contactUs{
    if ([SupportViewController canSendMail]){
        SupportViewController *mail = [[SupportViewController alloc] init];
        [[mail navigationBar] setBarTintColor:[UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0]];
        [[mail navigationBar] setTintColor:[UIColor redColor]];
        
        mail.mailComposeDelegate = self;
        [mail setToRecipients:@[@"support@azurcoding.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    } else {
        NSURL *urlSite = [NSURL URLWithString:@"http://azurcoding.com"];
        [[UIApplication sharedApplication] openURL:urlSite];
    }
}

- (void)showUpgrade{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UpgradeViewController *manual = [storyboard instantiateViewControllerWithIdentifier:@"upgrade"];
    [self.navigationController pushViewController:manual animated:YES];
}

- (void)restorePurchase{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UpgradeViewController *manual = [storyboard instantiateViewControllerWithIdentifier:@"upgrade"];
    [self.navigationController pushViewController:manual animated:YES];
}

- (void)showAbout{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    AboutViewController *manual = [storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    [self.navigationController pushViewController:manual animated:YES];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

@end
