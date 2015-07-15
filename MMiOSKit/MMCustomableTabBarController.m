//
//  MMCustomableTabBarController.m
//  Mormor
//
//  Created by yangzexin on 11/20/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "MMCustomableTabBarController.h"

@interface MMCustomableTabBarController ()

@property (nonatomic, strong) UIView *barContainerView;

@end

@implementation MMCustomableTabBarController

- (void)loadView {
    [super loadView];
    
    self.barContainerView = [[UIView alloc] initWithFrame:self.tabBar.bounds];
    self.barContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.barContainerView.backgroundColor = [UIColor whiteColor];
    [self.tabBar addSubview:self.barContainerView];

    if (SFDeviceSystemVersion >= 7.0f) {
        [[UITabBar appearance] setShadowImage:[UIImage sf_imageWithColor:[UIColor sf_colorFromHex:0xdddddd] size:CGSizeMake(1, SFLightLineWidth)]];
        [[UITabBar appearance] setBackgroundImage:[UIImage sf_imageWithColor:[UIColor clearColor] size:CGSizeMake(1, 1)]];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tabBar bringSubviewToFront:self.barContainerView];
}

@end
