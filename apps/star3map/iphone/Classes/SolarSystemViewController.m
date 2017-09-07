//
//  MainViewController.m
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "SolarSystemViewController.h"
#import "UAAppReviewManager.h"

#define TAB_TITLE_PLANETS @"Planets"
#define TAB_TITLE_INFORMATION @"Info"

#define MAX_PLANETS_COUNT 1
#define MAX_DAYS_PER_SECOND_SPEED 3.0f

#define GS_DEFAULT_WORLD_IDENTIFIER @"earth"

@interface SolarSystemViewController ()

@property CMMotionManager *motionManager;

@property (strong) OpenGLView *glView;
@property (strong) SolarSystemScene *solarSystemScene;

@property (nonatomic, retain) UIView *bannerView;
@property (nonatomic, retain) UIImageView *iconView;
@property (nonatomic, retain) UILabel *headlineLabel;
@property (nonatomic, retain) UILabel *subtitleLabel;
@property (nonatomic, retain) UIButton *upgradeButton;
@property (nonatomic, retain) UIButton *overlayButton;

@property UIView *sidebarView;
@property UIView *tabSelectorMasterView;
@property UISegmentedControl *tabSelector;
@property UIView *sidebarTabViewContainer;
@property NSMutableDictionary *tabs;
@property UIImageView *arrowButton;
@property UIScrollView *infoView;

@property NSMutableDictionary *planetButtons;
@property NSMutableArray *extraPlanetButtonViewsToRemove;

// The navigation bar used on the sidebar
@property UINavigationBar *rightNavBar;

@property UIScrollView *scrollView;

// Scene scale most recently used, for pinching
@property CGFloat mostRecentSceneScale;

// The latest configuration, so we can reload when necessary
@property PlanetButton *selectedButton;

// Collection of views presented on the screen to be removed later (related to info tab)
@property NSMutableArray *infoViewsShown;

// Button to create a custom world
@property UIBarButtonItem *customWorldsButton;

@property CGFloat buttonsEmptiedTime;

@end

@implementation SolarSystemViewController

/*
 *  Retrieves the shared instance of this view
 */
