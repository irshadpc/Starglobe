//
//  MailChimpHelper.m
//  pdd
//
//  Created by Иван Труфанов on 28.03.15.
//  Copyright (c) 2015 werbary. All rights reserved.
//

#import "WBMailChimp.h"

@implementation WBMailChimp
+ (void) addEmail:(NSString*)email toList:(NSString *)listId resBlock:(MailChimpHelperResultBlock)resBlock {
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@.api.mailchimp.com/2.0/lists/subscribe",mailchimpDC]]];
    NSLog(@"%@",req.URL);
    NSMutableDictionary *paramsDictionary = [NSMutableDictionary new];
    if (email) {
        paramsDictionary[@"email"] = @{@"email":email};
    }
    if (listId) {
        paramsDictionary[@"id"] = listId;
    }
    if (mailchimpApiKey) {
        paramsDictionary[@"apikey"] = mailchimpApiKey;
    }
    
    NSError *errGeneratingJson = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:paramsDictionary options:0 error:&errGeneratingJson];
    
    if (errGeneratingJson) {
        if (resBlock) {
            resBlock(NO,errGeneratingJson);
        }
        return;
    }
    [req setHTTPBody:bodyData];
    [req setHTTPMethod:@"POST"];
    
    [NSURLConnection sendAsynchronousRequest:req queue:[NSOperationQueue new] completionHandler:^(NSURLResponse *resp, NSData *respData, NSError *err){
        if (!err) {
            NSError *errParsing = nil;
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:respData options:0 error:&errParsing];
            if (errParsing) {
                if (resBlock) {
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        resBlock(NO,errParsing);
                    });
                }
            } else {
                if ([response[@"status"] isEqualToString:@"error"]) {
                    if (resBlock) {
                        NSError *err = [NSError errorWithDomain:@"com.werbary.mailchimp.helper" code:[response[@"code"] integerValue] userInfo:@{NSLocalizedDescriptionKey:response[@"error"]}];
                        dispatch_async(dispatch_get_main_queue(), ^(){
                            resBlock(NO,err);
                        });
                    }
                } else {
                    resBlock(YES,nil);
                }
            }
        } else {
            if (resBlock) {
                dispatch_async(dispatch_get_main_queue(), ^(){
                    resBlock(NO,err);
                });
            }
        }
    }];
}
@end