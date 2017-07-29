//
//  StarDetailViewController.m
//  Starglobe
//
//  Created by Alex on 29/05/2017.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import "StarDetailViewController.h"
#import "XMLDictionary.h"
#import "MultilineTableViewCell.h"
#import "Ono.h"


@interface StarDetailViewController ()

@end

@implementation StarDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = _viewTitle;
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    self.tableView.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1.0];
    [self.tableView setSeparatorColor:[UIColor darkGrayColor]];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.navigationController.toolbarHidden = YES;
    self.tableView.estimatedRowHeight = 100.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    _imageArray = [NSMutableArray array];
    _characteristicsArray = [NSMutableArray array];
    _characteristicsValueArray = [NSMutableArray array];
    _descriptionArray = [NSMutableArray array];
    _linkArray = [NSMutableArray array];
    
    NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[_contentFile lowercaseString] ofType:@"xml"]];
    NSError *error;
    
    ONOXMLDocument *document = [ONOXMLDocument XMLDocumentWithData:data error:&error];
    
    for (ONOXMLElement *images in [[document.rootElement firstChildWithTag:@"images"] children]) {
        [_imageArray addObject:[images stringValue]];
    }
    
    for (ONOXMLElement *images in [document.rootElement childrenWithTag:@"information"] ) {
        [_descriptionArray addObject:[images stringValue]];
    }
    
    for (ONOXMLElement *images in [document.rootElement childrenWithTag:@"link"] ) {
        [_linkArray addObject:[images stringValue]];
    }
    
    for (ONOXMLElement *images in [[document.rootElement firstChildWithTag:@"characteristics"] children]) {
        [_characteristicsArray addObject:images[@"name"]];
        [_characteristicsValueArray addObject:[images stringValue]];
    }
    
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 && _imageArray.count > 0) {
        return 200;
    }
    
        return UITableViewAutomaticDimension;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    int numberOfSections;
    if (_imageArray.count > 0) {
        numberOfSections++;
    }
    if (_descriptionArray.count > 0) {
        numberOfSections++;
    }
    
    if (_characteristicsArray.count > 0) {
        numberOfSections++;
    }
    
    return numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && _imageArray.count > 0) {
        return 1;
    }
    
    if (section == 1 && _characteristicsArray.count > 0) {
        return _characteristicsArray.count;
    }
    
    if (section == 2 && _descriptionArray.count > 0) {
        return 1;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;// = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];

    
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageCell"];
            
        }
        cell.textLabel.text = nil;
        for (int i = 0; i < _imageArray.count; i++) {
            UIImage *image = [UIImage imageNamed:[_imageArray objectAtIndex:i]];
            if (image != nil) {
                UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake((cell.frame.size.width - 198)/2, 0, 198, 198)];
                imageView.image = image;
                [cell addSubview:imageView];
                break;
            }
        }
    } else if (indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CharacteristicsCell" forIndexPath:indexPath];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CharacteristicsCell"];
            
        }
        cell.textLabel.text = [_characteristicsArray objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = [_characteristicsValueArray objectAtIndex:indexPath.row];
        
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"DescriptionCell" forIndexPath:indexPath];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DescriptionCell"];
            
        }
        cell.textLabel.text = [_descriptionArray objectAtIndex:0];
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.detailTextLabel.numberOfLines = 0;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textColor = [UIColor lightGrayColor];
   // cell.textLabel.font = [UIFont boldSystemFontOfSize:[UIFont labelFontSize]];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    cell.backgroundColor = self.tableView.backgroundColor;
    
    
    return cell;
}


- (void)viewDidLayoutSubviews {
    [self.bannerView setFrame:CGRectMake(0, self.view.frame.size.height - _bannerView.frame.size.height, _bannerView.frame.size.width, _bannerView.frame.size.height)];
}

@end
