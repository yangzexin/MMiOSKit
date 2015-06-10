//
//  MMViewController+Private.h
//  MMNewFire
//
//  Created by yangzexin on 3/24/15.
//  Copyright (c) 2015 sf-express. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMViewController ()

@property (nonatomic, assign) BOOL visible;

@property (nonatomic, strong) SFWaiting *waitingForViewControllerVisible;

@property (nonatomic, copy) void(^didTapBackButton)();

@end
