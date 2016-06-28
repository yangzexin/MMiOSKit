//
//  MMBaseTabController.h
//  MMiOSKit
//
//  Created by yangzexin on 7/29/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMViewController.h"

@interface MMBaseTabControllerSwitchingContext : NSObject

@property (nonatomic, assign, readonly) BOOL next;
@property (nonatomic, strong, readonly) UIViewController *switchingToViewController;
@property (nonatomic, strong, readonly) UIViewController *switchingFromViewController;

@end

@interface MMBaseTabController : MMViewController

@property (nonatomic, strong, readonly) SFSwitchTabController *compatibleTabController;

@property (nonatomic, strong) NSArray *viewControllers;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, assign) BOOL switchingByGestureEnabled;

@property (nonatomic, readonly) UIViewController *selectedViewController;

- (CGRect)frameForTabController;

- (UIViewController *)selectedViewController;

- (void)willChangeToSelectedIndex:(NSInteger)selectedIndex;
- (void)didChangeToSelectedIndex:(NSInteger)selectedIndex;

- (void)willBeginGestureSwitching:(MMBaseTabControllerSwitchingContext *)context;

- (void)selectNextViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;
- (void)selectPreviousViewControllerAnimated:(BOOL)animated completion:(void(^)())completion;

@end

@interface UIViewController (MMBaseTabViewController)

- (MMBaseTabController *)baseTabController;

@end