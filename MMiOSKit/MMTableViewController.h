//
//  MMTableViewController.h
//  Mormor
//
//  Created by yangzexin on 4/14/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MMViewController.h"

OBJC_EXPORT NSInteger const MMFirstPageIndex;

@interface MMTableViewController : MMViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak, readonly) UITableView *tableView;

@property (nonatomic, assign) BOOL pageDisabled;
@property (nonatomic, assign) NSInteger pageIndex;
@property (nonatomic, assign) NSInteger pageSize;
@property (nonatomic, assign) BOOL refreshEnabled;
@property (nonatomic, assign, readonly) BOOL refreshing;
@property (nonatomic, assign, readonly) BOOL loadingNext;

@property (nonatomic, copy) void(^refreshingPageDidTriggerListener)();

- (void)resetPageCursor;

- (void)loadNextPageDidTrigger;
- (void)refreshPageDidTrigger;

- (BOOL)decideWhetherHasMoreWithNumberOfResults:(NSInteger)numberOfResults;
- (void)pagingWithNumberOfResults:(NSInteger)numberOfResults;

- (void)restoreLoadingHeader;
- (void)restoreLoadingFooter;

- (void)triggerRefreshing;
- (void)endRefreshing;

- (UITableViewStyle)tableViewStyle;

- (UITableViewCellSelectionStyle)defaultCellSelectionStyle;

@end
