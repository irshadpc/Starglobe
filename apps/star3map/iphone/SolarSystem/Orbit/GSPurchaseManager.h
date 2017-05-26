//
//  GSPurchaseManager.h
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 7/12/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface GSProduct : NSObject

@property (readonly) NSString *productIdentifier;
@property (readonly) NSString *productPriceString;
@property (readonly) NSString *productName;
@property (readonly) NSString *productDescription;

- (void)purchase;
- (BOOL)purchased;
- (NSDictionary *)jsonFromFile;

@end

@interface GSPurchaseButton : UIButton

+ (GSPurchaseButton *)buttonWithProduct:(GSProduct *)product;

@end

@interface GSPurchaseManager : NSObject

@property (readonly) NSArray *products;
@property (copy) void(^productPurchasedHandler)(GSProduct *product);
@property (copy) void(^productsBecameAvailableHandler)(void);

+ (GSPurchaseManager *)sharedManager;
- (GSProduct *)productWithIdentifier:(NSString *)identifier;
- (void)restorePurchases;
- (void)waitForProducts;

@end