+ (SolarSystemViewController *)sharedInstance
{
    // A static MainViewController instance as the shared instance
    static SolarSystemViewController *sharedInstance = nil;
    
    // If the shared instance is nil
    if(!sharedInstance) {
        
        // Create a shared instance
        sharedInstance = [[SolarSystemViewController alloc] init];
    }
    
    // Return the shared instance
    return sharedInstance;
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.glView setAllViewsPaused: NO];

    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)upgradePressed{
    [self.tabBarController setSelectedIndex:2];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] > 1 && [[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] % 5 == 0 && [[GeneralHelper sharedManager]freeVersion]) {
            [self.tabBarController setSelectedIndex:2];
    } else if ([[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] > 1 && [[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] % 10 == 0 && [[GeneralHelper sharedManager]freeVersion]) {
        if ([UIDevice currentDevice].systemVersion.floatValue >= 10.3) {
            [SKStoreReviewController requestReview];
        } else {
            [UAAppReviewManager showPrompt];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setInteger:[[NSUserDefaults standardUserDefaults]integerForKey:@"InterstitialCounter"] + 1 forKey:@"InterstitialCounter"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.lastContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:nil];
}

- (void)cleanUp{
    self.lastContext = [EAGLContext currentContext];
    [EAGLContext setCurrentContext:nil];
    [self.glView setAllViewsPaused: YES];
}

- (void)restart{
    [self.glView setAllViewsPaused: NO];
}

-(void)dealloc{ NSLog(@"dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.navigationItem setTitle:@"Solar System"];
    self.view.backgroundColor = [UIColor blackColor];
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    bounds.size.height = bounds.size.height - 93;
    
    // Define some values for sizes and positions
    const NSInteger screenWidth = bounds.size.width;
    const NSInteger screenHeight = bounds.size.height;
    const NSInteger sideBarWidth = 0;
    
    self.infoViewsShown = [NSMutableArray array];
    
    BOOL showGLUnderSidebar = NO;
    CGFloat sidebarAlpha = showGLUnderSidebar ? 0.75f : 1.0f;
    
    // Create a view for rendering things!
    self.glView = [[OpenGLView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - (showGLUnderSidebar ? 0.0f : sideBarWidth), screenHeight)];
    [STexture setMasterView:self.glView];
    [self.view addSubview:self.glView];
    
    // Create a scene to play out the simulations
    self.solarSystemScene = [[SolarSystemScene alloc] init];
    [self.glView presentScene:self.solarSystemScene];
    
    // Setup the thing off the side underneath the sidebar
    if(showGLUnderSidebar) {
        CGFloat aspectRatio = CGRectGetWidth(self.glView.frame) / CGRectGetHeight(self.glView.frame);
        CGFloat coreViewWidth = screenWidth - sideBarWidth;
        CGFloat width = 2.0f;
        CGFloat height = width / aspectRatio * (screenWidth / coreViewWidth);
        self.solarSystemScene.projectionRect = CGRectMake(-width / 2.0f,
                                                          -height / 2.0f,
                                                          width * (screenWidth / coreViewWidth),
                                                          height);
    }
    
    UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(planetInfomation:)];
    [self.navigationItem setLeftBarButtonItem:infoButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismiss)];
    
    CGRect scrollViewFrame;
    scrollViewFrame.origin.x = 0;
    scrollViewFrame.origin.y = screenHeight - 75;
    scrollViewFrame.size.height = 75;
    scrollViewFrame.size.width = screenWidth;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
    self.scrollView.backgroundColor = [UIColor colorWithWhite:0.14f alpha:sidebarAlpha];
    [self.view addSubview:self.scrollView];
    
    // Add a pinch gesture recognizer to handle the zooming
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchScene:)];
    [pinch requireGestureRecognizerToFail:self.solarSystemScene.swipeGesture];
    [self.glView addGestureRecognizer:pinch];
    self.mostRecentSceneScale = self.solarSystemScene.focusDistanceFactor;
    
    // Load the default configuration
    [self setupDefaultConfiguration];
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    CGRect viewFrame = self.view.frame;
    self.infoView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 1, viewFrame.size.width-20, viewFrame.size.height-44-75-20 - 33)];
    self.infoView.alpha = 0.8f;
    self.infoView.backgroundColor = self.scrollView.backgroundColor;
    self.infoView.alpha = 0.0f;
    [self.view addSubview:self.infoView];
    
    [self populateScrollView];
    
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
        [_bannerView setFrame:CGRectMake(0, 00, self.view.frame.size.width, 60)];
        [_iconView setFrame:CGRectMake(5, 5, 50, 50)];
        [_headlineLabel setFrame:CGRectMake(65, 5, self.view.frame.size.width - 175, 20)];
        [_subtitleLabel setFrame:CGRectMake(65, 24, self.view.frame.size.width - 175, 35)];
        [_upgradeButton setFrame:CGRectMake(_headlineLabel.frame.origin.x + _headlineLabel.frame.size.width + 10, 0, 100, 60)];
        [_overlayButton setFrame:_bannerView.frame];
    }
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetScrollingAndLoopAgain:(UIScrollView *)view
{
    [UIView animateWithDuration:1.0f animations:^{
        
        view.contentOffset = CGPointZero;
        
    } completion:^(BOOL finished) {
        
        [self performSelector:@selector(loopScrolling:) withObject:view afterDelay:2.0f];
        
    }];
}

- (void)loopScrolling:(UIScrollView *)view
{
    CGFloat scrollSpeed = 60.0f; // Pixels per second
    CGFloat duration = (view.contentSize.height - view.contentOffset.y) / scrollSpeed;
    
    CGFloat maxContentOffset = view.contentSize.height - CGRectGetHeight(view.frame);
    
    [UIView animateWithDuration:duration delay:0.0f options:UIViewAnimationCurveLinear animations:^{
        
        view.contentOffset = CGPointMake(0.0f, maxContentOffset);
        
    } completion:^(BOOL finished) {
        
        [self performSelector:@selector(resetScrollingAndLoopAgain:) withObject:view afterDelay:2.0f];
        
    }];
    
}

#pragma mark - Gyroscope methods

- (void)beginGyroscope
{
    // If the gyroscope is available
    if([self.motionManager isGyroAvailable]) {
        
        /* Start the gyroscope if it is not active already */
        if([self.motionManager isGyroActive] == NO) {
            
            CGFloat updatesPerSecond = 20.0f;
            
            /* Update us a certain times a second */
            [self.motionManager setGyroUpdateInterval:(1.0f / updatesPerSecond)];
            
            /* Receive the gyroscope data on this block */
            [self.motionManager startGyroUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
                
                //if([AppSettings gyroEnabled]) {
                    
                    CGFloat orientationFactor = ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) ? -1.0f : 1.0f;
                    
                    CGFloat rotX = RadiansToDegrees(gyroData.rotationRate.y) * orientationFactor;
                    CGFloat rotY = RadiansToDegrees(gyroData.rotationRate.x);
                    
                    self.solarSystemScene.cameraAngularVelocity = CC3VectorMake(-rotX, -rotY, 0.0f);
               // }
                
            }];
        }
        
        // If the gyroscope is not available
    }else{
        NSLog(@"Gyroscope not Available!");
    }
}

