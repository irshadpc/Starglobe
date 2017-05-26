//
//  AdHelper.m
//  ProPlayer
//
//  Created by Alex on 11.01.17.
//  Copyright © 2017 Azurcoding. All rights reserved.
//

#import "AdHelper.h"
#import <StoreKit/StoreKit.h>
#import "UAAppReviewManager.h"

static AdHelper *sharedManager = nil;

@implementation AdHelper
+ (id) sharedManager{
    static dispatch_once_t pred;
    static AdHelper *sharedManager = nil;
    
    dispatch_once(&pred, ^{
        sharedManager = [[AdHelper alloc] init];
    });
    
    return sharedManager;
}

- (id) init{
    if (self = [super init]){
        _bannerController = [FyberSDK bannerController];
        _bannerController.delegate = self;        
        
        _interstitialController = [FyberSDK interstitialController];
        _interstitialController.delegate = self;
    }
    return self;
}

- (void)reloadInterstitial {    
    [_interstitialController requestInterstitial];
}

- (void)reloadBanner {
    NSDictionary *bannerSizes = @{ FYBAdMobNetworkName : [FYBBannerSize adMobDefault],
                                   FYBFacebookNetworkName : [FYBBannerSize facebookDefault]
                                   };
    [_bannerController requestBannerWithSizes:bannerSizes];
}

-(void)bannerControllerDidReceiveBanner:(FYBBannerController *)bannerController{
    NSLog(@"we received a banner offer, show it");
    [[FyberSDK bannerController] presentBannerAtPosition:FYBBannerPositionBottom];
}

-(void)bannerController:(FYBBannerController *)bannerController didFailToReceiveBannerWithError:(NSError *)error{
    NSLog(@"Failed to receive a Banner Offer with Error: %@", error);
}

-(void)bannerControllerWasClicked:(FYBBannerController *)bannerController{
    NSLog(@"A Banner was clicked");
}

-(void)bannerControllerWillPresentModalView:(FYBBannerController *)bannerController{
    NSLog(@"A Modal View will be presented");
}

-(void)bannerControllerDidDismissModalView:(FYBBannerController *)bannerController{
    NSLog(@"A Modal View was dismissed");
}

-(void)bannerControllerWillLeaveApplication:(FYBBannerController *)bannerController{
    NSLog(@"A Banner Controller will leave the app");
}

-(void)interstitialControllerDidReceiveInterstitial:(FYBInterstitialController *)interstitialController
{
    NSLog(@"An interstitial has been received");
    
    // Show the received interstitial
    [interstitialController presentInterstitialFromViewController:self];
}

-(void)interstitialController:(FYBInterstitialController *)interstitialController didFailToReceiveInterstitialWithError:(NSError *)error{
    NSLog(@"An error occured while receiving the interstitial ad %@", error);
}

-(void)interstitialControllerDidPresentInterstitial:(FYBInterstitialController *)interstitialController{
    NSLog(@"An interstitial has been presented");
}

-(void)interstitialController:(FYBInterstitialController *)interstitialController didFailToPresentInterstitialWithError:(NSError *)error{
    NSLog(@"An error occured while showing the interstitial %@", error);
}

-(void)interstitialController:(FYBInterstitialController *)interstitialController didDismissInterstitialWithReason:(FYBInterstitialControllerDismissReason)reason{
    NSString *reasonDescription;
    switch (reason) {
        case FYBInterstitialControllerDismissReasonUserEngaged:
            reasonDescription = @"because the user clicked on it";
            break;
        case FYBInterstitialControllerDismissReasonAborted:
            reasonDescription = @"because the user explicitly closed it";
            break;
        case FYBInterstitialControllerDismissReasonError:
            // error during playing
            break;
    }
    
    NSLog(@"The interstitial ad was dismissed %@", reasonDescription);
}

- (void)ratePrompt{
    if ([UIDevice currentDevice].systemVersion.floatValue >= 10.3) {
        [SKStoreReviewController requestReview];
    } else {
        [UAAppReviewManager showPrompt];
    }
}

@end
