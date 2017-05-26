//
//  MainViewController.m
//  Orbit
//
//  Created by Conner Douglass on 2/10/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "MainViewController.h"

#define TAB_TITLE_PLANETS @"Planets"
#define TAB_TITLE_INFORMATION @"Info"
#define TAB_TITLE_ADDONS @"Add-ons"
#define TAB_TITLE_SETTINGS @"Settings"

#define MAX_PLANETS_COUNT 1
#define MAX_DAYS_PER_SECOND_SPEED 1.0f

#define GS_DEFAULT_WORLD_IDENTIFIER @"earth"

@interface MainViewController ()

@property CMMotionManager *motionManager;

@property OpenGLView *glView;
@property SolarSystemScene *solarSystemScene;

@property UIView *sidebarView;
@property UIView *tabSelectorMasterView;
@property UISegmentedControl *tabSelector;
@property UIView *sidebarTabViewContainer;
@property NSMutableDictionary *tabs;
@property UIImageView *arrowButton;

@property UIScrollView *tab_Planets, *tab_Info, *tab_Addons, *tab_Settings;
@property NSMutableDictionary *planetButtons;
@property NSMutableArray *extraPlanetButtonViewsToRemove;

// The navigation bar used on the sidebar
@property UINavigationBar *rightNavBar;

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

@implementation MainViewController

/*
 *  Retrieves the shared instance of this view
 */
+ (MainViewController *)sharedInstance
{
    // A static MainViewController instance as the shared instance
    static MainViewController *sharedInstance = nil;
    
    // If the shared instance is nil
    if(!sharedInstance) {
        
        // Create a shared instance
        sharedInstance = [[MainViewController alloc] init];
    }
    
    // Return the shared instance
    return sharedInstance;
}

/*
 *  Edits the custom world with the identifier provided.
 */
- (void)editWorldWithIdentifier:(NSString *)identifier
{
    WorldCreatorViewController *creator = [[WorldCreatorViewController alloc] initWithNibName:@"WorldCreatorViewController" bundle:nil];
    [creator loadDataForIdentifier:identifier];
    creator.modalPresentationStyle = UIModalPresentationFormSheet;
    creator.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:creator animated:YES completion:nil];
}

/*
 *  Called when the button is tapped to create a custom world.
 */
