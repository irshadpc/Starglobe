//
//  InneractiveAdSDK-AdConfig.h
//  InneractiveAdSDK
//
//  Created by Inneractive.
//  Copyright (c) 2015 Inneractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#pragma mark - Types

/**
 *  @typedef IaAdType
 *  @brief Ad Type.
 */
typedef NS_ENUM(NSUInteger, IaAdType) {
    /**
     *  @brief Banner Ad.
     */
    IaAdType_Banner = 1,
    /**
     *  @brief Rectangle Ad.
     */
    IaAdType_Rectangle = 2,
    /**
     *  @brief Interstitial Ad.
     */
    IaAdType_Interstitial = 3,
    /**
     *  @brief Native Ad.
     */
    IaAdType_NativeAd = 4,
    /**
     *  @brief Native In-Feed Ad.
     */
    IaAdType_InFeedNativeAd = 5
};

/**
 *  @typedef InneractiveVideoFullscreenOrientationMode
 *
 *  @brief Fullscreen videos interface orientation modes.
 *
 *  The default is 'InneractiveVideoFullscreenOrientationModeMaskAll'.
 */
typedef NS_ENUM(NSInteger, InneractiveVideoFullscreenOrientationMode) {
    /**
     *  @brief A video will be presented in same orientation as presenting view controller; can be rotated to any supported orientation.
     */
    InneractiveVideoFullscreenOrientationModeMaskAll = 0,
    /**
     * A video will be presented in a landscape mode. Can be rotated to any supported landscape orientation.
     */
    InneractiveVideoFullscreenOrientationModeForceLandscape = 1,
    /**
     *  @brief A video will be presented in portrait mode.
     */
    InneractiveVideoFullscreenOrientationModeForcePortrait = 2,
};

/**
 *  @typedef IaNativeAdContentType
 *  @brief Native Ad Main Asset content definition.
 */
typedef NS_ENUM(NSUInteger, IaNativeAdContentType) {
    /**
     *  @brief Both video and image are allowed.
     */
    IaNativeAdContentTypeAny = 1,
    /**
     *  @brief Only video.
     */
     IaNativeAdContentTypeVideo = 2,
    /**
     *  @brief Only image.
     */
     IaNativeAdContentTypeImage = 3,
};

@class IaVideoLayout;
@class IaNativeAdAssetDescription;

/**
 *  @class IaAdConfig
 *  @brief Ad Configuration.
 */
@interface IaAdConfig : NSObject {}

#pragma mark - General

/**
 *  @brief Ad App ID.
 *  @discussion App IDs are created in the Inneractive console website http://console.inner-active.com
 *
 * An ad spot is a defined placement in your application set aside for advertising.
 */
@property (nonnull, nonatomic, strong) NSString *appId;

/**
 *  @brief Ad type definition.
 */
@property (nonatomic) IaAdType adType;

/**
 *  @brief The Inneractive ad refresh interval in seconds once the ad is displayed. This interval is only applicable for Banner and Rectangle ads.
 * Interstitial ads are never refreshed.
 */
@property (nonatomic) int refreshIntervalInSec;

#pragma mark - Ad Targeting

/**
 *  @brief A string representing a set of keywords, that should be passed to Inneractive's Ad Server in order to receive more relevant advertising.
 */
@property (nullable, nonatomic, strong) NSString *adKeyWords;

/**
 *  @brief User gender. Use for better ad targeting.
 *  @discussion Available values: "M" / "m" / "F" / "f" / "Male" / "Female".
 */
@property (nullable, nonatomic, strong) NSString *userGender;

/**
 *  @brief User age. Use for better ad targeting.
 *  @discussion Avalaible values: [0, 150].
 */
@property (nonatomic) NSUInteger userAge;

/**
 *  @brief ZIP Code. Use for better ad targeting.
 *  @discussion Should be specified as NSString instance with standard ZIP code value. E.g. "90210".
 */
@property (nullable, nonatomic, strong) NSString *zipCode;

/**
 *  @brief Current location. Use for better ad targeting.
 *  @discussion The CLLocation object should be passed. If there is no location management in the application,
 * Inneractive supplies it's own location manager. Use 'shouldAutomaticallyGetLocationData' to enable location management
 * on behalf of InneractiveAdSDK.
 *
 * If 'shouldAutomaticallyGetLocationData' is enabled, do not use current property, it will be updated automatically by the SDK.
 */
@property (nullable, nonatomic, copy) CLLocation *location;

/**
 *  @brief Use to enable a location manager managed by the InneractiveAdSDK.
 *  @discussion If enabled, InneractiveAdSDK will create and manage it's own location manager,
 * and the 'location' propery will be updated automatically.
 */
@property (nonatomic) BOOL shouldAutomaticallyGetLocationData;

#pragma mark - Video parameters

/**
 *  @brief Fullscreen videos preffered interface orientation mode.
 *  @discussion Use the 'InneractiveVideoFullscreenOrientationMode' type to define the orientation.
 */
