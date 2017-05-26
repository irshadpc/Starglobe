//
//  InneractiveAdSDK.h
//  InneractiveAdSDK
//
//  Created by Inneractive.
//  Copyright (c) 2015 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "InneractiveAdSDK-AdConfig.h"
#import "InneractiveAdSDK-AdView.h"
#import "InneractiveAdSDK-NativeAd.h"
#import "InneractiveAdSDK-AdDelegate.h"
#import "InneractiveAdSDK-GeneralConfig.h"

/**
 *  @class InneractiveAdSDK
 *  @classdesign Singleton
 *  @discussion The Inneractive iOS AD SDK API allows retrieving and displaying ads from Inneractive's Ad Server.
 */
@interface InneractiveAdSDK : NSObject {}

#pragma mark - General Methods

/**
 *  @brief Returns the singleton instance of the InneractiveAdSDK class.
 *  @discussion The singleton instance should be used to initiate ad requests and manage any Inneractive Ads inside your application.
 */
+ (nonnull instancetype)sharedInstance;

/**
 *  @brief Use to Initialize the InneractiveAdSDK.
 *  @discussion Currently is not used. The SDK will be initialized on the first invocation of 'sharedInstance' method.
 * This is an entry point, preserved for future use. Will be used to initialize the InneractiveAdSDK.
 */
- (void)initialize;

/**
 *  @brief Loads an Inneractive ad.
 *  @discussion InneractiveAdSDK will send request and will parse response. In case it succeeds, 'InneractiveAdLoaded:'
 *  InneractiveAdDelegate's protocol method will be invoked. In case of fail, 'InneractiveAdFailedWithError:withAdView:'
 * method will be called.
 *  @param ad IaAd subclass instance. IaAd is abstract class and is base class for IaAdView and IaNativeAd classes.
 */
- (void)loadAd:(nonnull IaAd *)ad;

/**
 *  @brief Removes saved ad resources and discards the ad.
 *  @discussion Should be used for cleanup only for Display Ads: banner, rectangle or interstitial.
 * This method should be called only after loading an ad using the loadAd function.
 *
 *  @param ad ad instance, that should be disposed.
 */
- (void)removeAd:(nullable IaAd *)ad;

#pragma mark - Interstitial Ads Methods

/**
 *  @brief Shows a pre-loaded Interstitial Ad.
 *  @discussion This method should be called only for Inetestitial ads, after loading an Interstitial ad using the 'loadAd:' method and getting positive response.
 *  @param adView IaAdView instance, initialized as IaAdType_Interstitial and successfully loaded.
 */
- (void)showInterstitialAd:(nonnull IaAdView *)adView;

/**
 *  @brief Checks if an Interstitial Ad has finished pre-loading and is ready to be displayed.
 *  @discussion This method should be called only after loading an Interstitial ad using the 'loadAd:' function.
 *  @param adView IaAdView instance, initialized as IaAdType_Interstitial.
 *
 *  @return if ad is ready, 'YES' will be returned, otherwise 'NO'
 */
- (BOOL)isInterstitialReady:(nonnull IaAdView *)adView;

#pragma mark - Native Ad methods

/**
 *  @brief Shows a Native Ad instance at a specified view.
 *  @discussion Should be used only for Native Ads. Native Ads types:
 *
 * IaAdType_NativeAd,
 *
 * IaAdType_InFeedNativeAd.
 *
 *  @param nativeAd        IaNativeAd instance.
 *  @param viewForNativeAd UIView subclass instance, that conforms to IaNativeAdRenderingDelegate protocol and implements 'layoutAdAssets:' method.
 */
- (void)showNativeAd:(nonnull IaNativeAd *)nativeAd atView:(nonnull UIView<IaNativeAdRenderingDelegate> *)viewForNativeAd;

/**
 *  @brief Shows a Native In-Feed Ad instance at a specified cell.
 *  @discussion Should be used only for Native Ad instance of IaAdType_InFeedNativeAd type.
 *  @param nativeAd        IaNativeAd instance.
 *  @param cell            UITableViewCell / UICollectionViewCell subclass instance, that conforms to IaNativeAdCellRenderingDelegate protocol and implements
 * 'layoutAdAssets:' and 'sizeForNativeAdCell' methods.
 */