- (void)createWorld
{
    WorldCreatorViewController *creator = [[WorldCreatorViewController alloc] initWithNibName:@"WorldCreatorViewController" bundle:nil];
    creator.modalPresentationStyle = UIModalPresentationFormSheet;
    creator.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:creator animated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // Define some values for sizes and positions
    const NSInteger screenWidth = 1024;
    const NSInteger screenHeight = 768;
    const NSInteger sideBarWidth = 320;
    const NSInteger navBarHeight = 44;
    const NSInteger tabSelectorPadding = 6;
    
    self.infoViewsShown = [NSMutableArray array];
    
    // Perform the initial transition things
    // if(IS_FIRST_VERSION_LAUNCH) {
    //     [self setupLaunchImage];
    // }
    
    BOOL showGLUnderSidebar = NO;
    CGFloat sidebarAlpha = showGLUnderSidebar ? 0.75f : 1.0f;
    
    // Create a view for rendering things!
    self.glView = [[OpenGLView alloc] initWithFrame:CGRectMake(0, 0, screenWidth - (showGLUnderSidebar ? 0.0f : sideBarWidth), screenHeight)];
    [Texture setMasterView:self.glView];
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
    
    // Create a frame for the sidebar view
    CGRect sidebarFrame;
    sidebarFrame.origin.x = screenWidth - sideBarWidth;
    sidebarFrame.origin.y = 0;
    sidebarFrame.size.width = sideBarWidth;
    sidebarFrame.size.height = screenHeight;
    self.sidebarView = [[UIView alloc] initWithFrame:sidebarFrame];
    self.sidebarView.backgroundColor = [UIColor colorWithWhite:0.14f alpha:sidebarAlpha];
    [self.view addSubview:self.sidebarView];
    
    // self.sidebarView.alpha = SIDEBAR_ALPHA;
    
    // Create a navigation bar
    self.rightNavBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, sideBarWidth, navBarHeight)];
    self.rightNavBar.barTintColor = [UIColor colorWithWhite:0.24f alpha:1.0f];
    self.rightNavBar.clipsToBounds = NO;
    self.rightNavBar.backgroundColor = [UIColor colorWithWhite:0.24f alpha:1.0f];
    self.rightNavBar.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.4f].CGColor;
    self.rightNavBar.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.rightNavBar.layer.shadowOpacity = 0.9f;
    self.rightNavBar.layer.shadowRadius = 0.0f;
    self.rightNavBar.tintColor = [UIColor whiteColor];
    self.rightNavBar.titleTextAttributes = @{
                                             NSForegroundColorAttributeName: [UIColor whiteColor]
                                             };
    [self.sidebarView addSubview:self.rightNavBar];
    
    // Now, a navigation item and buttons
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Galileo's Sandbox"];
    self.customWorldsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createWorld)];
    if(PURCHASE_ACTIVATED(@"com.connerdouglass.Galileo.custom_worlds")) {
        navItem.rightBarButtonItem = self.customWorldsButton;
    }
    [self.rightNavBar pushNavigationItem:navItem animated:NO];
    
    // Initialize the tab selector with the tab names
    NSMutableArray *tabNames = [NSMutableArray array];
    [tabNames addObject:TAB_TITLE_PLANETS];
    [tabNames addObject:TAB_TITLE_INFORMATION];
    [tabNames addObject:TAB_TITLE_ADDONS];
    [tabNames addObject:TAB_TITLE_SETTINGS];
    self.tabSelector = [[UISegmentedControl alloc] initWithItems:tabNames];
    
    const NSInteger tabSelectorHeight = CGRectGetHeight(self.tabSelector.frame);
    const NSInteger tabSelectorParentHeight = tabSelectorHeight + 2 * tabSelectorPadding;
    
    // Create a parent view for the tab selector
    CGRect tabParentFrame;
    tabParentFrame.origin.x = 0;
    tabParentFrame.origin.y = screenHeight - tabSelectorParentHeight;
    tabParentFrame.size.width = sideBarWidth;
    tabParentFrame.size.height = tabSelectorParentHeight;
    self.tabSelectorMasterView = [[UIView alloc] initWithFrame:tabParentFrame];
    self.tabSelectorMasterView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
    [self.sidebarView addSubview:self.tabSelectorMasterView];
    
    // Setup the actual tab selector
    CGRect tabSelectorFrame = CGRectInset(self.tabSelectorMasterView.bounds, tabSelectorPadding, tabSelectorPadding);
    self.tabSelector.frame = tabSelectorFrame;
    self.tabSelector.tintColor = [UIColor whiteColor];
    self.tabSelector.selectedSegmentIndex = 0;
    [self.tabSelector addTarget:self action:@selector(didChangeTab:) forControlEvents:UIControlEventValueChanged];
    [self.tabSelectorMasterView addSubview:self.tabSelector];
    
    // Create the view for containing each tab view
    CGRect sidebarContainerFrame;
    sidebarContainerFrame.origin.x = 0;
    sidebarContainerFrame.origin.y = navBarHeight;
    sidebarContainerFrame.size.width = sideBarWidth;
    sidebarContainerFrame.size.height = screenHeight - navBarHeight - tabSelectorParentHeight;
    self.sidebarTabViewContainer = [[UIView alloc] initWithFrame:sidebarContainerFrame];
    self.sidebarTabViewContainer.backgroundColor = [UIColor clearColor];
    self.sidebarTabViewContainer.clipsToBounds = YES;
    self.sidebarTabViewContainer.alpha = sidebarAlpha;
    [self.sidebarView addSubview:self.sidebarTabViewContainer];
    
    self.tabs = [NSMutableDictionary dictionary];
    
    // Add a tab
    self.tab_Info = [[UIScrollView alloc] initWithFrame:self.sidebarTabViewContainer.bounds];
    self.tab_Info.backgroundColor = [UIColor clearColor];
    self.tab_Info.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.tabs setObject:self.tab_Info forKey:TAB_TITLE_INFORMATION];
    
    // Add the tabs
    self.tab_Planets = [[UIScrollView alloc] initWithFrame:self.sidebarTabViewContainer.bounds];
    self.tab_Planets.backgroundColor = [UIColor clearColor];
    self.tab_Planets.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.tabs setObject:self.tab_Planets forKey:TAB_TITLE_PLANETS];
    
    // A tab
    self.tab_Addons = [[UIScrollView alloc] initWithFrame:self.sidebarTabViewContainer.bounds];
    self.tab_Addons.backgroundColor = [UIColor clearColor];
    self.tab_Addons.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.tabs setObject:self.tab_Addons forKey:TAB_TITLE_ADDONS];
    
    // Another tab
    self.tab_Settings = [[UIScrollView alloc] initWithFrame:self.sidebarTabViewContainer.bounds];
    self.tab_Settings.backgroundColor = [UIColor clearColor];
    self.tab_Settings.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    [self.tabs setObject:self.tab_Settings forKey:TAB_TITLE_SETTINGS];
    
    [self populatePlanetsTab];
    [self populateAddonsTab];
    
    [self switchToTabWithName:TAB_TITLE_PLANETS];
    
    [self.sidebarView bringSubviewToFront:self.rightNavBar];
    
    // Add a pinch gesture recognizer to handle the zooming
    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinchScene:)];
    [pinch requireGestureRecognizerToFail:self.solarSystemScene.swipeGesture];
    [self.glView addGestureRecognizer:pinch];
    self.mostRecentSceneScale = self.solarSystemScene.focusDistanceFactor;
    
    // Load the default configuration
    [self setupDefaultConfiguration];
    
    self.motionManager = [[CMMotionManager alloc] init];
    
    // Setup the settings tab
    [self populateSettingsTab];
    
    [[GSPurchaseManager sharedManager] setProductPurchasedHandler:^(GSProduct *product) {
        
        if([product.productIdentifier isEqualToString:@"com.connerdouglass.Galileo.moons"]) {
            [self reloadAvailableWorlds];
        }else if([product.productIdentifier isEqualToString:@"com.connerdouglass.Galileo.dwarf_planets"]) {
            [self reloadAvailableWorlds];
        }else if([product.productIdentifier isEqualToString:@"com.connerdouglass.Galileo.custom_worlds"]) {
            navItem.rightBarButtonItem = self.customWorldsButton;
        }
        
    }];
}

