//
//  MMViewController.m
//  MMiOSKit
//
//  Created by suruochang on 14-3-18.
//  Copyright (c) 2014年 SF. All rights reserved.
//

#import "MMViewController.h"

#import "MMViewController-private.h"

@implementation MMViewController

+ (instancetype)controller {
    id controller = [self new];
    
    return controller;
}

static UIImage *_MMLeftBarButtonItemImage = nil;

+ (UIImage *)defaultLeftBarButtonItemImage {
    return _MMLeftBarButtonItemImage == nil ? [@"✕" sf_imageWithFont:[UIFont systemFontOfSize:30.0f] textColor:[UIColor whiteColor]] : _MMLeftBarButtonItemImage;
}

+ (void)setDefaultLeftBarButtonItemImage:(UIImage *)image {
    _MMLeftBarButtonItemImage = image;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@ %@ dealloc", self.title, NSStringFromClass([self class]));
#endif
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    [self initialize];
    
    return self;
}

- (id)init {
    self = [self initWithNibName:nil bundle:nil];
    
    return self;
}

- (void)initialize {
    self.waitingForViewControllerVisible = [SFMarkWaiting markWaiting];
}

- (void)loadView {
    [super loadView];
    
    self.view.backgroundColor = SFRGB(245, 245, 245);
    if (self.didTapBackButton) {
        self.navigationItem.leftBarButtonItem = [MMViewController normalLeftBarButtonItemWithImage:[MMViewController defaultLeftBarButtonItemImage] tap:self.didTapBackButton];
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)whenWillVisible:(void(^)())block {
    [_waitingForViewControllerVisible wait:block];
}

- (void)whenWillVisible:(void(^)())block identifier:(NSString *)identifier {
    [_waitingForViewControllerVisible wait:block uniqueIdentifier:identifier];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.waitingForViewControllerVisible markAsFinish];
    [self.navigationController setNavigationBarHidden:self.hidesNavigationBar animated:animated];
    if (self.viewWillAppearObserver) {
        self.viewWillAppearObserver();
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.waitingForViewControllerVisible resetMark];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)setLeftBarButtonItemAsBackButtonWithTap:(void(^)())tap {
    self.didTapBackButton = tap;
}

- (SFBlockedBarButtonItem *)rightBarButtonItemWithImage:(UIImage *)image tap:(void(^)())tap {
    return [MMViewController normalRightBarButtonItemWithImage:image tap:tap];
}

- (SFBlockedBarButtonItem *)rightBarButtonItemWithTitle:(NSString *)title tap:(void(^)())tap {
    return [MMViewController normalRightBarButtonItemWithTitle:title tap:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
    }
    
    [self.waitingForViewControllerVisible cancelAll];
}

- (void)setHidesNavigationBar:(BOOL)hidesNavigationBar {
    _hidesNavigationBar = hidesNavigationBar;
    for (UIViewController *viewController in self.childViewControllers) {
        if ([viewController respondsToSelector:@selector(setHidesNavigationBar:)]) {
            [(id)viewController setHidesNavigationBar:_hidesNavigationBar];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    [self.view endEditing:YES];
}

- (BOOL)visible {
    return [self.waitingForViewControllerVisible isMarked];
}

#pragma mark - Normal Bar button
+ (SFBlockedBarButtonItem *)normalRightBarButtonItemWithImage:(UIImage *)image tap:(void(^)())tap {
    SFBlockedBarButtonItem *item  = [SFBlockedBarButtonItem blockedBarButtonItemWithCustomView:({
        SFBlockedButton *button = [SFBlockedButton blockedButtonWithTap:tap];
        [button setImage:image forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, button.currentImage.size.width, button.currentImage.size.height);
        button;
    })];
    
    return item;
}

+ (SFBlockedBarButtonItem *)normalRightBarButtonItemWithTitle:(NSString *)title tap:(void(^)())tap {
    SFBlockedButton *button = [SFBlockedButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 4.0, 58.0, 30.0);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    [button setTitle:title forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    static UIImage *backgroundImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        backgroundImage = [UIImage sf_roundImageWithOptions:({
            SFRoundImageOptions *options = [SFRoundImageOptions options];
            [options setBackgroundColor:[UIColor clearColor]];
            [options setBorderColor:[UIColor whiteColor]];
            [options setSize:CGSizeMake(40, 30)];
            [options setCornerRadius:3];
            [options setLightBorder:NO];
            options;
        })];
        backgroundImage = [backgroundImage stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    });
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    SFBlockedBarButtonItem *buttonItem = [SFBlockedBarButtonItem blockedBarButtonItemWithCustomView:({
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 58.0f, 44.0f)];
        [containerView addSubview:button];
        containerView;
    })];
    
    button.tap = tap;
    
    return buttonItem;
}

