//
//  MMViewController.h
//  Mormor
//
//  Created by suruochang on 14-3-18.
//  Copyright (c) 2014年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SFFoundation/SFFoundation.h>
#import <SFiOSKit/SFiOSKit.h>

@interface MMViewController : UIViewController

@property (nonatomic, assign) BOOL hidesNavigationBar;

@property (nonatomic, copy) void(^viewWillAppearObserver)();

+ (instancetype)controller;

+ (UIImage *)defaultLeftBarButtonItemImage;
+ (void)setDefaultBarButtonItemImage:(UIImage *)image;

- (void)initialize;

- (void)waitUntilVisible:(void(^)())block;
- (void)waitUntilVisible:(void(^)())block identifier:(NSString *)identifier;

- (void)setLeftBarButtonItemAsBackButtonWithHandler:(void(^)())handler;

- (SFBlockedBarButtonItem *)rightBarButtonItemWithImage:(UIImage *)image handler:(void(^)())handler;
- (SFBlockedBarButtonItem *)rightBarButtonItemWithTitle:(NSString *)title handler:(void(^)())handler;

@end

@interface UIViewController (MMDialogs)

- (void)alert:(NSString *)message;
- (void)alert:(NSString *)message completed:(void(^)())completed;

- (void)confirm:(NSString *)message approved:(void(^)())approve cancelled:(void(^)())cancel;

@end

@interface UIViewController (ServantSupport)

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                     succeeded:(SFServantSucceeded)succeeded;

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       started:(void(^)())started
                     succeeded:(SFServantSucceeded)succeeded
                     completed:(SFServantCompleted)completed;

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       started:(void(^)())started
                     succeeded:(SFServantSucceeded)succeeded
                     completed:(SFServantCompleted)completed
                    identifier:(NSString *)identifier;

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       started:(void(^)())started
                     succeeded:(SFServantSucceeded)succeeded
                  errorHandled:(void(^)())errorHandled
                     completed:(SFServantCompleted)completed
                    identifier:(NSString *)identifier;

@end
