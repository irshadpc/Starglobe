//
//  MailChimpHelper.h
//  WBMailChimp
//
//  Created by Ivan Trufanov on 28.03.15.
//  Copyright (c) 2015 Werbary. All rights reserved.
//

#import <Foundation/Foundation.h>

//Your mailchimp data center
//A solid example - say your API Key is myapikey-us2. You are in us2
#define mailchimpDC @"us7"
//API Key
#define mailchimpApiKey @"3b161d9597de7f2b2e0a9ddb93e2e74b-us7"

typedef void (^MailChimpHelperResultBlock)(BOOL successS, NSError *err);

@interface WBMailChimp : NSObject

/**
 Adds email to your MailChimp list
 
 @author Ivan Trufanov (itruf@werbary.ru)
 @copyright Werbary
 @date 28.03.2015
 
 @param email Email of user
 @param listId Id of MailChimp list
 @param resBlock Block handler
 
 */
+ (void) addEmail:(NSString*)email toList:(NSString *)listId resBlock:(MailChimpHelperResultBlock)resBlock;
@end
