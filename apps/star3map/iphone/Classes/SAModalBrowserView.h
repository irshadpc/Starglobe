//
//  SAModalBrowserView.h
//  SkyAbove
//
//  Created by Richard Hyland on 17/05/2012.
//  Copyright (c) 2012 RBD Solutions Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SAModalBrowserView : UIViewController <UIWebViewDelegate> {
    UIWebView *wv;
    
    @private
}

@property(nonatomic,strong) UIWebView *wv;


- (void)startWikiRequest;



@end