- (void)populateAddonsTab
{
    UILabel *loadingAddonsLabel = [[UILabel alloc] initWithFrame:self.tab_Addons.bounds];
    loadingAddonsLabel.backgroundColor = [UIColor clearColor];
    loadingAddonsLabel.textColor = [UIColor whiteColor];
    loadingAddonsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:18];
    loadingAddonsLabel.textAlignment = NSTextAlignmentCenter;
    loadingAddonsLabel.text = @"Loading Addon Store";
    [self.tab_Addons addSubview:loadingAddonsLabel];
    
    // Load the products
    [[GSPurchaseManager sharedManager] setProductsBecameAvailableHandler:^{
        
        [loadingAddonsLabel removeFromSuperview];
        
        const NSInteger spacing = 10;
        NSInteger y = spacing;
        
        for(GSProduct *product in [GSPurchaseManager sharedManager].products) {
            
            UIView *addonView = [self addonViewWithProduct:product];
            addonView.frame = CGRectOffset(addonView.frame, 0, y);
            [self.tab_Addons addSubview:addonView];
            
            y = CGRectGetMaxY(addonView.frame) + spacing;
            
        }
        
        UIButton *restoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [restoreButton setTitle:@"Restore Purchases" forState:UIControlStateNormal];
        [restoreButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        restoreButton.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.1f];
        [restoreButton addTarget:[GSPurchaseManager sharedManager] action:@selector(restorePurchases) forControlEvents:UIControlEventTouchUpInside];
        restoreButton.frame = CGRectMake(spacing, y, CGRectGetWidth(self.tab_Addons.frame) - 2 * spacing, 60);
        [self.tab_Addons addSubview:restoreButton];
        
        y = CGRectGetMaxY(restoreButton.frame) + spacing;
        
        self.tab_Addons.contentSize = CGSizeMake(CGRectGetWidth(self.tab_Addons.frame), y);
        
    }];
    
    // Call the block if it's finished, or wait for the products to load
    [[GSPurchaseManager sharedManager] waitForProducts];
    
}

