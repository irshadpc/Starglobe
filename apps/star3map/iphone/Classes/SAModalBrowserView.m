//
//  SAModalBrowserView.m
//  SkyAbove
//
//  Created by Richard Hyland on 17/05/2012.
//  Copyright (c) 2012 RBD Solutions Limited. All rights reserved.
//

#import "SAModalBrowserView.h"

@implementation SAModalBrowserView

@synthesize wv;

- (id)init {
    if ((self = [super init])) {
  //      mwClient = [[MWClient alloc] initWithApiURL:@"http://en.wikipedia.org/w/api.php" delegate:self];
        
	}
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wv = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [wv setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    //[wv setBackgroundColor:[UIColor whiteColor]];
    wv.opaque = NO;
	wv.backgroundColor = [UIColor clearColor];
    [wv setDelegate:self];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"menu" ofType:@"html"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
    [wv loadRequest:[NSURLRequest requestWithURL:url]];
    
    
    [self.view addSubview:wv];
    //[self startWikiRequest];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark UIWebView delegate methods
- (void)webViewDidStartLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView {
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType {
    if ([[[request URL] scheme] isEqualToString:@"skyabove"]) {
        NSString *file = [[request URL] host];
        
        aWebView.opaque = NO;
        aWebView.backgroundColor = [UIColor clearColor];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:file ofType:@"html"];
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path isDirectory:NO];
        [aWebView loadRequest:[NSURLRequest requestWithURL:url]];
        
        //if ([file isEqualToString:@"res-thesun"]) {
            //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"res-sun.png"]]];
        
        //}
         return NO;
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    return YES;
}

-(void) viewWillAppear: (BOOL)animated
{
    [super viewWillAppear: animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
    }
    else {
        self.navigationController.navigationBarHidden = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    wv.delegate = nil;
    if ([wv isLoading]) {
		[wv stopLoading];
	}
    [super viewWillDisappear:animated];
    
   // self.navigationController.navigationBarHidden = YES;

}


@end
