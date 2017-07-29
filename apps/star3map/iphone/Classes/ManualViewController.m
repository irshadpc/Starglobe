//
//  ManualViewController.m
//  AVPlayerDemo
//
//  Created by Alex on 19/03/16.
//  Copyright © 2016 apple. All rights reserved.
//

#import "ManualViewController.h"

@implementation ManualViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    _webView.delegate = self;
    _webView.tintColor = [UIColor whiteColor];
    [_webView setFrame:self.view.frame];
    self.view.autoresizesSubviews = YES;
    self.title = NSLocalizedString(@"Subscription Infos", nil);
        
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"subscription" ofType:@"html"];
        NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    htmlString = [htmlString stringByReplacingOccurrencesOfString:@"%%PRICE%%" withString:[[NSUserDefaults standardUserDefaults]objectForKey:@"IAPPrice"]];
    
        [_webView loadHTMLString:htmlString baseURL:nil];
    
    _webView.contentScaleFactor = 0;
    
    if (_showDismissButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(dismiss)];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}

- (void)dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
       [_webView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        [_webView.scrollView setZoomScale:0 animated:YES];
       // _webView.scrollView.contentInset = UIEdgeInsetsZero;
    } completion:nil];
}

- (BOOL)prefersStatusBarHidden{
    return NO;
}

@end
