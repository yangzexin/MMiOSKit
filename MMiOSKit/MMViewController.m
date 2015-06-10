//
//  MMViewController.m
//  Mormor
//
//  Created by suruochang on 14-3-18.
//  Copyright (c) 2014年 SF. All rights reserved.
//

#import "MMViewController.h"

#import "MMViewController-private.h"

@implementation MMViewController

+ (instancetype)controller
{
    id controller = [self new];
    
    return controller;
}

static UIImage *MMLeftBarButtonItemImage = nil;

+ (UIImage *)defaultLeftBarButtonItemImage
{
    return MMLeftBarButtonItemImage == nil ? [@"✕" sf_imageWithFont:[UIFont systemFontOfSize:30.0f] textColor:[UIColor whiteColor]] : MMLeftBarButtonItemImage;
}

+ (void)setDefaultBarButtonItemImage:(UIImage *)image
{
    MMLeftBarButtonItemImage = image;
}

- (void)dealloc
{
#ifdef DEBUG
    NSLog(@"%@ %@ dealloc", self.title, NSStringFromClass([self class]));
#endif
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init
{
    self = [self initWithNibName:nil bundle:nil];
    
    return self;
}

- (void)initialize
{
    __weak typeof(self) weakSelf = self;
    self.waitingForViewControllerVisible = [SFWaiting waitWithCondition:^BOOL{
        __weak typeof(weakSelf) self = weakSelf;
        return self.visible;
    }];
}

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = SFRGB(245, 245, 245);
    if (self.didTapBackButton) {
        self.navigationItem.leftBarButtonItem = [MMViewController normalLeftBarButtonItemWithImage:[MMViewController defaultLeftBarButtonItemImage] handler:self.didTapBackButton];
    }
    
    if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)waitUntilVisible:(void(^)())block
{
    [_waitingForViewControllerVisible wait:block];
}

- (void)waitUntilVisible:(void(^)())block identifier:(NSString *)identifier
{
    [_waitingForViewControllerVisible wait:block uniqueIdentifier:identifier];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.visible = YES;
    [self.navigationController setNavigationBarHidden:self.hidesNavigationBar animated:animated];
    if (self.viewWillAppearObserver) {
        self.viewWillAppearObserver();
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.visible = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)setLeftBarButtonItemAsBackButtonWithHandler:(void(^)())handler
{
    self.didTapBackButton = handler;
}

- (SFBlockedBarButtonItem *)rightBarButtonItemWithImage:(UIImage *)image handler:(void(^)())handler
{
    return [MMViewController normalRightBarButtonItemWithImage:image handler:handler];
}

- (SFBlockedBarButtonItem *)rightBarButtonItemWithTitle:(NSString *)title handler:(void(^)())handler
{
    return [MMViewController normalRightBarButtonItemWithTitle:title handler:handler];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && self.view.window == nil) {
        self.view = nil;
    }
    
    [self.waitingForViewControllerVisible cancelAll];
}

- (void)setHidesNavigationBar:(BOOL)hidesNavigationBar
{
    _hidesNavigationBar = hidesNavigationBar;
    for (UIViewController *viewController in self.childViewControllers) {
        if ([viewController respondsToSelector:@selector(setHidesNavigationBar:)]) {
            [(id)viewController setHidesNavigationBar:_hidesNavigationBar];
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    [self.view endEditing:YES];
}

#pragma mark - Normal Bar button
+ (SFBlockedBarButtonItem *)normalRightBarButtonItemWithImage:(UIImage *)image handler:(void(^)())handler
{
    SFBlockedBarButtonItem *item  = [SFBlockedBarButtonItem blockedBarButtonItemWithCustomView:({
        SFBlockedButton *button = [SFBlockedButton blockedButtonWithTapHandler:handler];
        [button setImage:image forState:UIControlStateNormal];
        button.frame = CGRectMake(0, 0, button.currentImage.size.width, button.currentImage.size.height);
        button;
    })];
    
    return item;
}

+ (SFBlockedBarButtonItem *)normalRightBarButtonItemWithTitle:(NSString *)title handler:(void(^)())handler
{
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
    button.tapHandler = handler;
    
    return buttonItem;
}

+ (SFBlockedBarButtonItem *)normalLeftBarButtonItemWithTitle:(NSString *)title handler:(void(^)())handler
{
    return [self normalRightBarButtonItemWithTitle:title handler:handler];
}

+ (SFBlockedBarButtonItem *)normalLeftBarButtonItemWithImage:(UIImage *)image handler:(void (^)())handler
{
    return [self normalRightBarButtonItemWithImage:image handler:handler];
}

@end

@implementation UIViewController (MMDialogs)

- (void)alert:(NSString *)message
{
    [self alert:message completed:nil];
}

- (void)alert:(NSString *)message completed:(void(^)())completed
{
    void(^alertBlock)() = ^{
        [UIAlertView sf_alertWithTitle:NSLocalizedString(@"Prompt", nil) message:message completion:^(NSInteger buttonIndex, NSString *buttonTitle) {
            if (completed) {
                completed();
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

- (void)confirm:(NSString *)message approved:(void(^)())approve cancelled:(void(^)())cancel
{
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

- (void)processingError:(NSError *)error retry:(void(^)())retry general:(void(^)(NSError *error))general
{
    if (error.code == NSURLErrorTimedOut) {
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
        [self alert:errMsg completed:^{
            if (general) {
                general(error);
            }
        }];
    }
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                     succeeded:(SFServantSucceeded)succeeded
{
    __weak typeof(self) wself = self;
    [self sendServantWithBuilder:servantBuilder started:^{
        __strong typeof(wself) self = wself;
        [self sf_setWaiting:YES];
    } succeeded:succeeded completed:^{
        __strong typeof(wself) self = wself;
        [self sf_setWaiting:NO];
    }];
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       started:(void(^)())started
                     succeeded:(SFServantSucceeded)succeeded
                     completed:(SFServantCompleted)completed
{
    [self sendServantWithBuilder:servantBuilder started:started succeeded:succeeded completed:completed identifier:nil];
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       started:(void(^)())started
                     succeeded:(SFServantSucceeded)succeeded
                     completed:(SFServantCompleted)completed
                    identifier:(NSString *)identifier
{
    [self sendServantWithBuilder:servantBuilder
                         started:started
                       succeeded:succeeded
                    errorHandled:nil
                       completed:completed
                      identifier:identifier];
}

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       started:(void(^)())started
                     succeeded:(SFServantSucceeded)succeeded
                  errorHandled:(void(^)())errorHandled
                     completed:(SFServantCompleted)completed
                    identifier:(NSString *)identifier
{
    
    id<SFServant> servant = servantBuilder();
    
    if (started) {
        started();
    }
    
    __weak typeof(self) weakself = self;
    [self sf_sendServant:servant succeeded:succeeded failed:^(NSError *error) {
        __strong typeof(weakself) self = weakself;
        [self processingError:error retry:^{
            __strong typeof(weakself) self = weakself;
            [self sendServantWithBuilder:servantBuilder
                                started:started
                              succeeded:succeeded
                           errorHandled:errorHandled
                              completed:completed
                             identifier:identifier];
        } general:^(NSError *error) {
            if (errorHandled) {
                errorHandled();
            }
        }];
    } completed:completed identifier:identifier];
}

@end
