//
//  MMWebViewController.h
//  Mormor
//
//  Created by yangzexin on 11/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMViewController.h"

@interface MMWebViewController : MMViewController

+ (instancetype)controllerWithURL:(NSURL *)url;

@property (nonatomic, weak, readonly) UIWebView *webView;

@property (nonatomic, assign) CGFloat progressBarPosition;

@property (nonatomic, assign) BOOL dragRefreshEnabled;

- (void)gotoURL:(NSURL *)url;

@end