- (void)stopGyroscope
{
    [self.motionManager stopGyroUpdates];
}

#pragma mark - Gesture callback methods

- (void)didPinchScene:(UIPinchGestureRecognizer *)pinch
{
    self.solarSystemScene.focusDistanceFactor = CLAMP(self.mostRecentSceneScale / pinch.scale, 3.0f, 100.0f);
    if(pinch.state == UIGestureRecognizerStateEnded) {
        self.mostRecentSceneScale = self.solarSystemScene.focusDistanceFactor;
    }
}

#pragma mark -

- (void)setupDefaultConfiguration
{
    self.solarSystemScene.passageOfTime = (24 * 60 * 60) / SECONDS_PER_DAY;
    [self selectWorldWithIdentifier:GS_DEFAULT_WORLD_IDENTIFIER];
}

- (void)clearWorldsButtons
{
    // NSLog(@"%i and %i", self.planetButtons.allValues.count, self.extraPlanetButtonViewsToRemove.count);
    
    // Remove all planet buttons from the list view
    for(PlanetButton *button in self.planetButtons.allValues) {
        [button removeFromSuperview];
    }
    // [self.planetButtons.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Remove all extra planet button views as well
    for(UIView *view in self.extraPlanetButtonViewsToRemove) {
        [view removeFromSuperview];
    }
    // [self.extraPlanetButtonViewsToRemove makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Remove all of the objects from both of the arrays
    [self.planetButtons removeAllObjects];
    [self.extraPlanetButtonViewsToRemove removeAllObjects];
    
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.scrollView.showsVerticalScrollIndicator = YES;
}

/*
 *  Reloads the available world list. Usually called when a change is made to the list of worlds.
 */
- (void)reloadAvailableWorlds
{
    self.buttonsEmptiedTime = CACurrentMediaTime();
    [self performSelector:@selector(reloadWorldButtonsTimer) withObject:nil afterDelay:1.3f];
}

- (void)reloadWorldButtonsTimer
{
    if(CACurrentMediaTime() - self.buttonsEmptiedTime > 1.0f) {
        
        [self.solarSystemScene removeAllBodies];
        
        [self clearWorldsButtons];
        
        // Repopulate the planets tab
        [self populateScrollView];
    }
}