- (void)showNativeAd:(nonnull IaNativeAd *)nativeAd atCell:(nonnull UIView<IaNativeAdCellRenderingDelegate> *)cell;

/**
 *  @brief Loads the Icon Asset into a supplied UIImageView instance.
 *  @discussion Call to this method from your 'layoutAdAssets:' method implementation.
 *  @param iconImageView The UIImageView instance which will contain the icon asset image.
 *  @param nativeAd      IaNativeAd instance.
 */
- (void)loadIconIntoImageView:(nonnull UIImageView *)iconImageView withNativeAd:(nonnull IaNativeAd *)nativeAd;

/**
 *  @brief Loads the Title Asset into a supplied UILabel instance.
 *  @discussion Call to this method from your 'layoutAdAssets:' method implementation.
 *  @param titleLabel The UILabel instance which will contain the title asset text.
 *  @param nativeAd   IaNativeAd instance.
 */
- (void)loadTitleIntoTitleLabel:(nonnull UILabel *)titleLabel withNativeAd:(nonnull IaNativeAd *)nativeAd;

/**
 *  @brief Loads the Body Text Asset into a supplied UILabel instance.
 *  @discussion Call to this method from your 'layoutAdAssets:' method implementation.
 *  @param bodyTextLabel The UILabel instance which will contain the body text.
 *  @param nativeAd      IaNativeAd instance.
 */
- (void)loadBodyTextIntoTitleLabel:(nonnull UILabel *)bodyTextLabel withNativeAd:(nonnull IaNativeAd *)nativeAd;

/**
 *  @brief Loads the Call to Action Asset into a supplied UILabel instance.
 *  @discussion Call to this method from your 'layoutAdAssets:' method implementation.
 *  @param callToActionLabel The UILabel instance which will contain the call to action text.
 *  @param nativeAd          IaNativeAd instance.
 */
- (void)loadCallToActionIntoLabel:(nonnull UILabel *)callToActionLabel withNativeAd:(nonnull IaNativeAd *)nativeAd;

/**
 *  @brief Loads The Main Asset, that is Native Video or Native Image into a supplied UIView instance.
 *  @discussion The Inneractive custom video player or custom image view visual object will be added as a subview to a supplied view.
 *
 * Call to this method from your 'layoutAdAssets:' method implementation.
 *  @param view     The UIView instance. Important: this view must be fully, 100% visible, and must be a top level view in the relevant view hierarchy,
 * in order to video player start to play or report an impression in case of image.
 *  @param nativeAd IaNativeAd instance.
 */
- (void)loadMainAssetIntoView:(nonnull UIView *)view withNativeAd:(nonnull IaNativeAd *)nativeAd;

/**
 *  @brief Loads the Social Context Asset into a supplied UILabel instance.
 *  @discussion Call to this method from your 'layoutAdAssets:' method implementation.
 *  @param socialContextLabel The UILabel instance which will contain the social context asset text.
 *  @param nativeAd           IaNativeAd instance.
 */
- (void)loadSocialContextIntoSocialContextLabel:(nonnull UILabel *)socialContextLabel withNativeAd:(nonnull IaNativeAd *)nativeAd;

/**
 *  @brief Loads the Star Rating Asset into a supplied UIView instance.
 *  @discussion Call to this method from your 'layoutAdAssets:' method implementation.
 *  @param starRatingView The UIView instance which will contain the star rating asset text.
 *  @param nativeAd       IaNativeAd instance.
 */
- (void)loadStarRatingIntoView:(nonnull UIView *)starRatingView withNativeAd:(nonnull IaNativeAd *)nativeAd;

/**
 *  @brief Use to enable secure connections.
 *  @discussion In order to work with HTTPS requests and ATS protocol, this property should be enabled.
 */
@property (nonatomic) BOOL useSecureConnections;

#pragma mark - Special Optional Display Ads methods

/**
 *  @brief Optional method for notifying the adView of manual rotation changes in case the application doesn't use autorotation.
 *
 *  @param adView                 IaAdView instance
 *  @param toInterfaceOrientation the UIInterfaceOrientation which the ad should rotate to.
 */
