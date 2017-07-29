//
//  ManualViewController.h
//  AVPlayerDemo
//
//  Created by Alex on 19/03/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualViewController : UIViewController <UIWebViewDelegate>
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property NSString *manualName;
@property NSString *manualBundle;
@property NSString *price;
@property BOOL showDismissButton;
@end