- (UIView *)addonViewWithProduct:(GSProduct *)product
{
    // Define the frames of things
    const CGSize addonSize = CGSizeMake(320, 180);
    const CGSize titleSize = CGSizeMake(180, 60);
    const CGSize buyButtonSize = CGSizeMake(80, 30);
    const NSInteger titleSpacingLeft = 5;
    
    // Make all the needed frames
    const CGRect titleFrame = CGRectMake(titleSpacingLeft, 0, titleSize.width - titleSpacingLeft, titleSize.height);
    const CGRect buyContainerFrame = CGRectMake(titleSize.width, 0, addonSize.width - titleSize.width, titleSize.height);
    const CGRect buyButtonFrame = CGRectMake(CGRectGetMidX(buyContainerFrame) - buyButtonSize.width / 2.0f, CGRectGetMidY(buyContainerFrame) - buyButtonSize.height / 2.0f, buyButtonSize.width, buyButtonSize.height);
    const CGRect entireBottomFrame = CGRectMake(0, titleSize.height, addonSize.width, addonSize.height - titleSize.height);
    const CGRect descriptionSharedFrame = CGRectMake(0, CGRectGetMinY(entireBottomFrame), titleSize.width, CGRectGetHeight(entireBottomFrame));
    const CGRect contentsSharedFrame = CGRectMake(CGRectGetWidth(descriptionSharedFrame), CGRectGetMinY(entireBottomFrame), addonSize.width - CGRectGetWidth(descriptionSharedFrame), CGRectGetHeight(entireBottomFrame));
    
    // Get all the parts from the addon dictionary
    NSDictionary *addonDictionary = product.jsonFromFile;
    NSArray *addon_contents = addonDictionary[@"contents-list"];
    
    // Determine frames for the addons based onthe data
    const CGRect descriptionFrame = (addon_contents ? descriptionSharedFrame : entireBottomFrame);
    
    // Make the master view
    UIView *addonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, addonSize.width, addonSize.height)];
    addonView.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    
    // Make the title view
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:30];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = product.productName;
    [addonView addSubview:titleLabel];
    
    // Make the buy button
    UIButton *buyButton = [GSPurchaseButton buttonWithProduct:product];
    buyButton.frame = buyButtonFrame;
    [addonView addSubview:buyButton];
    
    // Add the description view
    UITextView *descriptionView = [[UITextView alloc] initWithFrame:descriptionFrame];
    descriptionView.backgroundColor = [UIColor clearColor];
    descriptionView.textColor = [UIColor whiteColor];
    descriptionView.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
    descriptionView.text = product.productDescription;
    [addonView addSubview:descriptionView];
    
    // Add the contents view
    if(addon_contents) {
        
        const NSInteger itemSpacing = 4;
        
        UIView *masterContentsView = [[UIView alloc] initWithFrame:contentsSharedFrame];
        masterContentsView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.1f];
        
        UIView *contentsContainerParent = [[UIView alloc] initWithFrame:masterContentsView.bounds];
        contentsContainerParent.backgroundColor = [UIColor clearColor];
        
        UIScrollView *contentsContainer = [[UIScrollView alloc] initWithFrame:contentsContainerParent.bounds];
        contentsContainer.backgroundColor = [UIColor clearColor];
        contentsContainer.showsHorizontalScrollIndicator = NO;
        contentsContainer.showsVerticalScrollIndicator = NO;
        contentsContainer.userInteractionEnabled = NO;
        [contentsContainerParent addSubview:contentsContainer];
        
        NSInteger y = itemSpacing;
        NSInteger itemOffset = 8;
        
        for(NSString *item in addon_contents) {
            
            NSInteger itemLabelWidth = CGRectGetWidth(contentsContainer.frame) - itemOffset;
            CGRect itemFrame = CGRectMake(itemOffset, y, itemLabelWidth, 0);
            
            UILabel *itemLabel = [[UILabel alloc] initWithFrame:itemFrame];
            itemLabel.text = item;
            itemLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:16];
            itemLabel.textColor = [UIColor whiteColor];
            itemLabel.numberOfLines = 1;
            itemLabel.adjustsFontSizeToFitWidth = YES;
            [itemLabel sizeToFit];
            
            itemFrame = itemLabel.frame;
            itemFrame.size.width = itemLabelWidth;
            itemLabel.frame = itemFrame;
            
            [contentsContainer addSubview:itemLabel];
            
            y = CGRectGetMaxY(itemLabel.frame) + itemSpacing;
            
        }
        
        contentsContainer.contentSize = CGSizeMake(CGRectGetWidth(contentsContainer.frame), y);
        
        if(y > CGRectGetHeight(contentsContainer.frame)) {
            
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.colors = @[
                                (id)([UIColor clearColor].CGColor),
                                (id)([UIColor whiteColor].CGColor),
                                (id)([UIColor whiteColor].CGColor),
                                (id)([UIColor clearColor].CGColor)
                                ];
            const CGFloat fadeSize = 0.1f;
            gradient.locations = @[
                                   [NSNumber numberWithFloat:0.0f],
                                   [NSNumber numberWithFloat:fadeSize],
                                   [NSNumber numberWithFloat:1.0f - fadeSize],
                                   [NSNumber numberWithFloat:1.0f]
                                   ];
            gradient.frame = contentsContainer.bounds;
            contentsContainerParent.layer.mask = gradient;
            
            [self loopScrolling:contentsContainer];
            
        }
        
        [masterContentsView addSubview:contentsContainerParent];
        [addonView addSubview:masterContentsView];
        
    }
    
    return addonView;
}

