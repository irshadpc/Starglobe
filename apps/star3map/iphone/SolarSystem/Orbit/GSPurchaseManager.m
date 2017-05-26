//
//  GSPurchaseManager.m
//  Galileo's Sandbox
//
//  Created by Conner Douglass on 7/12/14.
//  Copyright (c) 2014 Conner Douglass. All rights reserved.
//

#import "GSPurchaseManager.h"
#import <StoreKit/StoreKit.h>

@interface GSPurchaseButton ()

@property GSProduct *product;

+ (GSPurchaseButton *)buttonWithProduct:(GSProduct *)product;
- (void)updateDesign;

@end

@interface GSProduct ()

@property GSPurchaseManager *manager;
@property (readonly) SKProduct *rawProduct;
@property NSMutableArray *buttons;

- (void)addButton:(GSPurchaseButton *)button;

@end

@implementation GSProduct

+ (NSString *)priceStringForProduct:(SKProduct *)product
{
    static NSNumberFormatter *priceFormatter = nil;
    if(!priceFormatter) {
        priceFormatter = [[NSNumberFormatter alloc] init];
        [priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    }
    
    [priceFormatter setLocale:product.priceLocale];
    return [priceFormatter stringFromNumber:product.price];
}

- (id)initWithRawProduct:(SKProduct *)product
{
    if(self = [super init]) {
        
        // Make the manager nil
        self.manager = nil;
        
        // Make an array for buttons
        self.buttons = [NSMutableArray array];
        
        // Save the whole product
        _rawProduct = product;
        
        // Save the identifier
        _productIdentifier = product.productIdentifier;
        
        // Save the price
        _productPriceString = [GSProduct priceStringForProduct:product];
        
        // Save the name
        _productName = product.localizedTitle;
        
        // Save the description
        _productDescription = product.localizedDescription;
        
    }
    return self;
}

- (NSDictionary *)jsonFromFile
{
    return [PRODUCT_CONTENTS objectForKey:self.productIdentifier];
}

- (void)addButton:(GSPurchaseButton *)button
{
    [self.buttons addObject:button];
}

- (void)updateButtons
{
    for(GSPurchaseButton *button in self.buttons) {
        [button updateDesign];
    }
}

/*
 *  Purchases the product.
 */
- (void)purchase
{
    // Make a new payment object
    SKPayment *payment = [SKPayment paymentWithProduct:self.rawProduct];
    
    // Submit the payment
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

/*
 *  Sets the cached purchase state of the product in user defaults.
 */
- (void)savePurchased:(BOOL)purchased
{
    [[NSUserDefaults standardUserDefaults] setBool:purchased forKey:DEFAULTS_KEY_PURCHASED_PRODUCT(self.productIdentifier)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 *  Reads from user defaults the purchase state of the product.
 */
- (BOOL)purchased
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:DEFAULTS_KEY_PURCHASED_PRODUCT(self.productIdentifier)];
}

@end

@implementation GSPurchaseButton

+ (GSPurchaseButton *)buttonWithProduct:(GSProduct *)product
{
    // Make a new button
    GSPurchaseButton *button = [GSPurchaseButton buttonWithType:UIButtonTypeCustom];
    
    // Save the product
    button.product = product;
    
    // Add an event handler to taps
    [button addTarget:button action:@selector(didTapButton) forControlEvents:UIControlEventTouchUpInside];
    
    // Design the button appropriately
    [button updateDesign];
    
    // Add the button to the product to handle changes in the backend
    [product addButton:button];
    
    // Return the button
    return button;
}

- (void)didTapButton
{
    // If the product is purchased, return
    if(self.product.purchased) {
        return;
    }
    
    // Update the UI
    [self updateDesignPending];
    
    // Purchase the product
    [self.product purchase];
}

- (void)updateDesignPending
{
    // Set a new title to show purchased
    [self setTitle:@"Working" forState:UIControlStateNormal];
    
    // Set the background color to blueish
    self.backgroundColor = [UIColor lightGrayColor];
}

- (void)updateDesign
{
    // Corner radius
    self.layer.cornerRadius = 4.0f;
    
    // Font color
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    // Title font
    self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12];
    
    // If the product has been purchased
    if(self.product.purchased) {
        
        // Set a new title to show purchased
        [self setTitle:@"Purchased √" forState:UIControlStateNormal];
        
        // Set the background color to blueish
        // self.backgroundColor = [UIColor colorWithRed:0.1f green:0.4f blue:1.0f alpha:1.0f];
        
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        
    }
    
    // If the product is not purchased
    else {
    
        // Set a new title with the price
        [self setTitle:self.product.productPriceString forState:UIControlStateNormal];
        
        // Set the background color to greenish
        self.backgroundColor = [UIColor colorWithRed:0.1f green:1.0f blue:0.4f alpha:1.0f];
        
    }
}

@end

@interface GSPurchaseManager () <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation GSPurchaseManager

static dispatch_queue_t purchaseHandlerQueue = NULL;

+ (GSPurchaseManager *)sharedManager
{
    // Define the shared instance
    static GSPurchaseManager *sharedInstance = nil;
    
    // If the shared instance is not created
    if(!sharedInstance) {
        
        // Create it!
        sharedInstance = [[GSPurchaseManager alloc] init];
    }
    
    // Return the shared instance
    return sharedInstance;
}

/*
 *  Fetches the available product identifiers from the "products.json" file.
 */
+ (NSArray *)availableIdentifiersFromProductsJSON
{
    NSMutableArray *identifiers = [NSMutableArray array];
    NSArray *addonsIdentifiers = PRODUCT_IDENTIFIERS;
    for(NSString *addon in addonsIdentifiers) {
        [identifiers addObject:addon];
    }
    return [NSArray arrayWithArray:identifiers];
}

/*
 *  Initializes the file with the default identifiers.
 */
- (id)init
{
    if(self = [super init]) {
        
        if(purchaseHandlerQueue == NULL) {
            purchaseHandlerQueue = dispatch_queue_create("GSPurchaseManagerQueue", NULL);
        }
        
        // Save this as the payment observer
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        // Get the identifiers
        NSArray *identifiers = [GSPurchaseManager availableIdentifiersFromProductsJSON];
        
        // Request the products
        [self requestProductsWithIdentifiers:identifiers];
        
    }
    return self;
}

- (void)requestProductsWithIdentifiers:(NSArray *)identifiers
{
    // Make a set out of the identifiers
    NSSet *identifiersSet = [NSSet setWithArray:identifiers];
    
    // Make the request for the products
    SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:identifiersSet];
    productsRequest.delegate = self;
    [productsRequest start];
}