+ (SFBlockedBarButtonItem *)normalLeftBarButtonItemWithTitle:(NSString *)title tap:(void(^)())tap {
    return [self normalRightBarButtonItemWithTitle:title tap:tap];
}

+ (SFBlockedBarButtonItem *)normalLeftBarButtonItemWithImage:(UIImage *)image tap:(void (^)())tap {
    return [self normalRightBarButtonItemWithImage:image tap:tap];
}

@end

@implementation UIViewController (MMDialogs)

- (void)alert:(NSString *)message {
    [self alert:message close:nil];
}

- (void)alert:(NSString *)message close:(void(^)())close {
    void(^alertBlock)() = ^{
        [UIAlertView sf_alertWithTitle:NSLocalizedString(@"Prompt", nil) message:message completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if (close) {
                close();
            }
        } cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    };
    if ([self isKindOfClass:[MMViewController class]]) {
        MMViewController *baseVC = (id)self;
        [baseVC.waitingForViewControllerVisible wait:alertBlock];
    } else {
        alertBlock();
    }
}

- (void)confirm:(NSString *)message approve:(void(^)())approve cancel:(void(^)())cancel {
    void(^confirmBlock)() = ^{
        [UIAlertView sf_alertWithTitle:NSLocalizedString(@"Prompt", nil) message:message completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if (buttonIndex != 0) {
                if (approve) {
                    approve();
                }
            } else {
                if (cancel) {
                    cancel();
                }
            }
        } cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    };
    if ([self isKindOfClass:[MMViewController class]]) {
        MMViewController *baseVC = (id)self;
        [baseVC.waitingForViewControllerVisible wait:confirmBlock];
    } else {
        confirmBlock();
    }
}

@end

@implementation UIViewController (ErrorHandling)

- (void)processingError:(NSError *)error retry:(void(^)())retry general:(void(^)(NSError *error))general {
    if (error.code == NSURLErrorTimedOut
        || error.code == SFWrappableServantTimeoutErrorCode
        || [error.localizedDescription hasSuffix:@"timeout."]) {
        void(^alertBlock)() = ^{
            [UIAlertView sf_alertWithTitle:NSLocalizedString(@"Prompt", nil) message:NSLocalizedString(@"Connect to server timeout.", nil) completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
                if (buttonIndex != 0) {
                    if (retry) {
                        retry();
                    }
                }
            } cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Retry", nil), nil];
        };
        if ([self isKindOfClass:[MMViewController class]] && retry) {
            MMViewController *baseVC = (id)self;
            [baseVC.waitingForViewControllerVisible wait:alertBlock];
        } else {
            alertBlock();
        }
    } else if (error.code == NSURLErrorNetworkConnectionLost) {
        [self alert:NSLocalizedString(@"Network connection disconnected.", nil)];
    } else {
        NSString *errMsg = [error localizedDescription];
        [self alert:errMsg close:^{
            if (general) {
                general(error);
            }
        }];
    }
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder success:(SFServantSuccess)success {
    [self sendServantWithBuilder:servantBuilder success:success identifier:nil];
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       success:(SFServantSuccess)success
                    identifier:(NSString *)identifier {
    __weak typeof(self) wself = self;
    [self sendServantWithBuilder:servantBuilder start:^{
        __strong typeof(wself) self = wself;
        [self sf_setWaiting:YES];
    } success:success finish:^{
        __strong typeof(wself) self = wself;
        [self sf_setWaiting:NO];
    } identifier:identifier];
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       start:(void(^)())start
                       success:(SFServantSuccess)success
                        finish:(SFServantFinish)finish {
    [self sendServantWithBuilder:servantBuilder start:start success:success finish:finish identifier:nil];
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                         start:(void(^)())start
                       success:(SFServantSuccess)success
                        finish:(SFServantFinish)finish
                    identifier:(NSString *)identifier {
    [self sendServantWithBuilder:servantBuilder
                           start:start
                         success:success
                    errorHandled:nil
                          finish:finish
                      identifier:identifier];
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                         start:(void(^)())start
                       success:(SFServantSuccess)success
                  errorHandled:(void(^)())errorHandled
                        finish:(SFServantFinish)finish
                    identifier:(NSString *)identifier {
    
    id<SFServant> servant = servantBuilder();
    
    if (start) {
        start();
    }
    
    __weak typeof(self) weakself = self;
    [self sf_sendServant:servant success:success error:^(NSError *error) {
        __strong typeof(weakself) self = weakself;
        [self processingError:error retry:^{
            __strong typeof(weakself) self = weakself;
            [self sendServantWithBuilder:servantBuilder
                                   start:start
                                 success:success
                            errorHandled:errorHandled
                                  finish:finish
                             identifier:identifier];
        } general:^(NSError *error) {
            if (errorHandled) {
                errorHandled();
            }
        }];
    } finish:finish identifier:identifier];
}

@end