- (void)populateSettingsTab
{
    
    // Determine device support for features
    BOOL gyroSupportedOnDevice = [self.motionManager isGyroAvailable];
    
    // Add option stuff
    if(gyroSupportedOnDevice) {
        UISwitch *gyroSwitch = [[UISwitch alloc] init];
        gyroSwitch.on = [AppSettings gyroEnabled];
        [gyroSwitch addTarget:self action:@selector(changedGyroEnabledSetting:) forControlEvents:UIControlEventValueChanged];
        SettingView *gyroSetting = [SettingView settingViewWithTitle:@"Gyroscopic Viewing" control:gyroSwitch];
        [self.tab_Settings addSubview:gyroSetting];
        
        if([AppSettings gyroEnabled]) {
            [self beginGyroscope];
        }
        
    }
    
    UISwitch *dynamicLightingSwitch = [[UISwitch alloc] init];
    dynamicLightingSwitch.on = [AppSettings dynamicLightingEnabled];
    [dynamicLightingSwitch addTarget:self action:@selector(changedLightingEnabledSetting:) forControlEvents:UIControlEventValueChanged];
    SettingView *lightingSetting = [SettingView settingViewWithTitle:@"Dynamic Shadows" control:dynamicLightingSwitch];
    [self.tab_Settings addSubview:lightingSetting];
    
    UISwitch *glowSwitch = [[UISwitch alloc] init];
    glowSwitch.on = [AppSettings glowEnabled];
    [glowSwitch addTarget:self action:@selector(changedGlowEnabledSetting:) forControlEvents:UIControlEventValueChanged];
    SettingView *glowSetting = [SettingView settingViewWithTitle:@"Atmosphere Glow" control:glowSwitch];
    [self.tab_Settings addSubview:glowSetting];
    
    UISwitch *cloudsSwitch = [[UISwitch alloc] init];
    cloudsSwitch.on = [AppSettings cloudsEnabled];
    [cloudsSwitch addTarget:self action:@selector(changedCloudsEnabledSetting:) forControlEvents:UIControlEventValueChanged];
    SettingView *cloudsSetting = [SettingView settingViewWithTitle:@"Clouds" control:cloudsSwitch];
    [self.tab_Settings addSubview:cloudsSetting];
    
    NSInteger bottom = CGRectGetMaxY(cloudsSetting.frame) + 20;
    const NSInteger imageAttrHeight = 30;
    
    UILabel *imageAttr = [[UILabel alloc] initWithFrame:CGRectMake(0, MAX(bottom, CGRectGetHeight(self.tab_Settings.frame) - imageAttrHeight), CGRectGetWidth(self.tab_Settings.frame), imageAttrHeight)];
    imageAttr.backgroundColor = [UIColor clearColor];
    imageAttr.textColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    imageAttr.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10];
    imageAttr.textAlignment = NSTextAlignmentCenter;
    imageAttr.text = @"Space images courtesy of NASA Jet Propulsion Lab.";
    // imageAttr.text = @"Space images based on images from NASA Jet Propulsion Lab.";
    [self.tab_Settings addSubview:imageAttr];
    
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
                
                if([AppSettings gyroEnabled]) {
                    
                    CGFloat orientationFactor = ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) ? -1.0f : 1.0f;
                    
                    CGFloat rotX = RadiansToDegrees(gyroData.rotationRate.y) * orientationFactor;
                    CGFloat rotY = RadiansToDegrees(gyroData.rotationRate.x);
                    
                    self.solarSystemScene.cameraAngularVelocity = CC3VectorMake(-rotX, -rotY, 0.0f);
                }
                
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
    
    self.tab_Planets.showsVerticalScrollIndicator = NO;
    [self.tab_Planets.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.tab_Planets.showsVerticalScrollIndicator = YES;
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
        [self populatePlanetsTab];
    }
}

