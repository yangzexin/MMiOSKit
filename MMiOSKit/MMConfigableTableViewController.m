//
//  MMConfigableTableViewController.m
//  MMiOSKit
//
//  Created by yangzexin on 8/28/14.
//  Copyright (c) 2014 yangzexin. All rights reserved.
//

#import "MMConfigableTableViewController.h"

@implementation MMConfigableTableViewController

- (void)loadView {
    [super loadView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (UIView *)normalSectionHeaderWithTitle:(NSString *)title {
    return [self normalSectionHeaderWithTitle:title height:30.0f];
}

- (UIView *)normalSectionHeaderWithTitle:(NSString *)title height:(CGFloat)height {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, view.frame.size.width - height, view.frame.size.height)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor darkGrayColor];
    label.text = title;
    label.font = [UIFont systemFontOfSize:15.0f];
    [view addSubview:label];
    
    return view;
}

#pragma mark - UITableViewDelegate & dataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_keySectionValueRows objectForKey:[_sections objectAtIndex:section]] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 0;
    NSString *row = [[_keySectionValueRows objectForKey:[_sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    NSValue *heightCalculator = [self.keyRowValueHeightCalculator objectForKey:row];
    if (heightCalculator) {
        CGFloat(^calculator)() = (CGFloat(^)())[heightCalculator sf_block];
        height = calculator();
    } else {
        UIView *view = [_keyRowValueView objectForKey:row];
        if (view) {
            height = view.frame.size.height;
        }
    }
    
    return height;
}

- (UITableViewCell *)_headerCellWithRow:(NSString *)row {
    static NSString *identifier = @"header";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell sf_makeFrameCompatibleWithTableView:self.tableView];
        [cell sf_makeTransparent];
    }
    
    [cell.contentView sf_removeAllSubviews];
    
    UIView *view = [_keyRowValueView objectForKey:row];
    if (view) {
        [cell.contentView addSubview:view];
    }
    
    return cell;
}

- (UITableViewCell *)_cellForRow:(NSString *)row indexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"iden";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        [cell sf_makeFrameCompatibleWithTableView:self.tableView];
    }
    
    [cell.contentView sf_removeAllSubviews];
    
    UIView *view = [_keyRowValueView objectForKey:row];
    if (view) {
        [cell.contentView addSubview:view];
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    NSString *row = [[_keySectionValueRows objectForKey:[_sections objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    if ((_headerRows && [_headerRows indexOfObject:row] != NSNotFound) || self.transparentBackground) {
        cell = [self _headerCellWithRow:row];
    } else {
        cell = [self _cellForRow:row indexPath:indexPath];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

@end