- (void)populateScrollView
{
    NSMutableArray *spaceObjectsFinal = [NSMutableArray array];
    
    [WorldDataManager fetchAvailableBodyJsonForButtons:^(NSArray *spaceObjectsRaw) {
        for(NSDictionary *body in spaceObjectsRaw) {
            
            NSMutableDictionary *bodyMut = [body mutableCopy];
            [bodyMut setObject:[NSMutableArray array] forKey:@"_children"];
            if([[body valueForKey:@"parent"] isKindOfClass:[NSNull class]]) {
                [spaceObjectsFinal addObject:bodyMut];
            } else{
                NSString *parent = [body valueForKey:@"parent"];
                for(NSDictionary *potentialParent in spaceObjectsFinal) {
                    if([[potentialParent valueForKey:@"id"] isEqualToString:parent]) {
                        [[potentialParent objectForKey:@"_children"] addObject:bodyMut];
                    }
                }
            }
        }
        
        NSInteger index = 0;
        NSInteger buttonHeight = 75;
        NSInteger buttonWidth = 150;
        NSInteger childHeight = 75;
        NSInteger childIndent = buttonHeight - childHeight;
        NSInteger left = 0;
        
        for(NSDictionary *body in spaceObjectsFinal) {
            NSArray *children = [body objectForKey:@"_children"];
            
            CGRect buttonFrame = CGRectMake(left, 0, buttonWidth, buttonHeight);
            PlanetButton *button = [[PlanetButton alloc] initWithFrame:buttonFrame json:body];
            button.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.05f];
            button.baseBackgroundColor = button.backgroundColor;
            GSWorldData *data = [[GSWorldData alloc] initWithJson:body];
            
            
            left += buttonWidth;
            
            if (index > 7 && [[GeneralHelper sharedManager]freeVersion]) {
                void(^tappedBlock)(void) = ^{
                    [self.tabBarController setSelectedIndex:2];
                };
                
                [button setWasTapped:tappedBlock];
                UIImageView *recommendedBadge = [[UIImageView alloc]initWithFrame:CGRectMake(75,0, 75, 20)];
                recommendedBadge.tintColor = [UIColor redColor];
                recommendedBadge.image = [[UIImage imageNamed:@"badge"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
                [button addSubview:recommendedBadge];
                
                UILabel *badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 75, 20)];
                badgeLabel.text = NSLocalizedString(@"Pro", nil);
                badgeLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:17];
                badgeLabel.textAlignment = NSTextAlignmentCenter;
                badgeLabel.textColor = [UIColor whiteColor];
                [recommendedBadge addSubview:badgeLabel];
            } else {
                void(^tappedBlock)(void) = ^{
                    [self tappedPlanetButton:button];
                };
                
                [button setWasTapped:tappedBlock];
            }
            
            
            
            [self.scrollView addSubview:button];
            [self.planetButtons setObject:button forKey:data.identifier];
            
            index++;
            
            for(NSDictionary *child in children) {
                
                CGRect childFrame = CGRectMake(left, 0, buttonWidth, childHeight);
                UIView *blackView = [[UIView alloc] initWithFrame:childFrame];
                blackView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.35f];
                [self.scrollView addSubview:blackView];
                
                CGRect innerChildFrame = CGRectMake(childIndent, 0, CGRectGetWidth(blackView.bounds) - childIndent, CGRectGetHeight(blackView.bounds));
                PlanetButton *childButton = [[PlanetButton alloc] initWithFrame:innerChildFrame json:child];
                childButton.baseBackgroundColor = childButton.backgroundColor;
                GSWorldData *childData = [[GSWorldData alloc] initWithJson:child];
                
                
                
                if (index > 7 && [[GeneralHelper sharedManager]freeVersion]) {
                    void(^childTappedBlock)(void) = ^{
                        [self.tabBarController setSelectedIndex:2];
                    };
                    
                    [childButton setWasTapped:childTappedBlock];
                    UIImageView *recommendedBadge = [[UIImageView alloc]initWithFrame:CGRectMake(75,0, 75, 20)];
                    recommendedBadge.tintColor = [UIColor redColor];
                    recommendedBadge.image = [[UIImage imageNamed:@"badge"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];;
                    [childButton addSubview:recommendedBadge];
                    
                    UILabel *badgeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 75, 20)];
                    badgeLabel.text = NSLocalizedString(@"Pro", nil);
                    badgeLabel.font = [UIFont fontWithName:@"GillSans-SemiBold" size:17];
                    badgeLabel.textAlignment = NSTextAlignmentCenter;
                    badgeLabel.textColor = [UIColor whiteColor];
                    [recommendedBadge addSubview:badgeLabel];
                } else {
                    void(^childTappedBlock)(void) = ^{
                        [self tappedPlanetButton:childButton];
                    };
                    
                    [childButton setWasTapped:childTappedBlock];
                }
                
                [blackView addSubview:childButton];
                [self.planetButtons setObject:childButton forKey:childData.identifier];
                
                [self.extraPlanetButtonViewsToRemove addObject:blackView];
                
                left += buttonWidth;
                
                index++;
            }

        }
        
        [self.scrollView setContentSize:CGSizeMake(left, buttonHeight)];
        [self.scrollView setDirectionalLockEnabled:YES];
        [self.scrollView setContentOffset:CGPointMake(buttonWidth * 2, 0) animated:YES];
        [self loadDescriptionInfoWithIdentifier:@"earth"];
        
    }];
}

#pragma mark - Selecting worlds to view

/*
 *  Called when the user taps the planet button and handles displaying the newly selected world.
 */
- (void)tappedPlanetButton:(PlanetButton *)button
{
    [self tappedPlanetButton:button skipChecks:NO];
}

- (void)tappedPlanetButton:(PlanetButton *)button skipChecks:(BOOL)skip
{
    if(!skip) {
        // If this is the same as the current button, return
        if([self.selectedButton.data.identifier isEqualToString:button.data.identifier]) {
            return;
        }
    }
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    
    // Deselect the previously selected button
    if(self.selectedButton) {
        self.selectedButton.backgroundColor = self.selectedButton.baseBackgroundColor;
    }
    
    // Save this as the selected button
    self.selectedButton = button;
    
    // Set the background color of the new selected button
    self.selectedButton.backgroundColor = [UIColor colorWithRed:74.f/255.f green:74.f/255.f blue:74.f/255.f alpha:1.0f];
    
    [UIView commitAnimations];
    
    // Select the world within the scene
    [self.solarSystemScene focusOnBodyWithIdentifier:self.selectedButton.data.identifier];
    
    // Load the description information
    [self loadDescriptionInfoWithIdentifier:self.selectedButton.data.identifier];
}