- (GSProduct *)productWithIdentifier:(NSString *)identifier
{
    for(GSProduct *product in self.products) {
        if([product.productIdentifier isEqualToString:identifier]) {
            return product;
        }
    }
    return nil;
}

- (void)restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)waitForProducts
{
    if(self.products && self.productsBecameAvailableHandler) {
        self.productsBecameAvailableHandler();
        self.productsBecameAvailableHandler = nil;
    }
}

#pragma mark - Responding to updated transaction

- (void)makeContentAvailable:(GSProduct *)product newlyPurchased:(BOOL)newlyPurchased
{
    // Mark the product as purchased
    [product savePurchased:YES];
    
    // Update the buttons on the product
    [product updateButtons];
    
    if(self.productPurchasedHandler) {
        dispatch_sync(purchaseHandlerQueue, ^{
            self.productPurchasedHandler(product);
        });
    }
}

- (void)didCompleteTransaction:(SKPaymentTransaction *)transaction
{
    // Get the product in question
    GSProduct *product = [self productWithIdentifier:transaction.payment.productIdentifier];
    
    // Make the content available
    [self makeContentAvailable:product newlyPurchased:YES];
}

- (void)didRestoreTransaction:(SKPaymentTransaction *)transaction
{
    // Get the product in question
    GSProduct *product = [self productWithIdentifier:transaction.originalTransaction.payment.productIdentifier];
    
    // Make the content available
    [self makeContentAvailable:product newlyPurchased:NO];
}

- (void)didFailTransaction:(SKPaymentTransaction *)transaction
{
    // Get the product in question
    GSProduct *product = [self productWithIdentifier:transaction.payment.productIdentifier];
    
    // Update the buttons on the product
    [product updateButtons];
}

#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    // Make a mutable array for the products
    NSMutableArray *productsMutable = [NSMutableArray array];
    
    // Loop through the raw products
    for(SKProduct *rawProduct in response.products) {
        
        // Make a new product with the raw one
        GSProduct *product = [[GSProduct alloc] initWithRawProduct:rawProduct];
        
        // Save this manager as the product manager
        product.manager = self;
        
        // Add the product to the array
        [productsMutable addObject:product];
        
    }
    
    // Save the products
    _products = [NSArray arrayWithArray:productsMutable];
    
    // Call the handler if there is one
    [self waitForProducts];
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Product request error: %@", error);
}

#pragma mark - SKPaymentTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    // Loop through each transation that was updated
    for (SKPaymentTransaction *transaction in transactions) {
        
        // Respond differently based on what the update was
        switch (transaction.transactionState) {
                
            // Newly purchased:
            case SKPaymentTransactionStatePurchased:
                [self didCompleteTransaction:transaction];
                break;
                
            // Failed purchase:
            case SKPaymentTransactionStateFailed:
                [self didFailTransaction:transaction];
                break;
                
            // Restored purchase:
            case SKPaymentTransactionStateRestored:
                [self didRestoreTransaction:transaction];
                break;
                
            // Default, to satisfy the switch
            default:
                break;
        }
        
        // If it was one of those types of transaction states above
        if(transaction.transactionState == SKPaymentTransactionStatePurchased ||
           transaction.transactionState == SKPaymentTransactionStateFailed ||
           transaction.transactionState == SKPaymentTransactionStateRestored) {
            
            // Mark the transaction as handled
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        }
    }
}

@end
