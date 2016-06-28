//
//  MMWebViewController.m
//  MMiOSKit
//
//  Created by yangzexin on 11/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "MMWebViewController.h"

#import "NJKWebViewProgress.h"

#import "SVPullToRefresh.h"

@interface SFWebViewProgressBar : SFIBCompatibleView

@property (nonatomic, strong) UIColor *progressColor;

- (void)setPercent:(float)percent animated:(BOOL)animated completion:(void(^)())completion;

@end

@interface SFWebViewProgressBar ()

@property (nonatomic, weak) UIView *progressView;

@end

@implementation SFWebViewProgressBar

- (void)initialize {
    [super initialize];
    UIView *progressView = [[UIView alloc] initWithFrame:self.bounds];
    progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:progressView];
    self.progressView = progressView;
    
    __weak typeof(self) weakself = self;
    [SFTrackProperty(self, progressColor) change:^(id value) {
        __strong typeof(weakself) self = weakself;
        self.progressView.backgroundColor = self.progressColor == nil ? SFRGB(227, 227, 227) : self.progressColor;
    }];
}

- (void)setPercent:(float)percent animated:(BOOL)animated completion:(void(^)())completion {
    void(^animations)() = ^{
        CGRect tmpFrame = self.progressView.frame;
        tmpFrame.size.width = ceil(percent * self.frame.size.width);
        self.progressView.frame = tmpFrame;
    };
    
    if (animated) {
        [UIView animateWithDuration:.25f animations:animations completion:^(BOOL finished) {
            if (completion) {
                completion();
            }
        }];
    } else {
        animations();
        if (completion) {
            completion();
        }
    }
}

@end

@interface MMWebViewController () <UIWebViewDelegate, NJKWebViewProgressDelegate>

@property (nonatomic, weak) UIWebView *webView;
@property (nonatomic, weak) SFWebViewProgressBar *progressBar;

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong) NJKWebViewProgress *webViewProgress;

@end

@implementation MMWebViewController

+ (instancetype)controllerWithURL:(NSURL *)url {
    MMWebViewController *controller = [self controller];
    controller.url = url;
    
    return controller;
}

- (void)loadView {
    [super loadView];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    webView.scalesPageToFit = YES;
    [self.view addSubview:webView];
    self.webView = webView;
    
    SFWebViewProgressBar *progressBar = [[SFWebViewProgressBar alloc] initWithFrame:CGRectMake(0, self.progressBarPosition, self.view.frame.size.width, 2)];
    progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [progressBar setPercent:.0f animated:NO completion:nil];
    [self.view addSubview:progressBar];
    self.progressBar = progressBar;
    
    [self.webView sf_removeShadow];
    [self.webView sf_scrollView].decelerationRate = UIScrollViewDecelerationRateNormal;
    [self sf_setLoadingOrWaitingShowable:NO];
    
    __weak typeof(self) weakself = self;
    SFBlockedButton *closeButton = [SFBlockedButton blockedButtonWithTapHandler:^{
        __strong typeof(weakself) self = weakself;
        [self.navigationController popViewControllerAnimated:YES];
    }];
    closeButton.frame = CGRectMake(SFDeviceSystemVersion < 7.0f ? 30.0f : 40.0f, 0.0f, 60.0f, self.navigationController.navigationBar.frame.size.height);
    [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton setTitleColor:SFRGBA(255, 255, 255, 50) forState:UIControlStateHighlighted];
    closeButton.hidden = YES;
    [self sf_setAssociatedObject:closeButton key:@"closeButton"];
    
    [self.navigationController.navigationBar addSubview:closeButton];
    
    [self.webView.scrollView addPullToRefreshWithActionHandler:^{
        __strong typeof(weakself) self = weakself;
        [self.webView reload];
        [self.webView.scrollView.pullToRefreshView stopAnimating];
    } position:SVPullToRefreshPositionTop];
    self.webView.scrollView.showsPullToRefresh = self.dragRefreshEnabled;
    [self.webView.scrollView.pullToRefreshView setTitle:@"继续下拉刷新页面" forState:SVPullToRefreshStateAll];
    [self.webView.scrollView.pullToRefreshView setTitle:@"释放立即刷新页面" forState:SVPullToRefreshStateTriggered];
}

- (void)setDragRefreshEnabled:(BOOL)dragRefreshEnabled {
    _dragRefreshEnabled = dragRefreshEnabled;
    self.webView.scrollView.showsPullToRefresh = dragRefreshEnabled;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIButton *closeButton = [self sf_associatedObjectWithKey:@"closeButton"];
    closeButton.alpha = .0f;
    [UIView animateWithDuration:.25f animations:^{
        closeButton.alpha = 1.0f;
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    UIButton *closeButton = [self sf_associatedObjectWithKey:@"closeButton"];
    [UIView animateWithDuration:.25f animations:^{
        closeButton.alpha = .0f;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webViewProgress = [[NJKWebViewProgress alloc] init];
    self.webViewProgress.webViewProxyDelegate = self;
    self.webViewProgress.progressDelegate = self;
    self.webView.delegate = self.webViewProgress;
    
    [self gotoURL:self.url];
}

- (void)gotoURL:(NSURL *)url {
    if (url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress {
    if (progress == .0f) {
        self.progressBar.hidden = NO;
        [self.progressBar setPercent:.0f animated:NO completion:nil];
    } else {
        __weak typeof(self) weakself = self;
        [self.progressBar setPercent:progress animated:YES completion:^{
            __strong typeof(weakself) self = weakself;
            if (progress == 1.0f) {
                self.progressBar.hidden = YES;
            }
        }];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    __weak typeof(webView) weakwebView = webView;
    if ([[SFWebViewCallTracker sharedInstance] isURLTrackable:request.URL javascriptExecutor:^NSString *(NSString *javascript){
        __strong typeof(weakwebView) webView = weakwebView;
        return [webView stringByEvaluatingJavaScriptFromString:javascript];
    }]) {
        return NO;
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self sf_setWaiting:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.webkitTouchCallout='none';"];
    [self sf_setWaiting:NO];
    if (self.didFinishLoad) {
        self.didFinishLoad();
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self sf_setWaiting:NO];
}

@end
