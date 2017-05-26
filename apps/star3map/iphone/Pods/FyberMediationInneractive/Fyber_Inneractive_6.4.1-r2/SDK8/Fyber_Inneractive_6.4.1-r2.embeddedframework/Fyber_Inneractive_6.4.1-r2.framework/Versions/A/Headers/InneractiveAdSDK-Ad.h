//
//  InneractiveAdSDK-Ad.h
//  InneractiveAdSDK
//
//  Created by Inneractive.
//  Copyright (c) 2015 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IaAdConfig;
@protocol InneractiveAdDelegate;

/**
 *  @typedef IaVideoProgressBlock
 *
 *  @brief Video progress block.
 *
 *  @discussion Is used to observe video playback progress.
 *
 *  @param currentTime Current playback time in seconds.
 *  @param totalTime   Total video duration in seconds.
 */
typedef void(^IaVideoProgressBlock)(NSTimeInterval currentTime, NSTimeInterval totalTime);

/**
 *  @class IaAd
 *  @discussion The IaAd is an abstract class. It implements the basic ad flow logic.
 * This class should not be allocated explicitly, please use IaAdView class (Display Ads) or IaNativeAd class (Native Ads) instead.
 *
 * It contains the IaAdConfig property - ad configuration, and the InneractiveAdDelegate delegate.
 */
@interface IaAd : UIView {}

/**
 *  @brief Ad Configuration.
 */
@property (nonnull, nonatomic, strong) IaAdConfig *adConfig;

/**
 *  @brief InneractiveAdDelegate.
 */
@property (nullable, nonatomic, weak) id<InneractiveAdDelegate> delegate;

/**
 *  @brief Use to get video duration in seconds. Is valid only if the ad is video ad.
 *
 *  @discussion Use this method after 'InneractiveAdLoaded:' event has been received.
 */
@property (nonatomic, readonly) NSTimeInterval videoDuration;

/**
 *  @brief Video progress observer. Use to observe current video progress. Is valid only if the ad is video ad and the video is being played.
 *
 *  @discussion The block is invoked on the main thread.
 */
@property (nullable, nonatomic, copy) IaVideoProgressBlock videoProgressObserver;

/**
 *  @brief Check, whether the interstitial / native ad is video ad.
 *
 *  @discussion Use this method after 'InneractiveAdLoaded:' event has been received.
 *
 *  @return YES in case of video ad, otherwise NO.
 */
- (BOOL)isVideoAd;

- (null_unspecified instancetype)init __attribute__((unavailable("IaAd is an abstract class, please use IaAdView class or IaNativeAd class instead")));
- (null_unspecified instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("IaAd is an abstract class, please use IaAdView class or IaNativeAd class instead")));
- (null_unspecified instancetype)initWithCoder:(null_unspecified NSCoder *)aDecoder __attribute__((unavailable("IaAd is an abstract class, please use IaAdView class or IaNativeAd class instead")));
+ (null_unspecified instancetype)new __attribute__((unavailable("IaAd is an abstract class, please use IaAdView class or IaNativeAd class instead")));

#pragma mark - Ads Debugging

/**
 *  @brief Use to limit the connection request time to Inneractive's Server when retrieving the ad.
 *  @discussion If the connection timeout is reached and no ad is recevied from Inneractive's Server - an ad failed event will be invoked.
 * The default connection timeout is 8.0 seconds and the minimum that can be set is 3.0 seconds.
 *  @param connectionTimeoutInSeconds Timeout in seconds.
 */
- (void)setAdRequestConnectionTimeoutInSec:(NSTimeInterval)connectionTimeoutInSeconds;

- (void)testEnvironmentAddress:(nullable NSString *)name;
/**
 * @param portalsString contains portals separated by dot (.) symbol.
 * For example: @"7714.7715"
 */
- (void)testEnvironmentPortal:(nullable NSString *)portalsString;
- (void)testEnvironmentResponse:(nullable NSString *)responseType;

@end