- (void)rotateAdView:(nonnull IaAdView *)adView ToOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

#pragma mark - Display Ads Mediation

/** 
 * @typedef IaAdMediationType
 * 
 * @brief Mediation type
 * 
 * @field <b>IaAdMediationType_None</b> Without mediation.<br>
 * @field <b>IaAdMediationType_Mopub</b> Working under Mopub.<br>
 * @field <b>IaAdMediationType_AdMob</b> Working under Admob.<br>
 * @field <b>IaAdMediationType_DFP</b> Working under DFP.<br>
 * @field <b>IaAdMediationType_Fyber</b> Working under Fyber.<br>
 * @field <b>IaAdMediationType_Other</b> Undefined.<br>
 */
typedef NS_ENUM(NSUInteger, IaAdMediationType) {
    /**
     *  Without mediation.
     */
    IaAdMediationType_None = 0,
    /**
     *  Working under Mopub.
     */
    IaAdMediationType_Mopub = 1,
    /**
     *  Working under Admob.
     */
    IaAdMediationType_AdMob = 2,
    /**
     *  Working under DFP.
     */
    IaAdMediationType_DFP = 3,
    /**
     *  Working under Fyber.
     */
    IaAdMediationType_Fyber = 4,
    /**
     *  Undefined.
     */
    IaAdMediationType_Other = 5
};

/**
 *  @brief Should be set to appropriate mediation type in custom event class.
 *  @discussion Do not use this method, if you want to load the Inneractive Ad and not a mediated one.
 *
 * Setting the mediation type to anything other than the default (IaAdMediationType_None) disables
 * automatic ad refreshes.
 *  @param mediationType the Mediation the ad is running under.
 */
- (void)setAdMediationType:(IaAdMediationType)mediationType;

/**
 *  @brief Get current defined ad mediation type.
 *
 *  @return Current defined ad mediation type.
 */
- (IaAdMediationType)adMediationType;

#pragma mark - Configuration

/**
 *  @brief The sdkConfig object can be used to set the general SDK configuration InneractiveAdSDKGeneralConfig (e.g., general video behaviour etc.)
 *  @discussion Global SDK Configuration.
 */
@property (nonnull, nonatomic, strong, readonly) InneractiveAdSDKGeneralConfig *sdkConfig;

/**
 *  @typedef IaLogLevel
 *  @brief Log level.
 */
typedef NS_ENUM(NSUInteger, IaLogLevel) {
    /**
     *  @brief Disabled.
     */
    IaLogLevel_Off = 0,
    /**
     *  @brief Includes error logging.
     */
    IaLogLevel_Error = 1,
    /**
     *  @brief Includes warnings and error logging.
     */
    IaLogLevel_Warn = 2,
    /**
     *  @brief Includes general info., warnings and error logging.
     */
    IaLogLevel_Info = 3,
    /**
     *  @brief Includes debug information, general info., warnings and error logging.
     */
    IaLogLevel_Debug = 4,
    /**
     *  @brief Includes all types of logging.
     */
    IaLogLevel_Verbose = 5,
};

/**
 *  @brief Sets the log level which is outputted to XCode's console.
 *
 *  @param logLevel log level
 */
+ (void)setLogLevel:(IaLogLevel)logLevel;

/**
 *  @brief SDK Version check
 *
 *  @return SDK version as a float number (e.g., 5.01)
 */
+ (float)sdkVersion;

/**
 *  @brief The alloc, init and new methods should not be used to initialize and use the InneractiveSDK class. [InneractiveAdSDK sharedInstance] should be used instead.
 */
- (null_unspecified instancetype)init __attribute__((unavailable("init not available, call [InneractiveAdSDK sharedInstance] instead")));
+ (null_unspecified instancetype)new __attribute__((unavailable("new not available, call [InneractiveAdSDK sharedInstance] instead")));
- (void)testRemoteConfig:(nonnull NSString *)config;
- (nullable NSString *)facebookNativeAdPlacementID;
- (void)setFacebookNativeAdPlacementID:(nonnull NSString *)facebookNativeAdPlacementID;

@end