- (void)populatePlanetsTab
{
    if(!self.planetButtons) {
        self.planetButtons = [NSMutableDictionary dictionary];
    }
    if(!self.extraPlanetButtonViewsToRemove) {
        self.extraPlanetButtonViewsToRemove = [NSMutableArray array];
    }
    NSMutableArray *spaceObjectsFinal = [NSMutableArray array];
    
    [WorldDataManager fetchAvailableBodyJsonForButtons:^(NSArray *spaceObjectsRaw) {
        
        for(NSDictionary *body in spaceObjectsRaw) {
            
            NSMutableDictionary *bodyMut = [body mutableCopy];
            [bodyMut setObject:[NSMutableArray array] forKey:@"_children"];
            if([[body valueForKey:@"parent"] isKindOfClass:[NSNull class]]) {
                [spaceObjectsFinal addObject:bodyMut];
            }else{
                NSString *parent = [body valueForKey:@"parent"];
                for(NSDictionary *potentialParent in spaceObjectsFinal) {
                    if([[potentialParent valueForKey:@"id"] isEqualToString:parent]) {
                        [[potentialParent objectForKey:@"_children"] addObject:bodyMut];
                    }
                }
            }
        }
        
        NSInteger index = 0;
        NSInteger buttonHeight = 64;
        NSInteger childHeight = 42;
        NSInteger childIndent = buttonHeight - childHeight;
        NSInteger bottom = 0;
        
        for(NSDictionary *body in spaceObjectsFinal) {
            
            NSArray *children = [body objectForKey:@"_children"];
            
            CGRect buttonFrame = CGRectMake(0, bottom, CGRectGetWidth(self.tab_Planets.frame), buttonHeight);
            PlanetButton *button = [[PlanetButton alloc] initWithFrame:buttonFrame json:body];
            button.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.05f];
            button.baseBackgroundColor = button.backgroundColor;
            GSWorldData *data = [[GSWorldData alloc] initWithJson:body];
            
            void(^tappedBlock)(void) = ^{
               [self tappedPlanetButton:button];
            };
            
            [button setWasTapped:tappedBlock];
            [button setEditBlock:^(NSString *identifier){
                [self editWorldWithIdentifier:identifier];
            }];
            [button setDeleteBlock:^(NSString *identifier) {
                [self deleteWorldWithIdentifier:identifier];
            }];
            bottom += buttonHeight;
            [self.tab_Planets addSubview:button];
            [self.planetButtons setObject:button forKey:data.identifier];
            
            index++;
            
            for(NSDictionary *child in children) {
                
                CGRect childFrame = CGRectMake(0, bottom, CGRectGetWidth(self.tab_Planets.frame), childHeight);
                UIView *blackView = [[UIView alloc] initWithFrame:childFrame];
                blackView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.35f];
                [self.tab_Planets addSubview:blackView];
                
                CGRect innerChildFrame = CGRectMake(childIndent, 0, CGRectGetWidth(blackView.bounds) - childIndent, CGRectGetHeight(blackView.bounds));
                PlanetButton *childButton = [[PlanetButton alloc] initWithFrame:innerChildFrame json:child];
                childButton.baseBackgroundColor = childButton.backgroundColor;
                GSWorldData *childData = [[GSWorldData alloc] initWithJson:child];
                
                void(^childTappedBlock)(void) = ^{
                    [self tappedPlanetButton:childButton];
                };
                
                [childButton setWasTapped:childTappedBlock];
                [childButton setEditBlock:^(NSString *identifier){
                    [self editWorldWithIdentifier:identifier];
                }];
                [childButton setDeleteBlock:^(NSString *identifier) {
                    [self deleteWorldWithIdentifier:identifier];
                }];
                [blackView addSubview:childButton];
                [self.planetButtons setObject:childButton forKey:childData.identifier];
                
                [self.extraPlanetButtonViewsToRemove addObject:blackView];
                
                bottom += childHeight;
                
                index++;
            }
            
        }
        
        self.tab_Planets.contentSize = CGSizeMake(CGRectGetWidth(self.tab_Planets.frame), bottom);
        
        if(self.selectedButton) {
            [self selectWorldWithIdentifier:self.selectedButton.data.identifier];
        }
        
    }];
}