- (void)planetInfomation:(id)sender {
    if (self.infoView.alpha == 0) {
        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(planetInfomation:)];
        [self.navigationItem setLeftBarButtonItem:infoButton];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        
        self.infoView.alpha = 1.0f;
        [UIView commitAnimations];
    } else {
        UIBarButtonItem *infoButton = [[UIBarButtonItem alloc] initWithTitle:@"Info" style:UIBarButtonItemStylePlain target:self action:@selector(planetInfomation:)];
        [self.navigationItem setLeftBarButtonItem:infoButton];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        
        self.infoView.alpha = 0.0f;
        [UIView commitAnimations];
    }
}

/*
 *  Selects the world with the given identifier.
 */
- (void)selectWorldWithIdentifier:(NSString *)identifier
{
    // Loop through every button
    for(PlanetButton *button in self.planetButtons.allValues) {
        
        // If the button identifier is the same
        if([button.data.identifier isEqualToString:identifier]) {
            
            // Pretend we tapped that button
            [self tappedPlanetButton:button skipChecks:YES];
            
            // Return and stop checking buttons
            return;
        }
    }
    
    /*
     *  The lower part of this method, below this comment, are only called if the above did not work,
     *  like if the button is not yet initialized. So we just focus on it but do not show the world button
     *  as selected with the usual blue highlight. This is a price we pay for having things load asynchronusly.
     */
    
    // Select the world within the scene
    [self.solarSystemScene focusOnBodyWithIdentifier:identifier];
    
    // Load the description information
    [self loadDescriptionInfoWithIdentifier:identifier];
}

#pragma mark -

- (void)displayNoInformationMessage
{
    [self clearInfoView];
    
    UILabel *noInfoLabel = [[UILabel alloc] initWithFrame:self.infoView.bounds];
    noInfoLabel.backgroundColor = [UIColor clearColor];
    noInfoLabel.textColor = [UIColor whiteColor];
    noInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
    noInfoLabel.textAlignment = NSTextAlignmentCenter;
    noInfoLabel.text = @"No Info Available";
    [self.infoView addSubview:noInfoLabel];
    
    self.infoView.contentSize = CGSizeZero;
    
    [self.infoViewsShown addObject:noInfoLabel];
}

- (void)clearInfoView
{
    for(UIView *view in self.infoViewsShown) {
        [view removeFromSuperview];
    }
    [self.infoViewsShown removeAllObjects];
}

