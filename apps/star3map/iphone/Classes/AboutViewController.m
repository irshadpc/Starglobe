//
//  AboutViewController.m
//  CarbonWorkout
//
//  Created by Kevin Carbone on 5/13/14.
//  Copyright (c) 2014 Kevin Carbone. All rights reserved.
//

#import "AboutViewController.h"
#import "WBMailChimp.h"
#import "SupportViewController.h"

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"About", nil);
    
    _logoView = [[UIImageView alloc]init];
    _logoView.frame = CGRectMake((self.view.frame.size.width-300)/2,self.navigationController.navigationBar.frame.size.height + 30,300,168);
    _logoView.image = [UIImage imageNamed:@"azurcoding"];
    _logoView.contentMode = UIViewContentModeScaleToFill;
    [self.view addSubview:_logoView];
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];

    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.navigationController.toolbarHidden = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            if ([cell.contentView subviews]){
                for (UIView *subview in [cell.contentView subviews]) {
                    [subview removeFromSuperview];
                }
            }
            
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            [cell addSubview:_logoView];
            _logoView.frame = CGRectMake((cell.frame.size.width-300)/2, 15,300,168);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Like us on Facebook", nil);
            cell.detailTextLabel.text = @"fb.com/azurcoding";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Follow us on Twitter", nil);
            cell.detailTextLabel.text = @"@azurcoding";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 2) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Follow us on Instagram", nil);
            cell.detailTextLabel.text = @"azurcoding";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsDetailTableViewCell" forIndexPath:indexPath];
            cell.textLabel.text = NSLocalizedString(@"Website", nil);
            cell.detailTextLabel.text = @"azurcoding.com";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        } else if (indexPath.row == 4) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsTableViewCell" forIndexPath:indexPath];
            if ([cell.contentView subviews]){
                for (UIView *subview in [cell.contentView subviews]) {
                    [subview removeFromSuperview];
                }
            }
            cell.textLabel.text = NSLocalizedString(@"Get Email Newsletter", nil);
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }
    }
    
    cell.detailTextLabel.hidden = NO;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor colorWithRed:31.0/255.0 green:31.0/255.0 blue:31.0/255.0 alpha:1.0];
    cell.layoutMargins = UIEdgeInsetsZero;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self facebookLike];
        } else if (indexPath.row == 1) {
            [self twitterFollow];
        } else if (indexPath.row == 2) {
            [self instagramFollow];
        } else if (indexPath.row == 3) {
            [self openWebsite];
        } else if (indexPath.row == 4) {
            [self subscribe];
        }
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSString*) tableView:(UITableView *) tableView titleForHeaderInSection:(NSInteger)section{
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 && indexPath.section == 0) {
        return 200;
    }
    
    return 44;
}

- (NSString*) tableView:(UITableView *) tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0) {
        return NSLocalizedString(@" ", nil);
    }
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

- (void)openWebsite{
    NSURL *urlSite = [NSURL URLWithString:@"http://azurcoding.com"];
    [[UIApplication sharedApplication] openURL:urlSite];
}

-(void)contactUs{
    if ([SupportViewController canSendMail]){
        SupportViewController *mail = [[SupportViewController alloc] init];
        [mail navigationBar].barStyle = UIBarStyleBlack;
       // [[mail navigationBar] setBarTintColor:blackButtonColor];
        [[mail navigationBar] setTintColor:[UIColor redColor]];
        
        mail.mailComposeDelegate = self;
        [mail setToRecipients:@[@"support@azurcoding.com"]];
        
        [self presentViewController:mail animated:YES completion:nil];
    } else {
        NSURL *urlSite = [NSURL URLWithString:@"http://azurcoding.com"];
        [[UIApplication sharedApplication] openURL:urlSite];
    }
}


- (void)facebookLike{
    NSURL *urlApp = [NSURL URLWithString:@"fb://profile/131790290201423"];
    NSURL *urlSite = [NSURL URLWithString:@"http://facebook.com/azurcoding"];
    
    if ([[UIApplication sharedApplication] canOpenURL:urlApp]){
        [[UIApplication sharedApplication] openURL:urlApp];
    } else {
        [[UIApplication sharedApplication] openURL:urlSite];
    }
}

- (void)twitterFollow{
    NSArray *urls = [NSArray arrayWithObjects:
                     @"twitter://user?screen_name={handle}", // Twitter
                     @"tweetbot:///user_profile/{handle}", // TweetBot
                     @"echofon:///user_timeline?{handle}", // Echofon
                     @"twit:///user?screen_name={handle}", // Twittelator Pro
                     @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
                     @"x-birdfeed://user?screen_name={handle}", // Birdfeed
                     @"tweetings:///user?screen_name={handle}", // Tweetings
                     @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
                     @"icebird://user?screen_name={handle}", // IceBird
                     @"fluttr://user/{handle}", // Fluttr
                     @"http://twitter.com/{handle}",
                     nil];
    
    UIApplication *application = [UIApplication sharedApplication];
    
    for (NSString *candidate in urls) {
        NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:@"azurcoding"]];
        if ([application canOpenURL:url]) {
            [application openURL:url];
            // Stop trying after the first URL that succeeds
            return;
        }
    }
}

- (void)instagramFollow{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://user?username=azurcoding"];
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        [[UIApplication sharedApplication] openURL:instagramURL];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://instagram.com/azurcoding"]];
    }
}


- (void)subscribe{
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:NSLocalizedString(@"Get Email Newsletter", nil)
                                          message:nil
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action){
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Subscribe", nil)
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                                   UITextField *nameField = alertController.textFields.firstObject;
                                   [WBMailChimp addEmail:nameField.text toList:@"b21d62d9b6" resBlock:^(BOOL success,NSError *err){
                                       if (success) {
                                           NSLog(@"Added successfully");
                                       } else {
                                           NSLog(@"Failed to add: %@",err.localizedDescription);
                                       }
                                   }];
                                   
                               }];
    okAction.enabled = NO;
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = NSLocalizedString(@"Email", nil);
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        
        [textField addTarget:self
                      action:@selector(alertTextFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alertController animated:YES completion:nil];
    });
}


- (IBAction)closeAbout:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
       
        [self.tableView reloadData];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        
    }];
}


- (void)alertTextFieldDidChange:(UITextField *)sender{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController){
        UITextField *nameField = alertController.textFields.firstObject;
        UIAlertAction *okAction = alertController.actions.lastObject;
        if (nameField.text.length > 0) {
            okAction.enabled = YES;
        } else {
            okAction.enabled = NO;
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

@end
