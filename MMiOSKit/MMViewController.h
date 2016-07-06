//
//  MMViewController.h
//  MMiOSKit
//
//  Created by suruochang on 14-3-18.
//  Copyright (c) 2014年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SFFoundation/SFFoundation.h>
#import <SFiOSKit/SFiOSKit.h>

@interface MMViewController : UIViewController

@property (nonatomic, assign) BOOL hidesNavigationBar;
@property (nonatomic, assign, readonly) BOOL visible;

@property (nonatomic, copy) void(^viewWillAppearObserver)();

+ (instancetype)controller;

+ (UIImage *)defaultLeftBarButtonItemImage;
+ (void)setDefaultLeftBarButtonItemImage:(UIImage *)image;

- (void)initialize;

- (void)whenWillVisible:(void(^)())block;
- (void)whenWillVisible:(void(^)())block identifier:(NSString *)identifier;

- (void)setLeftBarButtonItemAsBackButtonWithTap:(void(^)())tap;

- (SFBlockedBarButtonItem *)rightBarButtonItemWithImage:(UIImage *)image tap:(void(^)())tap;
- (SFBlockedBarButtonItem *)rightBarButtonItemWithTitle:(NSString *)title tap:(void(^)())tap;

@end

@interface UIViewController (MMDialogs)

- (void)alert:(NSString *)message;
- (void)alert:(NSString *)message close:(void(^)())close;

- (void)confirm:(NSString *)message approve:(void(^)())approve cancel:(void(^)())cancel;

@end

@interface UIViewController (ServantSupport)

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       success:(SFServantSuccess)success;

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                       success:(SFServantSuccess)success
                    identifier:(NSString *)identifier;

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                         start:(void(^)())start
                       success:(SFServantSuccess)success
                        finish:(SFServantFinish)finish;

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                         start:(void(^)())start
                       success:(SFServantSuccess)success
                        finish:(SFServantFinish)finish
                    identifier:(NSString *)identifier;

- (void)sendServantWithBuilder:(id<SFServant>(^)())servantBuilder
                         start:(void(^)())start
                       success:(SFServantSuccess)success
                  errorHandled:(void(^)())errorHandled
                        finish:(SFServantFinish)finish
                    identifier:(NSString *)identifier;

@end
