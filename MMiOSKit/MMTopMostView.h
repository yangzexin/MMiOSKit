//
//  MMTopMostView.h
//  MMiOSKit
//
//  Created by yangzexin on 6/14/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <SFFoundation/SFFoundation.h>
#import <SFiOSKit/SFiOSKit.h>

@class MMTopMostView;

@protocol MMTopMostViewPresentingAnimation <NSObject>

- (void)topMostView:(MMTopMostView *)topMostView preparingPresentingAnimation:(UIView *)presentingView;
- (void)topMostView:(MMTopMostView *)topMostView presentingAnimation:(UIView *)presentingView;
- (void)topMostView:(MMTopMostView *)topMostView didFinishPresentingAnimation:(UIView *)presentingView;

- (void)topMostView:(MMTopMostView *)topMostView preparingDismissingAnimation:(UIView *)presentingView;
- (void)topMostView:(MMTopMostView *)topMostView dismissingAnimation:(UIView *)presentingView;
- (void)topMostView:(MMTopMostView *)topMostView didFinishDismissingAnimation:(UIView *)presentingView;

@end

@interface MMTopMostView : SFIBCompatibleView <MMTopMostViewPresentingAnimation>

@property (nonatomic, weak) id<MMTopMostViewPresentingAnimation> presentingAnimation;

@property (nonatomic, copy) void(^whenTapBackground)();

- (id)initWithContainerView:(UIView *)containerView;
- (id)initFromLastWindow;

- (void)presentWithView:(UIView *)view completion:(void(^)())completion;
- (void)dismissWithCompletion:(void(^)())completion;

@end
