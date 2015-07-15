//
//  MMTableViewController.m
//  Mormor
//
//  Created by yangzexin on 4/14/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "MMTableViewController.h"

#import "SVPullToRefresh.h"

NSInteger const MMFirstPageIndex = 1;

@interface MMTableViewController ()

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UIRefreshControl *refreshControl;

@property (nonatomic, assign) BOOL refreshing;
@property (nonatomic, assign) BOOL loadingNext;

@end

@implementation MMTableViewController

- (void)dealloc {
    self.tableView.showsPullToRefresh = NO;
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
}

- (void)initialize {
    [super initialize];
    self.pageSize = 20;
}

- (void)loadView {
    [super loadView];
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:[self tableViewStyle]];
    self.tableView = tableView;
    tableView.scrollsToTop = YES;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = [UIView new];
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    
    if (_refreshEnabled) {
        [self sf_setCenterTipsTransparent:YES];
        
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.tintColor = [UIColor sf_colorWithRed:210 green:210 blue:210];
        [refreshControl addTarget:self action:@selector(_dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
        [self.tableView addSubview:refreshControl];
        self.refreshControl = refreshControl;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self resetPageCursor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.tableView.scrollsToTop = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    self.tableView.scrollsToTop = NO;
}

- (void)resetPageCursor {
    self.pageIndex = MMFirstPageIndex;
}

- (void)_dropViewDidBeginRefreshing:(id)refreshControl {
    [self triggerRefreshing];
}

- (void)refreshPageDidTrigger {
    
}

- (void)triggerRefreshing {
    self.pageIndex = MMFirstPageIndex;
    self.refreshing = YES;
    [self restoreLoadingFooter];
    if (self.whenRefreshingPageDidTrigger) {
        self.whenRefreshingPageDidTrigger();
    }
    [self refreshPageDidTrigger];
}

- (void)endRefreshing {
    self.refreshing = NO;
    [self.refreshControl endRefreshing];
}

- (void)loadNextPageDidTrigger {
}

- (BOOL)_isRefreshControlRefreshing {
    return [self.refreshControl isRefreshing];
}

- (void)setShouldLoadMore:(BOOL)more {
    self.refreshing = NO;
    if ([self _isRefreshControlRefreshing]) {
        [_refreshControl endRefreshing];
    }
    if (!_pageDisabled && self.tableView.pullToRefreshView == nil) {
        __weak typeof(self) weakSelf = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
            __strong typeof(weakSelf) self = weakSelf;
            self.loadingNext = YES;
            [self restoreLoadingHeader];
            [self loadNextPageDidTrigger];
        } position:SVPullToRefreshPositionBottom];
        [self.tableView.pullToRefreshView setTitle:@"上拉加载.." forState:SVPullToRefreshStateAll];
        [self.tableView.pullToRefreshView setTitle:@"加载中.." forState:SVPullToRefreshStateLoading];
        [self.tableView.pullToRefreshView setTitle:@"立即加载.." forState:SVPullToRefreshStateTriggered];
    }
    self.loadingNext = NO;
    if (!self.pageDisabled) {
        [self.tableView.pullToRefreshView stopAnimating];
        self.tableView.showsPullToRefresh = more;
    }
}

- (BOOL)decideWhetherHasMoreWithNumberOfResults:(NSInteger)numberOfResults {
    return numberOfResults != 0 && numberOfResults >= self.pageSize;
}

- (void)pagingWithNumberOfResults:(NSInteger)numberOfResults {
    BOOL more = [self decideWhetherHasMoreWithNumberOfResults:numberOfResults];
    
    [self setShouldLoadMore:more];
    if (more) {
        ++_pageIndex;
    }
}

- (void)restoreLoadingHeader {
    self.refreshing = NO;
    if ([self _isRefreshControlRefreshing]) {
        [_refreshControl endRefreshing];
    }
}

- (void)restoreLoadingFooter {
    if (!self.pageDisabled) {
        [self.tableView.pullToRefreshView stopAnimating];
    }
    self.loadingNext = NO;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStylePlain;
}

- (UITableViewCellSelectionStyle)defaultCellSelectionStyle {
    return SFDeviceSystemVersion < 7.0f ? UITableViewCellSelectionStyleBlue : UITableViewCellSelectionStyleDefault;
}

- (BOOL)sf_loadingOrWaitingShowable {
    return !_refreshing && !_loadingNext;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"DefaultCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"(%@)NULL CELL - %ld %ld", NSStringFromClass([self class]), (long)indexPath.section, (long)indexPath.row];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
}

@end