- (void)displayInformation:(NSDictionary *)info
{
    // Clear the info view
    [self clearInfoView];
    
    // Define the padding between the sections
    const NSInteger betweenSectionsPadding = 20;
    
    // Define the padding between title and subtitle
    const NSInteger betweenTitleSubtitlePadding = 10;
    
    // Define the master edge insets of the whole view
    const NSInteger mainPadding = 10;
    
    // Define the width of titles in the measurements section
    const CGFloat measurementTitleWidthPct = 0.65f;
    
    // The height of a measurement view
    const NSInteger measurementViewHeight = 36;
    
    // Define the padding between paragraphs
    const NSInteger paragraphPadding = 12;
    
    // Calculate the usable width
    const NSInteger usableWidth = CGRectGetWidth(self.infoView.frame) - 2 * mainPadding;
    
    NSString *title = [info valueForKey:@"title"];
    NSString *subtitle = [info valueForKey:@"subtitle"];
    NSArray *measurements = [info objectForKey:@"measurements"];
    NSArray *paragraphs = [info objectForKey:@"paragraphs"];
    NSString *backgroundName = [info valueForKey:@"background"];
    
    BOOL hasBackground = backgroundName && backgroundName.length > 0;
    BOOL hasSubtitle = subtitle && subtitle.length > 0;
    
    // Make a background image view
    if(hasBackground) {
        
        UIImage *bgImage = [UIImage imageNamed:backgroundName];
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.infoView.frame), (hasSubtitle ? 100 : 70))];
        bgView.image = bgImage;
        bgView.contentMode = UIViewContentModeScaleAspectFill;
        bgView.clipsToBounds = YES;
        
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.colors = @[
                            (id)([UIColor whiteColor].CGColor),
                            (id)([UIColor clearColor].CGColor)
                            ];
        gradient.frame = bgView.bounds;
        bgView.layer.mask = gradient;
        
        [self.infoView addSubview:bgView];
        
        [self.infoViewsShown addObject:bgView];
        
    }
    
    // Setup the current insertion value at the padding inset
    NSInteger insertionY = mainPadding;
    
    UILabel *masterTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainPadding, insertionY, usableWidth, 0)];
    masterTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:42];
    masterTitleLabel.text = title;
    masterTitleLabel.textColor = [UIColor whiteColor];
    masterTitleLabel.backgroundColor = [UIColor clearColor];
    masterTitleLabel.numberOfLines = 0;
    [masterTitleLabel sizeToFit];
    if(hasBackground) {
        masterTitleLabel.layer.shadowColor = [UIColor blackColor].CGColor;
        masterTitleLabel.layer.shadowOffset = CGSizeZero;
        masterTitleLabel.layer.shadowOpacity = 0.9f;
        masterTitleLabel.layer.shadowRadius = 10.0f;
    }
    [self.infoView addSubview:masterTitleLabel];
    [self.infoViewsShown addObject:masterTitleLabel];
    
    insertionY = CGRectGetMaxY(masterTitleLabel.frame);
    
    // If there is a subtitle
    if(hasSubtitle) {
        
        // Add padding after the main title
        insertionY += betweenTitleSubtitlePadding;
        
        // Create a label to store the subtitle and add it to the view
        UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainPadding, insertionY, usableWidth, 0)];
        subtitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        subtitleLabel.text = subtitle;
        subtitleLabel.textColor = [UIColor grayColor];
        subtitleLabel.backgroundColor = [UIColor clearColor];
        subtitleLabel.numberOfLines = 0;
        [subtitleLabel sizeToFit];
        if(hasBackground) {
            subtitleLabel.textColor = [UIColor whiteColor];
        }
        [self.infoView addSubview:subtitleLabel];
        [self.infoViewsShown addObject:subtitleLabel];
        
        // Update the insertion value
        insertionY = CGRectGetMaxY(subtitleLabel.frame);
        
    }
    
    if(measurements && measurements.count > 0) {
        
        // Put spacing between the sections
        insertionY += betweenSectionsPadding;
        [self addLineSeparatorWithInsertionY:insertionY title:@"STATISTICS"];
        insertionY += betweenSectionsPadding;
        
        // Determine the width of the view used by titles
        const NSInteger measurementViewWidth = usableWidth;
        const NSInteger measurementTitleWidth = measurementViewWidth * measurementTitleWidthPct;
        const NSInteger measurementValueWidth = measurementViewWidth * (1.0f - measurementTitleWidthPct);
        
        // Determine some frames for each section
        const CGRect measurementTitleFrame = CGRectMake(0, 0, measurementTitleWidth, measurementViewHeight);
        const CGRect measurementValueFrame = CGRectMake(measurementTitleWidth, 0, measurementValueWidth, measurementViewHeight);
        
        // Loop through each measurement in the array
        for(NSDictionary *measurement in measurements) {
            
            // Create a view for the entire measurement
            UIView *measurementView = [[UIView alloc] initWithFrame:CGRectMake(mainPadding, insertionY, measurementViewWidth, measurementViewHeight)];
            [self.infoView addSubview:measurementView];
            [self.infoViewsShown addObject:measurementView];
            
            // Create a label for the title of the measurement and add it to the view
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:measurementTitleFrame];
            titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            titleLabel.textColor = [UIColor whiteColor];
            titleLabel.text = [measurement valueForKey:@"title"];
            titleLabel.adjustsFontSizeToFitWidth = YES;
            [measurementView addSubview:titleLabel];
            
            // Create a label for the value of the measurement and add it to the view
            UILabel *valueLabel = [[UILabel alloc] initWithFrame:measurementValueFrame];
            valueLabel.font = [UIFont systemFontOfSize:16.0f];
            valueLabel.textColor = [UIColor whiteColor];
            valueLabel.attributedText = [self attributedStringForMeasurementValue:measurement];
            valueLabel.adjustsFontSizeToFitWidth = YES;
            valueLabel.textAlignment = NSTextAlignmentRight;
            [measurementView addSubview:valueLabel];
            
            // Move the insertion value down
            insertionY = CGRectGetMaxY(measurementView.frame);
            
        }
    }
    
    if(paragraphs && paragraphs.count > 0) {
        
        // Add some padding after the measurements
        insertionY += betweenSectionsPadding;
        [self addLineSeparatorWithInsertionY:insertionY title:[NSString stringWithFormat:@"About %@", title].uppercaseString];
        insertionY += betweenSectionsPadding;
        
        // Paragraph style for the label
        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrahStyle setLineSpacing:4];
        
        NSDictionary *paragraphLabelAttributes = @{
                                                   NSParagraphStyleAttributeName: paragrahStyle,
                                                   NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:13],
                                                   NSForegroundColorAttributeName: [UIColor whiteColor]
                                                   };
        
        for(NSString *paragraph in paragraphs) {
            
            // Make a frame for the label
            CGRect frame;
            frame.origin.x = mainPadding;
            frame.origin.y = insertionY + paragraphPadding;
            frame.size.width = usableWidth;
            frame.size.height = 0;
            
            NSAttributedString *paraAttr = [[NSAttributedString alloc] initWithString:paragraph attributes:paragraphLabelAttributes];
            
            // Make a label for the paragraph
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            label.backgroundColor = [UIColor clearColor];
            label.attributedText = paraAttr;
            label.numberOfLines = 0;
            [label sizeToFit];
            
            // Add the label to the view
            [self.infoView addSubview:label];
            [self.infoViewsShown addObject:label];
            
            // Move down the insertion value
            insertionY = CGRectGetMaxY(label.frame) + paragraphPadding;
        }
        
    }
    
    // Add some more padding after the paragraphs
    insertionY += 8;
    
    // Update the scrollsize
    self.infoView.contentSize = CGSizeMake(CGRectGetWidth(self.infoView.frame), insertionY);
    
}

