//
//  InneractiveAdSDK-AdView.h
//  InneractiveAdSDK
//
//  Created by Inneractive.
//  Copyright (c) 2015 Inneractive. All rights reserved.
//

#import "InneractiveAdSDK-Ad.h"

// Display Ads Sizes
static const CGFloat kIAIPhoneBannerWidth = 320.0f;
static const CGFloat kIAIPhoneBannerHeight = 50.0f;

static const CGFloat kIAIPadBannerWidth = 728.0f;
static const CGFloat kIAIPadBannerHeight = 90.0f;

static const CGFloat kIARectangleWidth = 300.0f;
static const CGFloat kIARectangleHeight = 250.0f;

@protocol InneractiveAdDelegate;

/**
 *  @class IaAdView
 *  @brief The IaAdView is a Display Ads class. It can be used as banner, rectangle or interstitial ad.
 *  @discussion The compatible ad types are: IaAdType_Banner, IaAdType_Rectangle, IaAdType_Interstitial.
 *
 *  @code self.adView = [[IaAdView alloc] initWithAppId:@"some app id" adType:IaAdType_Banner delegate:self];
 *  @endcode
 */
@interface IaAdView : IaAd {}

/**
 *  @brief Is used to initialize the IaAdView class instance.
 *
 *  @param appId      The App Id as a string, registered on Inneractive's console (e.g., @"MyCompany_MyApp").
 *  @param adType     The type of ad (IaAdType_Banner, IaAdType_Rectangle, IaAdType_Interstitial)
 *  @param adDelegate The Delegate parameter is a class implementing the <InneractiveAdDelegate> protocol.
 *
 *  @return IaAdView instance.
 */
- (nonnull instancetype)initWithAppId:(nonnull NSString *)appId adType:(IaAdType)adType delegate:(nonnull id<InneractiveAdDelegate>)adDelegate;

- (null_unspecified instancetype)init __attribute__((unavailable("please use 'initWithAppId:adType:delegate:' instead")));
- (null_unspecified instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("please use 'initWithAppId:adType:delegate:' instead")));
- (null_unspecified instancetype)initWithCoder:(null_unspecified NSCoder *)aDecoder __attribute__((unavailable("'using initWithCoder:' programmatically is unavailable, please use 'initWithAppId:adType:delegate:' instead or use Interface Builder and setup the ad required configuration; e.g: adView.adConfig.appId = <app id>; adView.adConfig.adType = <ad type>;")));
+ (null_unspecified instancetype)new __attribute__((unavailable("please use 'initWithAppId:adType:delegate:' instead")));

/**
 *  @brief Use to limit ad load time.
 *
 *  @param loadTimeout load timout in seconds.
 */
- (void)setAdLoadTimeoutInSec:(NSTimeInterval)loadTimeout;

@end