@property (nonatomic) InneractiveVideoFullscreenOrientationMode fullscreenVideoOrientationMode;

/**
 *  @brief Video Layout.
 */
@property (nonnull, nonatomic, strong, readonly) IaVideoLayout *videoLayout;

#pragma mark - Native Ad parameters

/**
 *  @brief Native Ad Assets configuration. Should be defined for better compatibility between publisher and advertiser.
 *  @discussion IaNativeAdAssetDescription class consists of properties, that customize a final native ad, and is compatible
 * with IAB Native Protocol 1.0.
 *
 * List of properties:
 *
 * 'mainAssetMinSize'- defines the minimum width and heigth for main image or video asset.
 *
 * 'titleAssetPriority' - defines the title asset priority.
 *
 * 'imageIconAssetPriority' - defines the icon asset priority.
 *
 * 'imageIconAssetMinSize' - define the minimum width and height for icon asset.
 *
 * 'callToActionTextAssetPriority' - defines the "Call to Action" asset priority.
 *
 * 'descriptionTextAssetPriority' - defines the description (body text) asset priority.
 *
 * IaNativeAdAssetPriority Enum:
 *
 * 'IaNativeAdAssetPriorityNone' - Asset (UI) is not implemented by a publisher.
 *
 * 'IaNativeAdAssetPriorityOptional' - Asset (UI) is implemented by a publisher, but is not crusial for getting data for.
 *
 * 'IaNativeAdAssetPriorityRequired' - Asset (UI) is implemeted by a publisher and is required by a publisher.
 */
@property (nonnull, nonatomic, strong, readonly) IaNativeAdAssetDescription *nativeAdAssetsDescription;

/**
 *  @brief Native Ad Main Asset content type.
 *  @discussion Default - IaNativeAdContentTypeAny.
 */
@property (nonatomic) IaNativeAdContentType nativeAdContentType;

#pragma mark - In-Feed Native Ad using adapter ads parameters

/**
 *  @brief Native Ad start position inside a feed. For use with table adapter only.
 */
@property (nonatomic) NSInteger nativeAdStartPosition;

/**
 *  @brief Native Ad repeating interval inside a feed. For use with table adapter only.
 */
@property (nonatomic) NSInteger nativeAdRepeatingInterval;

@end

#pragma mark - Video Layout

/**
 *  @typedef IaVideoLayoutControlType
 *  @brief IaVideoLayoutControlType
 */
typedef NS_ENUM(NSUInteger, IaVideoLayoutControlType) {
    IaVideoLayoutControlTypeClose = 1,
    IaVideoLayoutControlTypeAction,
    IaVideoLayoutControlTypeMute,
    IaVideoLayoutControlTypeTimer,
};

/**
 *  @typedef IaVideoClickActionType
 *  @brief IaVideoClickActionType
 */
typedef NS_ENUM(NSUInteger, IaVideoClickActionType) {
    IaVideoClickActionTypeFullscreen = 0,
    IaVideoClickActionTypeLandingPage
};

/**
 *  @class IaVideoLayout
 *  @brief Video controls layout configuration.
 */
@interface IaVideoLayout : NSObject

/**
 *  @brief Defines whether the action button (aka: CTA / "Visit Us" / VAST clickthrough) is visible in feed (native and non-fullscreen mode).
 *
 *  @discussion This is not OpenRTB Native 1.0 CTA, but VAST protocol CTA. There is also OpenRTB CTA asset in native ad unit (in case a response includes it).
 *
 * Default: <b>enabled</b>.
 * 
 * If disabled, <b>will not be visible</b> in feed.
 *
 * If enabled <b>and</b> CTA native asset is implemented in UI, will be <b>hidden</b> in feed, in order to prevent from showing both CTAs (VAST and OpenRTB).
 *
 * If enabled <b>and</b> CTA native asset is NOT implemented in UI, will be <b>visible</b>.
 */
@property (nonatomic, getter=isActionButtonVisibleInFeed) BOOL actionButtonIsVisibleInFeed;

/**
 *  @brief Defines whether progress bar is visible in feed (native and non-fullscreen mode).
 */
@property (nonatomic, getter=isProgressBarVisibleInFeed) BOOL progressBarIsVisibleInFeed;

/**
 *  @brief Progress bar progress track fill color.
 */
@property (nonnull, nonatomic, strong) UIColor *progressBarFillColor;

/**
 *  @brief Progress bar track color.
 */
@property (nonnull, nonatomic, strong) UIColor *progressBarBackColor;

/**
 *  @brief Defines whether controls are aligned to an actual video rect or to a video player superview (placeholder).
 *
 *  @discussion This setting will affect only videos that are not fully fitted inside native ad main asset, and the videos that are displayed in fullscreen portrait mode.
 *
 * Default: NO.
 */
@property (nonatomic) BOOL controlsInsideVideoRect;

