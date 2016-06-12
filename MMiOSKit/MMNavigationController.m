//
//  MMNavigationController.m
//  MMiOSKit
//
//  Created by yangzexin on 6/12/16.
//  Copyright © 2016 yangzexin. All rights reserved.
//

#import "MMNavigationController.h"

@implementation MMNavigationController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [self.topViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [self.topViewController prefersStatusBarHidden];
}

@end