- (void)addLineSeparatorWithInsertionY:(NSInteger)insertionY title:(NSString *)title
{
    // Define some properties
    const NSInteger usableWidth = CGRectGetWidth(self.infoView.frame);
    const CGFloat lineWidthPct = 0.9f;
    UIColor* const lineColor = [UIColor grayColor];
    const CGFloat lineHeight = 1.5f - 0.5f * [UIScreen mainScreen].scale;
    const NSInteger titleLabelPaddingSides = 20;
    
    // Define the frame
    CGRect lineFrame;
    lineFrame.size.width = usableWidth * lineWidthPct;
    lineFrame.size.height = lineHeight;
    lineFrame.origin.x = (usableWidth - CGRectGetWidth(lineFrame)) / 2.0f;
    lineFrame.origin.y = insertionY;
    
    // Make the view for the line and add it
    UIView *lineView = [[UIView alloc] initWithFrame:lineFrame];
    lineView.backgroundColor = lineColor;
    
    [self.infoViewsShown addObject:lineView];
    
    // If there is a title
    if(title) {
        
        // Make a label
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
        titleLabel.textColor = lineColor;
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel sizeToFit];
        
        CGRect titleFrame = titleLabel.frame;
        titleFrame.size.width += titleLabelPaddingSides;
        titleLabel.frame = titleFrame;
        
        titleLabel.center = lineView.center;
        [self.infoView addSubview:titleLabel];
        [self.infoViewsShown addObject:titleLabel];
        
    }
}