- (void)deleteWorldWithIdentifier:(NSString *)identifier
{
    [self selectWorldWithIdentifier:@"earth"];
    
    [WorldDataManager fetchJsonForBodiesInPackage:PACKAGE_USERWORLDS completion:^(NSArray *fileJSON) {
        
        NSMutableArray *newFileJSON = [NSMutableArray array];
        
        // Sift through everything
        for(NSDictionary *body in fileJSON) {
            
            BOOL isSameIdentifier = [[body valueForKey:@"id"] isEqualToString:identifier];
            BOOL isChildOfIdentifier = [[body valueForKey:@"parent"] isKindOfClass:[NSNull class]] ? NO : [[body valueForKey:@"parent"] isEqualToString:identifier];
            
            if(!(isSameIdentifier || isChildOfIdentifier)) {
                [newFileJSON addObject:body];
            }
        }
        
        // Write it to file!
        NSError *error;
        NSData *data = [NSJSONSerialization dataWithJSONObject:newFileJSON options:kNilOptions error:&error];
        if(error) {
            NSLog(@"%@", error);
        }else{
            NSString *docs = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSString *userWorldsPath = [docs stringByAppendingPathComponent:USERWORLDS_JSON];
            [data writeToFile:userWorldsPath atomically:YES];
        }
        
        [self reloadAvailableWorlds];
        
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
    
    // Deselect the previously selected button
    if(self.selectedButton) {
        self.selectedButton.backgroundColor = self.selectedButton.baseBackgroundColor;
    }
    
    // Save this as the selected button
    self.selectedButton = button;
    
    // Set the background color of the new selected button
    self.selectedButton.backgroundColor = [UIColor colorWithRed:0.4f green:0.4f blue:1.0f alpha:0.8f];
    
    // Select the world within the scene
    [self.solarSystemScene focusOnBodyWithIdentifier:self.selectedButton.data.identifier];
    
    // Load the description information
    [self loadDescriptionInfoWithIdentifier:self.selectedButton.data.identifier];
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
    
    UILabel *noInfoLabel = [[UILabel alloc] initWithFrame:self.tab_Info.bounds];
    noInfoLabel.backgroundColor = [UIColor clearColor];
    noInfoLabel.textColor = [UIColor whiteColor];
    noInfoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:24];
    noInfoLabel.textAlignment = NSTextAlignmentCenter;
    noInfoLabel.text = @"No Info Available";
    [self.tab_Info addSubview:noInfoLabel];
    
    self.tab_Info.contentSize = CGSizeZero;
    
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
    const NSInteger usableWidth = CGRectGetWidth(self.tab_Info.frame) - 2 * mainPadding;
    
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
        
        UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tab_Info.frame), (hasSubtitle ? 100 : 70))];
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
        
        [self.tab_Info addSubview:bgView];
        
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
    [self.tab_Info addSubview:masterTitleLabel];
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
        [self.tab_Info addSubview:subtitleLabel];
        [self.infoViewsShown addObject:subtitleLabel];
        
        // Update the insertion value
        insertionY = CGRectGetMaxY(subtitleLabel.frame);
        
    }
    
    if(measurements && measurements.count > 0) {
    
        // Put spacing between the sections
        insertionY += betweenSectionsPadding;
        [self addLineSeparatorWithInsertionY:insertionY title:@"MEASUREMENTS"];
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
            [self.tab_Info addSubview:measurementView];
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
            [self.tab_Info addSubview:label];
            [self.infoViewsShown addObject:label];
            
            // Move down the insertion value
            insertionY = CGRectGetMaxY(label.frame) + paragraphPadding;
        }
        
    }
    
    // Add some more padding after the paragraphs
    insertionY += 8;
    
    // Update the scrollsize
    self.tab_Info.contentSize = CGSizeMake(CGRectGetWidth(self.tab_Info.frame), insertionY);
    
}

