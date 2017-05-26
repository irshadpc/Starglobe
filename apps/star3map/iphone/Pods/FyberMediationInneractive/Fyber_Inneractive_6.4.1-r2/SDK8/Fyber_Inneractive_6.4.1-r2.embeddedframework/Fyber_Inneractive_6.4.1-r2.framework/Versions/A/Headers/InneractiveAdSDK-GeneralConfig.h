//
//  InneractiveAdSDK-GeneralConfig.h
//  InneractiveAdSDK
//
//  Created by Inneractive.
//  Copyright (c) 2015 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InneractiveAdSDK-Ad.h"

/**
 *  @class InneractiveAdSDKGeneralConfig
 *  @brief The InneractiveAdSDKGeneralConfig is the global InneractiveAdSDK configuration.
 */
@interface InneractiveAdSDKGeneralConfig : NSObject

#pragma mark - Video Ad settings: Interstitial or Native ad

/**
*  @brief The max video bitrate above which the video will be filtered out from the received playlist, when connected through WiFi.
*
*  @return Bit rate in kbit/s.
*/
- (NSInteger)bitrateMaxWifi;

/**
 *  @brief The max video bitrate above which the video will be filtered out from the received playlist, when connected through WiFi.
 *
 *  @param bitrateMaxWifi Bit rate in kbit/s.
 */
- (void)setBitrateMaxWifi:(NSInteger)bitrateMaxWifi;

/**
 *  @brief The max video bitrate above which the video will be filtered out from the playlist when connected to a cellular data network.
 *
 *  @return Bit rate in kbit/s.
 */
- (NSInteger)bitrateMax3g;

/**
 *  @brief The max video bitrate above which the video will be filtered out from the playlist when connected to a cellular data network.
 *
 *  @param bitrateMax3g Bit rate in kbit/s.
 */
- (void)setBitrateMax3g:(NSInteger)bitrateMax3g;

/**
 *  @brief The timeout for video buffering, during playing the video, when connected via WIFI.
 *
 *  @return Timeout in seconds.
 */
- (NSInteger)buffWifiTimeout;

/**
 *  @brief The timeout for video buffering, during playing the video, when connected via WIFI.
 *
 *  @param buffWifiTimeout Timeout in seconds.
 */
- (void)setBuffWifiTimeout:(NSInteger)buffWifiTimeout;

/**
 *  @brief The timeout for video buffering, during playing the video, when connected via a cellular data network.
 *
 *  @return Timeout in seconds.
 */
- (NSInteger)buff3gTimeout;

/**
 *  @brief The timeout for video buffering, during playing the video, when connected via a cellular data network.
 *
 *  @param buff3gTimeout Timeout in seconds.
 */
- (void)setBuff3gTimeout:(NSInteger)buff3gTimeout;

/**
 *  @brief The timeout for video buffering, during loading the video, when connected via WIFI.
 *
 *  @return Timeout in seconds.
 */
- (NSInteger)prerollWifiTimeout;

/**
 *  @brief The timeout for video buffering, during loading the video, when connected via WIFI.
 *
 *  @param prerollWifiTimeout Timeout in seconds.
 */
- (void)setPrerollWifiTimeout:(NSInteger)prerollWifiTimeout;

/**
 *  @brief The timeout for video buffering, during loading the video, when connected via a cellular data network.
 *
 *  @return Timeout in seconds.
 */
- (NSInteger)preroll3gTimeout;

/**
 *  @brief The timeout for video buffering, during loading the video, when connected via a cellular data network.
 *
 *  @param preroll3gTimeout Timeout in seconds.
 */
- (void)setPreroll3gTimeout:(NSInteger)preroll3gTimeout;

#pragma mark - Native Ads reload intervals

/**
 *  @brief A time interval the ad should be reloaded after the 'no ad' event has been received.
 *
 *  @return Time interval in seconds.
 */
- (NSInteger)refreshOnNoAd;

/**
 *  @brief A time interval the ad should be reloaded after the 'no ad' event has been received.
 *
 *  @param refreshOnNoAd Time interval in seconds.
 */
- (void)setRefreshOnNoAd:(NSInteger)refreshOnNoAd;

/**
 *  @brief A time interval the ad should be reloaded after the error event has been received.
 *
 *  @return Time interval in seconds.
 */
- (NSInteger)refreshOnError;

/**
 *  @brief A time interval the ad should be reloaded after the error event has been received.
 *
 *  @param refreshOnError Time interval in seconds.
 */
- (void)setRefreshOnError:(NSInteger)refreshOnError;

/**
 *  @brief A time interval the ad should be reloaded after the complete event has been received.
 *
 *  @discussion In case of video ad, the complete event is when the video finishes playing.
 * In case of native image ad, the complete event means - an impression was logged.
 *
 *  @return Time interval in seconds.
 */
- (NSInteger)refreshOnComplete;

/**
 *  @brief A time interval the ad should be reloaded after the complete event has been received.
 *
 *  @discussion In case of video ad, the complete event is when the video finishes playing.
 * In case of native image ad, the complete event means - an impression was logged.
 *
 *  @param refreshOnComplete Time interval in seconds.
 */
- (void)setRefreshOnComplete:(NSInteger)refreshOnComplete;

/**
 *  @brief Use to determine whether ads reload is disabled.
 *
 *  @return Result in boolean.
 */
- (BOOL)disableAutoFetch;

/**
 *  @brief Use to disable automatic reloading of Native Ads.
 *
 *  @param disableAutoFetch Enable / Disable value.
 */
- (void)setDisableAutoFetch:(BOOL)disableAutoFetch;

/**
 *  @brief Use to determine whether video autoplay is enabled.
 *
 *  @return Result in boolean.
 */
- (BOOL)nativeVideoShouldAutoplay;

/**
 *  @brief Use to enable / disable video autoplay.
 *
 *  @param nativeVideoShouldAutoplay Enable / Disable value.
 */
- (void)setNativeVideoShouldAutoplay:(BOOL)nativeVideoShouldAutoplay;

/**
 *  @brief Enable built-in AVAudioSession category management.
 *  @discussion Should be invoked before the first native ad instance has been created.
 */
- (void)setUseAudioSessionManagement;

/**
 *  @typedef InneractiveInterstitialVideoSkipMode
 *  @brief Enum Defines a time interval, the interstitial video will be available to skip after.
 */
typedef NS_ENUM(NSInteger, InneractiveInterstitialVideoSkipMode) {
    /**
     *  Default: after 15 seconds.
     */
    InneractiveInterstitialVideoSkipModeDefault = 0,
    /**
     *  Minimum: after 5 seconds.
     */
    InneractiveInterstitialVideoSkipModeMinTime = 1,
    /**
     *  Skip is not allowed until video finishes.
     */
    InneractiveInterstitialVideoSkipModeDisabled = 2,
    /**
     *  @brief Skip is always available.
     */
    InneractiveInterstitialVideoSkipModeAlways = 3,
};

/**
 *  @brief Get skip mode.
 *
 *  @return skip mode.
 */
- (InneractiveInterstitialVideoSkipMode)interstitialVideoSkipMode;

/**
 *  @brief Defines a time interval, the interstitial video will be available to skip after.
 *
 *  @param interstitialVideoSkipMode Skip mode.
 */
- (void)setInterstitialVideoSkipMode:(InneractiveInterstitialVideoSkipMode)interstitialVideoSkipMode;

@end
