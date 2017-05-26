//
//  InneractiveAdSDK-AdDelegate.h
//  InneractiveAdSDK
//
//  Created by Inneractive.
//  Copyright (c) 2015 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IaAd;

/**
 *  @protocol InneractiveAdDelegate
 *  @brief InneractiveAdDelegate Protocol
 *  @discussion In order to load and show Inneractive Ads, InneractiveAdDelegate Protocol methods should be implemented.
 */
@protocol InneractiveAdDelegate <NSObject>

@required

/**
 *  @brief Required InneractiveAdDelegate Protocol method. Should be implemented in order IA SDK will be able to present Interstitial Ad,
 * In-App Browser and other modal views.
 *
 *  @return UIViewController instance to show modal views from.
 */
- (nonnull UIViewController *)viewControllerForPresentingModalView;

@optional

/**
 *  @brief Is called when a paying ad was loaded and is ready to be displayed.
 */
- (void)InneractiveAdLoaded:(nonnull IaAd *)ad;

/**
 *  @brief Is Called when there was an error loading the ad.
 */
- (void)InneractiveAdFailedWithError:(nonnull NSError *)error withAdView:(nonnull IaAd *)ad;

/**
 *  @brief Is called when the ad opens a modal view. The app. can perform logic such as pausing a running game here. 
 */
- (void)InneractiveAdAppShouldSuspend:(nonnull IaAd *)ad;

/**
 *  @brief Is called when the ad closes it's final modal view. The app. can perform logic such as re-running a paused game here.
 */
- (void)InneractiveAdAppShouldResume:(nonnull IaAd *)ad;

/**
 *  @brief Ad clicked event.
 */
- (void)InneractiveAdClicked:(nonnull IaAd *)ad;

/**
 *  @brief Impression event for Native Image Ads only.
 */
- (void)InneractiveAdWillLogImpression:(nonnull IaAd *)ad;

/**
 *  @brief Called before the ad will open an external application (e.g. Safari, the Telephone/Messages/Email apps. etc.).
 */
- (void)InneractiveAdWillOpenExternalApp:(nonnull IaAd *)ad;

#pragma mark - Interstitial Ad events

/**
 *  @brief Called before an interstitial ad will be presented on the screen.
 */
- (void)InneractiveInterstitialAdWillShow:(nonnull IaAdView *)adView;

/**
 *  @brief Called after the interstitial ad is presented on the screen.
 */
- (void)InneractiveInterstitialAdDidShow:(nonnull IaAdView *)adView;

/**
 *  @brief Called when an Interstitial close / skip button was pressed.
 */
- (void)InneractiveInterstitialAdDismissed:(nonnull IaAdView *)adView;

#pragma mark - MRAID 2.0 Ad Events

/**
 *  @brief MRAID Resize event will happen.
 *
 *  @param adView       IaAdView instance.
 *  @param frameAsValue Resized frame.
 */
- (void)InneractiveAdWillResize:(nonnull IaAdView *)adView toFrame:(nonnull NSValue *)frameAsValue;

/**
 *  @brief MRAID Resize event did happen.
 *
 *  @param adView       IaAdView instance.
 *  @param frameAsValue Resized frame.
 */
- (void)InneractiveAdDidResize:(nonnull IaAdView *)adView toFrame:(nonnull NSValue *)frameAsValue;

/**
 *  @brief MRAID Expand event will happen.
 *
 *  @param adView       IaAdView instance.
 *  @param frameAsValue Expanded frame.
 */
- (void)InneractiveAdWillExpand:(nonnull IaAdView *)adView toFrame:(nonnull NSValue *)frameAsValue;

/**
 *  @brief MRAID Expand event did happen.
 *
 *  @param adView       IaAdView instance.
 *  @param frameAsValue Expanded frame.
 */
- (void)InneractiveAdDidExpand:(nonnull IaAdView *)adView toFrame:(nonnull NSValue *)frameAsValue;

#pragma mark - Video Ad (Interstitial / Native) Events

/**
 *  @brief Called when video did finish playing to end successfully.
 */
- (void)InneractiveVideoCompleted:(nonnull IaAd *)ad;

@end