/**
 *  @brief Defines click (inside video area) action, while a video has not finished playing.
 *
 *  @discussion The default action is to open fullscreen.
 */
@property (nonatomic) IaVideoClickActionType videoClickActionType;

/**
 *  @brief Defines color theme.
 *
 *  @discussion Tints text color of text based controls.
 * Tints image colour of image based controls.
 *
 * The default is nil.
 */
@property (nullable, nonatomic, strong) UIColor *themeColor;

/**
 *  @brief Defines background color theme.
 *
 *  @discussion Tints background color of text based controls.
 *
 * The default is nil.
 */
@property (nullable, nonatomic, strong) UIColor *backgroundThemeColor;

/**
 *  @brief Defines controls placement.
 *
 *  @param topLeftControlType     Control to place in the top left corner.
 *  @param topRightControlType    Control to place in the top right corner.
 *  @param bottomLeftControlType  Control to place in the bottom left corner.
 *  @param bottomRightControlType Control to place in the bottom right corner.
 *
 *  @discussion Calling this method, all the four parameters should be passed, and all four should be distinct. Use IaVideoLayoutControlType enum to define a control.
 */
- (void)setTopLeftControlType:(IaVideoLayoutControlType)topLeftControlType
          topRightControlType:(IaVideoLayoutControlType)topRightControlType
        bottomLeftControlType:(IaVideoLayoutControlType)bottomLeftControlType
       bottomRightControlType:(IaVideoLayoutControlType)bottomRightControlType;

/**
 *  @brief Use to get UI control by control type.
 *
 *  @discussion This method should be invoked only after 'InneractiveAdLoaded:' event has been received.
 * This method should be used in order to customise font, text color, etc.
 *
 *  @param type Control type.
 *
 *  @return (UIButton *) OR (UILabel *) OR other UIView subclass instance.
 */
- (nullable UIView *)controlByType:(IaVideoLayoutControlType)type;

/**
 *  @brief Use to get 'skip in ...' label of interstitial ad type.
 *
 *  @discussion This method should be invoked only after 'InneractiveAdLoaded:' event has been received.
 * This method should be used in order to customise font, text color, etc.
 *
 *  @return Skip label as (UILabel *).
 */
- (nullable UILabel *)interstitialSkipLabel;

@end

#pragma mark - Native Ad Assets

/**
 *  @typedef IaAdAssetSize
 *  @brief Custom size struct.
 *  @discussion Use to define native assets minimum size.
 *
 *  @field width Asset width.
 *  @field height Asset height.
 */
typedef struct IaAdAssetSize {
    NSUInteger width;
    NSUInteger height;
} IaAdAssetSize;

/**
 *  @brief Creates IaAdAssetSize struct instance.
 *
 *  @param width  Width.
 *  @param height Height.
 *
 *  @return IaAdAssetSize instance.
 */
static inline IaAdAssetSize IaAdAssetSizeMake(NSUInteger width, NSUInteger height) {
    IaAdAssetSize assetSize;
    
    assetSize.width = width;
    assetSize.height = height;
    
    return assetSize;
}

/**
 *  @typedef IaNativeAdAssetPriority
 *  @brief Asset Prioriy enum, that is used to define whether asset can be optional, is required by publisher or should not be displayed at all.
 */
typedef NS_ENUM(NSInteger, IaNativeAdAssetPriority) {
    /**
     *  @brief Asset (UI) is not implemented by a publisher.
     */
    IaNativeAdAssetPriorityNone,
    
    /**
     *  @brief Asset (UI) is implemented by a publisher, but is not crucial getting data for.
     */
    IaNativeAdAssetPriorityOptional,
    
    /**
     *  @brief Asset (UI) is implemeted by a publisher and is required by a publisher.
     */
    IaNativeAdAssetPriorityRequired
};

/**
 *  @class IaNativeAdAssetDescription
 *  @brief Native Ad Assets configuration.
 */
@interface IaNativeAdAssetDescription : NSObject

/**
 *  @brief Defines the minimum width and heigth for main image or video asset.
 */
@property (nonatomic) IaAdAssetSize mainAssetMinSize;

/**
 *  @brief Defines the title asset priority.
 */
@property (nonatomic) IaNativeAdAssetPriority titleAssetPriority;

/**
 *  @brief Defines the icon asset priority.
 */
@property (nonatomic) IaNativeAdAssetPriority imageIconAssetPriority;

/**
 *  @brief Define the minimum width and height for icon asset.
 */
@property (nonatomic) IaAdAssetSize imageIconAssetMinSize;

/**
 *  @brief Defines the "Call to Action" asset priority.
 */
@property (nonatomic) IaNativeAdAssetPriority callToActionTextAssetPriority;

/**
 *  @brief Defines the description (body text) asset priority.
 */
@property (nonatomic) IaNativeAdAssetPriority descriptionTextAssetPriority;

@end
