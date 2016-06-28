//
//  MMConfigableTableViewController.h
//  MMiOSKit
//
//  Created by yangzexin on 8/28/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMTableViewController.h"

@interface MMConfigableTableViewController : MMTableViewController

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) NSDictionary *keySectionValueRows;
@property (nonatomic, strong) NSDictionary *keyRowValueView;
@property (nonatomic, strong) NSDictionary *keyRowValueHeightCalculator;
@property (nonatomic, strong) NSArray *headerRows;

@property (nonatomic, assign) BOOL transparentBackground;

- (UIView *)normalSectionHeaderWithTitle:(NSString *)title;
- (UIView *)normalSectionHeaderWithTitle:(NSString *)title height:(CGFloat)height;

@end