- (NSAttributedString *)attributedStringForMeasurementValue:(NSDictionary *)measurement
{
    // Pre-written string value for the measurement
    NSString *val_string = [measurement valueForKey:@"string"];
    
    // Units for the string
    NSString *units = [measurement valueForKey:@"units"];
    
    // Array for scientific notation of the value
    NSArray *val_obj = [measurement objectForKey:@"value"];
    
    // Make an attributed string
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
    
    // Default fonts and such
    UIFont *valueFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
    UIFont *exponentFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:8];
    UIFont *unitsFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:13];
    UIColor *valueColor = [UIColor whiteColor];
    UIColor *exponentColor = [UIColor whiteColor];
    UIColor *unitsColor = [UIColor lightGrayColor];
    NSInteger exponentOffset = 6;
    UIFont *mathSymbolFont = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:14];
    UIColor *mathSymbolColor = [UIColor lightGrayColor];
    
    
    // Make the properties of the different parts of the string
    NSDictionary *numberAttributes = @{
                                       NSFontAttributeName: valueFont,
                                       NSForegroundColorAttributeName: valueColor
                                       };
    NSDictionary *exponentAttributes = @{
                                         NSFontAttributeName: exponentFont,
                                         NSForegroundColorAttributeName: exponentColor,
                                         NSBaselineOffsetAttributeName: [NSNumber numberWithInt:exponentOffset]
                                         };
    NSDictionary *unitsAttributes = @{
                                      NSFontAttributeName: unitsFont,
                                      NSForegroundColorAttributeName: unitsColor
                                      };
    NSDictionary *mathSymbolAttributes = @{
                                           NSFontAttributeName: mathSymbolFont,
                                           NSForegroundColorAttributeName: mathSymbolColor
                                           };
    
    // Make an attributed string for a space
    NSAttributedString *space = [[NSAttributedString alloc] initWithString:@" " attributes:numberAttributes];
    
    // Make an attributed string for units
    NSString *unitsString = @"";
    if(units) {
        unitsString = [NSString stringWithFormat:@"%@", units];
        // unitsString = unitsString.uppercaseString;
    }
    NSAttributedString *unitsAttr = [[NSAttributedString alloc] initWithString:unitsString attributes:unitsAttributes];
    
    // If we have a string
    if(val_string) {
        
        // Manipulate the value string
        NSString *valueStr = val_string;
        
        // Make attributed strings for each part
        NSAttributedString *stringAttr = [[NSAttributedString alloc] initWithString:valueStr attributes:numberAttributes];
        
        // Add everything to the main string
        [attr appendAttributedString:stringAttr];
        
        // If we do not have a string
    }else{
        
        // Get the base value of the sci notation
        CGFloat baseValue = [[val_obj firstObject] floatValue];
        
        // Get the exponent value of the sci notation
        NSInteger exponentValue = [[val_obj lastObject] integerValue];
        
        // Create a string for the base value
        NSString *baseValueString = [NSString stringWithFormat:@"%.2f", baseValue];
        
        // Make an attributed string out of the base value
        NSAttributedString *baseValAttr = [[NSAttributedString alloc] initWithString:baseValueString attributes:numberAttributes];
        
        // Add it to the main string
        [attr appendAttributedString:baseValAttr];
        
        // If the exponent is not zero...
        if(exponentValue != 0) {
            
            // Append a "x 10" to the string for scientific notation
            NSAttributedString *timesAttr = [[NSAttributedString alloc] initWithString:@"x" attributes:mathSymbolAttributes];
            NSAttributedString *tenAttr = [[NSAttributedString alloc] initWithString:@"10" attributes:numberAttributes];
            
            // Turn the exponent into a string
            NSString *exponentValueString = [NSString stringWithFormat:@"%i", exponentValue];
            
            // Create an attributed string for the exponent
            NSAttributedString *exponent = [[NSAttributedString alloc] initWithString:exponentValueString attributes:exponentAttributes];
            
            // Append all of the parts
            [attr appendAttributedString:space];
            [attr appendAttributedString:timesAttr];
            [attr appendAttributedString:space];
            [attr appendAttributedString:tenAttr];
            [attr appendAttributedString:exponent];
            
        }
        
    }
    
    // Append a units string to the end
    [attr appendAttributedString:space];
    [attr appendAttributedString:unitsAttr];
    
    // Return it
    return attr;
}

- (void)loadDescriptionInfoWithIdentifier:(NSString *)identifier
{
    NSString *filenamePath = [[NSBundle mainBundle] pathForResource:@"descriptions" ofType:@"json"];
    NSError *error;
    NSString *contents = [NSString stringWithContentsOfFile:filenamePath encoding:NSUTF8StringEncoding error:&error];
    if(error) {
        [self displayNoInformationMessage];
        return;
    }
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[contents dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    if(error) {
        [self displayNoInformationMessage];
        return;
    }
    NSDictionary *data = [json objectForKey:identifier];
    if(!data) {
        [self displayNoInformationMessage];
        return;
    }
    [self displayInformation:data];
}

/*
 *  Deselects every planet button and sets the current one to nil
 */
- (void)deselectAllPlanetButtons
{
    for(PlanetButton *button in self.planetButtons.allValues) {
        button.backgroundColor = button.baseBackgroundColor;
    }
    self.selectedButton = nil;
}

#pragma mark - Methods for changing tabs

/*
 *  Called when the user changes from one tab to another using the tab selector
 */
- (void)didChangeTab:(UISegmentedControl *)tabSelector
{
    // Get the index of the tab
    NSInteger tabIndex = tabSelector.selectedSegmentIndex;
    
    // Get the title of the tab from its index
    NSString *tabTitle = [tabSelector titleForSegmentAtIndex:tabIndex];
    
    // Switch to the new tab by name
    [self switchToTabWithName:tabTitle];
}

/*
 *  Switches to the tab with the given name
 */
- (void)switchToTabWithName:(NSString *)tabTitle
{
    // If the tab name does not exist, return and do nothing here
    if(![self.tabs.allKeys containsObject:tabTitle]) {
        return;
    }
    
    // Remove each tab from the screen
    [self.tabs.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    // Get the new tab view
    UIView *selectedView = [self.tabs objectForKey:tabTitle];
    
    // Add the new tab view to the container
    [self.sidebarTabViewContainer addSubview:selectedView];
}

#pragma mark - Settings value changed action methods

@end