- (void)addLineSeparatorWithInsertionY:(NSInteger)insertionY title:(NSString *)title
{
    // Define some properties
    const NSInteger usableWidth = CGRectGetWidth(self.tab_Info.frame);
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
    [self.tab_Info addSubview:lineView];
    [self.infoViewsShown addObject:lineView];
    
    // If there is a title
    if(title) {
        
        // Make a label
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = self.sidebarView.backgroundColor;
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9];
        titleLabel.textColor = lineColor;
        titleLabel.text = title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel sizeToFit];
        
        CGRect titleFrame = titleLabel.frame;
        titleFrame.size.width += titleLabelPaddingSides;
        titleLabel.frame = titleFrame;
        
        titleLabel.center = lineView.center;
        [self.tab_Info addSubview:titleLabel];
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

/*
 *  Called when the gyro setting switch is changed
 */
- (void)changedGyroEnabledSetting:(UISwitch *)sw
{
    if(sw.on) {
        [self beginGyroscope];
    }else{
        [self stopGyroscope];
    }
    [AppSettings saveGyroEnabled:sw.on];
}

- (void)changedLightingEnabledSetting:(UISwitch *)dynamicLightingSwitch
{
    [AppSettings saveDynamicLightingEnabled:dynamicLightingSwitch.on];
}

- (void)changedGlowEnabledSetting:(UISwitch *)glowSwitch
{
    [AppSettings saveGlowEnabled:glowSwitch.on];
}

- (void)changedCloudsEnabledSetting:(UISwitch *)cloudsSwitch
{
    [AppSettings saveCloudsEnabled:cloudsSwitch.on];
}

@end
