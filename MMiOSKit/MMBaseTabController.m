//
//  MMBaseTabController.m
//  Mormor
//
//  Created by yangzexin on 7/29/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "MMBaseTabController.h"

@interface MMBaseTabControllerSwitchingContext ()

@property (nonatomic, assign) BOOL next;
@property (nonatomic, strong) UIViewController *switchingToViewController;
@property (nonatomic, strong) UIViewController *switchingFromViewController;

@end

@implementation MMBaseTabControllerSwitchingContext

@end

@interface MMBaseTabController () <SFSwitchTabControllerDelegate>

@property (nonatomic, strong) SFSwitchTabController *compatibleTabController;

@end

@implementation MMBaseTabController

- (void)initialize
{
    [super initialize];
    self.switchingByGestureEnabled = YES;
    
    self.compatibleTabController = [SFSwitchTabController new];
}

- (void)loadView
{
    [super loadView];
    
    self.compatibleTabController.scrollable = YES;
    self.compatibleTabController.delegate = self;
    self.compatibleTabController.view.frame = [self frameForTabController];
    self.compatibleTabController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addChildViewController:self.compatibleTabController];
    [self.view addSubview:self.compatibleTabController.view];
    [self.compatibleTabController didMoveToParentViewController:self];
    
    if (self.viewControllers) {
        self.compatibleTabController.viewControllers = self.viewControllers;
    }
    
    __weak typeof(self) weakself = self;
    [SFTrackProperty(self, switchingByGestureEnabled) change:^(id value) {
        __strong typeof(weakself) self = weakself;
        self.compatibleTabController.scrollable = self.switchingByGestureEnabled;
    }];
    
    [SFTrackProperty(self, selectedIndex) change:^(id value) {
        __strong typeof(weakself) self = weakself;
        self.compatibleTabController.selectedIndex = [value integerValue];
    }];
}

- (void)_selectViewControllerAnimated:(BOOL)animated next:(BOOL)next completion:(void(^)())completion
{
    NSInteger nextSelectedIndex = self.selectedIndex + (next ? 1 : -1);
    
    if (nextSelectedIndex < 0) {
        nextSelectedIndex = self.viewControllers.count - 1;
    } else if (nextSelectedIndex > self.viewControllers.count - 1) {
        nextSelectedIndex = 0;
    }
    __weak typeof(self) weakself = self;
    [self.compatibleTabController setSelectedIndex:nextSelectedIndex animated:animated completion:^{
        if (completion) {
            completion();
        }
        __strong typeof(weakself) self = weakself;
        [self didChangeToSelectedIndex:nextSelectedIndex];
    }];
}

- (void)selectNextViewControllerAnimated:(BOOL)animated completion:(void(^)())completion
{
    [self _selectViewControllerAnimated:animated next:YES completion:completion];
}

- (void)selectPreviousViewControllerAnimated:(BOOL)animated completion:(void(^)())completion
{
    [self _selectViewControllerAnimated:animated next:NO completion:completion];
}

- (CGRect)frameForTabController
{
    return self.view.bounds;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    
    for (UIViewController *controller in viewControllers) {
        [controller sf_setAssociatedObject:[NSValue sf_valueWithWeakObject:self] key:@"baseTabViewController"];
    }
    _compatibleTabController.viewControllers = viewControllers;
}

- (UIViewController *)selectedViewController
{
    return [_compatibleTabController selectedViewController];
}

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated
{
}

- (void)willChangeToSelectedIndex:(NSInteger)selectedIndex
{
}

- (void)didChangeToSelectedIndex:(NSInteger)selectedIndex
{
}

- (void)willBeginGestureSwitching:(MMBaseTabControllerSwitchingContext *)context
{
}

- (void)switchTabController:(SFSwitchTabController *)switchTabController willSwitchToIndex:(NSInteger)index
{
    UIViewController *currentViewController = [self.viewControllers objectAtIndex:self.selectedIndex];
    UIViewController *nextViewController = [self.viewControllers objectAtIndex:index];
    BOOL next = index > self.selectedIndex;
    MMBaseTabControllerSwitchingContext *context = [MMBaseTabControllerSwitchingContext new];
    context.next = next;
    context.switchingFromViewController = currentViewController;
    context.switchingToViewController = nextViewController;
    [self willBeginGestureSwitching:context];
    
    _selectedIndex = index;
}

- (void)switchTabController:(SFSwitchTabController *)switchTabController didSwitchToIndex:(NSInteger)index
{
    [self didChangeToSelectedIndex:index];
}

@end

@implementation UIViewController (MMBaseTabViewController)

- (MMBaseTabController *)baseTabController
{
    return [[self sf_associatedObjectWithKey:@"baseTabViewController"] sf_weakObject];
}

@end