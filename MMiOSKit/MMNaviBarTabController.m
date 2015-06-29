//
//  SFNaviBarTabController.m
//  Mormor
//
//  Created by yangzexin on 5/5/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "MMNaviBarTabController.h"

@interface MMNaviBarTabController ()

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIView *titleLabelContainerView;
@property (nonatomic, strong) NSArray *titleLabels;
@property (nonatomic, strong) SFPageIndicator *pageIndicator;

@end

@implementation MMNaviBarTabController

- (void)initialize
{
    [super initialize];
    self.titleColor = [UIColor sf_colorWithRed:72 green:72 blue:72 alpha:100];
    self.pageIndicatorColor = [UIColor sf_colorWithRed:230 green:230 blue:230];
    self.pageIndicatorColorCurrent = [UIColor sf_colorWithRed:190 green:190 blue:190];
}

- (void)loadView
{
    [super loadView];
//    self.switchingByGestureEnabled = YES;
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.navigationController.navigationBar.frame.size.width - 120, self.navigationController.navigationBar.frame.size.height)];
    titleView.backgroundColor = [UIColor clearColor];
    self.titleView = titleView;
    [self.titleView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_titleViewTapGestureRecognizer:)]];
    
    self.pageIndicator = [[SFPageIndicator alloc] initWithFrame:CGRectMake(0, titleView.frame.size.height - 15, titleView.frame.size.width, 10)];
    self.pageIndicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    self.pageIndicator.currentIndicatorImage = [UIImage sf_circleImageWithSize:CGSizeMake(9, 9) color:self.pageIndicatorColorCurrent];
    self.pageIndicator.indicatorImage = [UIImage sf_circleImageWithSize:CGSizeMake(9, 9) color:self.pageIndicatorColor];
    self.pageIndicator.spacing = 12.0f;
    self.pageIndicator.backgroundColor = [UIColor clearColor];
    [titleView addSubview:self.pageIndicator];
    
    self.titleLabelContainerView = [[UIView alloc] initWithFrame:titleView.bounds];
    self.titleLabelContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.titleLabelContainerView.backgroundColor = [UIColor clearColor];
    [titleView addSubview:self.titleLabelContainerView];
    
    self.navigationItem.titleView = self.titleView;
    
    [self _updateTitleView];
    
    __weak typeof(self) weakself = self;
    [SFTrackProperty(self.compatibleTabController.scrollView, contentOffset) change:^(id value) {
        __strong typeof(weakself) self = weakself;
        if (self.titleLabels.count != 0) {
            CGPoint contentOffset = [value CGPointValue];
            [self _updateTitleLabelWithContentOffset:contentOffset];
        }
    }];
    
    [SFTrackProperty(self.compatibleTabController, selectedIndex) change:^(id value) {
        __strong typeof(weakself) self = weakself;
        [self _updateTitleView];
        [self _updateTitleLabelWithContentOffset:self.compatibleTabController.scrollView.contentOffset];
    }];
    
    [SFTrackProperty(self.compatibleTabController, viewControllers) change:^(NSArray *viewControllers) {
        __strong typeof(weakself) self = weakself;
        [self _rebuildTitleLabels];
    }];
}

- (void)_rebuildTitleLabels
{
    [self.titleLabelContainerView sf_removeAllSubviews];
    
    NSMutableArray *titleLabels = [NSMutableArray array];
    for (NSInteger i = 0; i < self.viewControllers.count; ++i) {
        UIViewController *controller = [self.viewControllers objectAtIndex:i];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i * self.compatibleTabController.scrollView.frame.size.width / 2, 0, self.titleView.frame.size.width, self.titleView.frame.size.height - self.pageIndicator.frame.size.height)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 0.0f;
        titleLabel.textColor = self.titleColor;
        titleLabel.text = controller.title;
        [self.titleLabelContainerView addSubview:titleLabel];
        
        [titleLabels addObject:titleLabel];
    }
    
    self.titleLabels = titleLabels;
}

- (void)_updateTitleLabelWithContentOffset:(CGPoint)contentOffset
{
    CGRect tmpFrame = self.titleLabelContainerView.frame;
    tmpFrame.origin.x = -contentOffset.x / 2;
    self.titleLabelContainerView.frame = tmpFrame;;
    CGFloat labelIndexF = (contentOffset.x + self.compatibleTabController.scrollView.frame.size.width) / self.compatibleTabController.scrollView.frame.size.width;
    CGFloat alpha = labelIndexF - (NSInteger)labelIndexF;
    NSInteger labelIndex = (NSInteger)labelIndexF - 1;
    
    if (labelIndex >= 0 && labelIndex < self.titleLabels.count) {
        
        UILabel *centerLabel = [self.titleLabels objectAtIndex:labelIndex];
        centerLabel.alpha = 1.0f - alpha;
        
        if (labelIndex - 1 >= 0) {
            UILabel *leftLabel = [self.titleLabels objectAtIndex:labelIndex - 1];
            leftLabel.alpha = alpha;
        }
        
        if (labelIndex + 1 < self.titleLabels.count) {
            UILabel *nextLabel = [self.titleLabels objectAtIndex:labelIndex + 1];
            nextLabel.alpha = alpha;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)updatePageTitles
{
    [self _rebuildTitleLabels];
    [self _updateTitleView];
}

- (void)_updateTitleView
{
    if (self.viewControllers.count != 1) {
        self.pageIndicator.numberOfPages = self.viewControllers.count;
        self.pageIndicator.hidden = NO;
    } else {
        self.pageIndicator.hidden = NO;
    }
    self.pageIndicator.currentPageIndex = self.compatibleTabController.selectedIndex;
    [self _updateTitleLabelWithContentOffset:self.compatibleTabController.scrollView.contentOffset];
}

- (void)didTapNavigationBar
{
}

- (void)_titleViewTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if ([self shouldSwitchingTabOnTappingNavigationBar]) {
        [self selectNextViewControllerAnimated:YES completion:nil];
    }
    [self didTapNavigationBar];
}

- (BOOL)shouldSwitchingTabOnTappingNavigationBar
{
    return YES;
}

- (void)setTitle:(NSString *)title
{
    self.navigationItem.titleView = self.titleView;
}

- (void)didChangeToSelectedIndex:(NSInteger)selectedIndex
{
    [super didChangeToSelectedIndex:selectedIndex];
    [self _updateTitleView];
}

- (void)willBeginGestureSwitching:(MMBaseTabControllerSwitchingContext *)context
{
    [super willBeginGestureSwitching:context];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [super setViewControllers:viewControllers];
    [self _updateTitleView];
}

@end
