//
//  MMNaviBarTabController.h
//  MMiOSKit
//
//  Created by yangzexin on 5/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMBaseTabController.h"

@interface MMNaviBarTabController : MMBaseTabController

@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIColor *pageIndicatorColor;
@property (nonatomic, strong) UIColor *pageIndicatorColorCurrent;

- (BOOL)shouldSwitchingTabOnTappingNavigationBar;

- (void)updatePageTitles;

- (void)didTapNavigationBar;

@end