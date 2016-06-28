//
//  MMTopMostView.m
//  MMiOSKit
//
//  Created by yangzexin on 6/14/15.
//  Copyright (c) 2015 yangzexin. All rights reserved.
//

#import "MMTopMostView.h"

@interface MMTopMostView ()

@property (nonatomic, weak) UIView *backgroundView;

@property (nonatomic, weak) UIView *presentingView;

@property (nonatomic, weak) UIView *containerView;

@end

@implementation MMTopMostView

- (id)initWithContainerView:(UIView *)containerView {
    self = [super init];
    
    self.containerView = containerView;
    
    return self;
}

- (id)initFromLastWindow {
    self = [self initWithContainerView:[[[UIApplication sharedApplication] windows] lastObject]];
    
    return self;
}

- (void)initialize {
    [super initialize];
    
    self.presentingAnimation = self;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    __weak typeof(self) weakSelf = self;
    [backgroundView sf_addTapListener:^{
        __strong typeof(weakSelf) self = weakSelf;
        if (self.whenTapBackground) {
            self.whenTapBackground();
        }
    }];
    [self addSubview:backgroundView];
    self.backgroundView = backgroundView;
}

- (void)presentWithView:(UIView *)view completion:(void(^)())completion {
    NSAssert(self.superview == nil, @"This Top most view is presenting");
    
    self.presentingView = view;
    [self addSubview:self.presentingView];
    
    UIView *superView = self.containerView;
    self.frame = superView.bounds;
    [superView addSubview:self];
    
    self.backgroundView.alpha = .0f;
    [self.presentingAnimation topMostView:self preparingPresentingAnimation:self.presentingView];
    [UIView animateWithDuration:.50f animations:^{
        self.backgroundView.alpha = .50f;
        [self.presentingAnimation topMostView:self presentingAnimation:self.presentingView];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        [self.presentingAnimation topMostView:self didFinishPresentingAnimation:self.presentingView];
    }];
}

- (void)dismissWithCompletion:(void(^)())completion {
    [self.presentingAnimation topMostView:self preparingDismissingAnimation:self.presentingView];
    self.backgroundView.alpha = .50f;
    [UIView animateWithDuration:.25f animations:^{
        self.backgroundView.alpha = .0f;
        [self.presentingAnimation topMostView:self dismissingAnimation:self.presentingView];
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
        [self.presentingAnimation topMostView:self didFinishDismissingAnimation:self.presentingView];
        [self removeFromSuperview];
    }];
}

#pragma mark - Default animation
- (void)_movePresentingViewToBottom:(UIView *)presentingView {
    [self sf_setAssociatedObject:@(presentingView.frame.origin.y) key:@"_presentingViewOriginalY"];
    CGRect tmpFrame = presentingView.frame;
    tmpFrame.origin.y = self.bounds.size.height;
    presentingView.frame = tmpFrame;
}

- (void)_restorePresentingView:(UIView *)presentingView {
    CGFloat originalY = [[self sf_associatedObjectWithKey:@"_presentingViewOriginalY"] floatValue];
    CGRect tmpFrame = presentingView.frame;
    tmpFrame.origin.y = originalY;
    presentingView.frame = tmpFrame;
}

- (void)topMostView:(MMTopMostView *)topMostView preparingPresentingAnimation:(UIView *)presentingView {
    [self _movePresentingViewToBottom:presentingView];
}

- (void)topMostView:(MMTopMostView *)topMostView presentingAnimation:(UIView *)presentingView {
    [self _restorePresentingView:presentingView];
}

- (void)topMostView:(MMTopMostView *)topMostView didFinishPresentingAnimation:(UIView *)presentingView {
}

- (void)topMostView:(MMTopMostView *)topMostView preparingDismissingAnimation:(UIView *)presentingView {
}

- (void)topMostView:(MMTopMostView *)topMostView dismissingAnimation:(UIView *)presentingView {
    [self _movePresentingViewToBottom:presentingView];
}

- (void)topMostView:(MMTopMostView *)topMostView didFinishDismissingAnimation:(UIView *)presentingView {
    [self _restorePresentingView:presentingView];
}

@end
