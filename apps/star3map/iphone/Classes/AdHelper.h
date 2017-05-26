//
//  AdHelper.h
//  ProPlayer
//
//  Created by Alex on 11.01.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import <Foundation/Foundation.h>
#ifdef STARGLOBE_FREE
#import "FyberSDK.h"
#import "FYBAdMob.h"
#import "FYBFacebookAudienceNetwork.h"
//#import "FYBTaypjoy.h"
//#import "FYBInneractive.h"
#import "FYBInMobi.h"
#import "FYBIntegrationAnalyzerViewController.h"
#endif

@interface AdHelper : NSObject <FYBBannerControllerDelegate, FYBInterstitialControllerDelegate>
+ (id)sharedManager;
@property (nonatomic, strong)FYBBannerController *bannerController;
@property (nonatomic, strong)FYBInterstitialController *interstitialController;
@property BOOL hasInterstitial;
@property BOOL hasBanner;
- (void)reloadInterstitial;
- (void)reloadBanner;
- (void)ratePrompt;
@end
