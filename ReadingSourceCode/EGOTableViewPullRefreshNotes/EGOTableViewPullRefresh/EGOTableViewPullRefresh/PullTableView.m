//
//  PullTableView.m
//  TableViewPull
//
//  Created by Emre Berge Ergenekon on 2011-07-30.
//  Copyright 2011 Emre Berge Ergenekon. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PullTableView.h"
#import "UIView+Layout.h"

@interface PullTableView (Private) <UIScrollViewDelegate>

- (void)config;
- (void)configDisplayProperties;

@end

@implementation PullTableView

# pragma mark - Initialization / Deallocation

@synthesize pullDelegate;
@synthesize loadMoreViewEnable;
@synthesize refreshingViewEnable;
@synthesize refreshView;
@synthesize loadMoreView;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        [self config];
    }
    return self;
}

- (void)dealloc
{
    
}

# pragma mark - Custom view configuration

- (void) config
{
    /* Message interceptor to intercept scrollView delegate messages */
    delegateInterceptor = [[MessageInterceptor alloc] init];
    delegateInterceptor.middleMan = self;
    delegateInterceptor.receiver = self.delegate;
    super.delegate = (id)delegateInterceptor;
    NSLog(@"%@", self.delegate);
    
    /* Status Properties */
    pullTableIsRefreshing = NO;
    pullTableIsLoadingMore = NO;
    
    refreshingViewEnable = YES;
    /* Refresh View */
    self.refreshView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, -self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    refreshView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    refreshView.delegate = self;
    [self addSubview:refreshView];
    
    loadMoreViewEnable = YES;
    /* Load more view init */
    self.loadMoreView = [[LoadMoreTableFooterView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    loadMoreView.delegate = self;
    [self addSubview:loadMoreView];
    
    self.pullTextColor = [UIColor colorWithRed:120/255.0 green:120/255.0 blue:120/255.0 alpha:1];
}

#pragma mark - Event

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    if ([pullDelegate conformsToProtocol:@protocol(PullTableViewDelegate)] &&
        [pullDelegate respondsToSelector:@selector(tableView:touchesBegan:withEvent:)]) {
        [pullDelegate tableView:self touchesBegan:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    
    if ([pullDelegate conformsToProtocol:@protocol(PullTableViewDelegate)] &&
        [pullDelegate respondsToSelector:@selector(tableView:touchesCancelled:withEvent:)]) {
        [pullDelegate tableView:self touchesCancelled:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    
    if ([pullDelegate conformsToProtocol:@protocol(PullTableViewDelegate)] &&
        [pullDelegate respondsToSelector:@selector(tableView:touchesEnded:withEvent:)]) {
        [pullDelegate tableView:self touchesEnded:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    
    if ([pullDelegate conformsToProtocol:@protocol(PullTableViewDelegate)] &&
        [pullDelegate respondsToSelector:@selector(tableView:touchesMoved:withEvent:)]) {
        [pullDelegate tableView:self touchesMoved:touches withEvent:event];
    }
}

#pragma mark - View changes

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (loadMoreViewEnable) {
        CGFloat visibleTableDiffBoundsHeight = (self.bounds.size.height - MIN(self.bounds.size.height, self.contentSize.height));
        
        CGRect loadMoreFrame = loadMoreView.frame;
        loadMoreFrame.origin.y = self.contentSize.height + visibleTableDiffBoundsHeight;
        loadMoreView.frame = loadMoreFrame;
    } else {
        if (loadMoreView) {
            [loadMoreView removeFromSuperview];
            loadMoreView = nil;
        }
    }
    
    if (!refreshingViewEnable) {
        if (refreshView) {
            [refreshView removeFromSuperview];
            refreshView = nil;
        }
    }
}

#pragma mark - Preserving the original behaviour

- (void)setDelegate:(id<UITableViewDelegate>)delegate
{
    if (delegateInterceptor) {
        super.delegate = nil;
        if (delegate) {
            delegateInterceptor.receiver = delegate;
            super.delegate = (id)delegateInterceptor;
        }
    } else {
        if (delegate) {
            super.delegate = delegate;
        }
    }
}

- (void)reloadData
{
    [super reloadData];
    // Give the footers a chance to fix it self.
    if (loadMoreViewEnable) {
        [loadMoreView egoRefreshScrollViewDidScroll:self];
    }
}

#pragma mark - Status Propreties

@synthesize pullTableIsRefreshing;
@synthesize pullTableIsLoadingMore;

- (void)setPullTableIsRefreshing:(BOOL)isRefreshing
{
    if (!pullTableIsRefreshing && isRefreshing) {
        // If not allready refreshing start refreshing
        [refreshView startAnimatingWithScrollView:self];
        pullTableIsRefreshing = YES;
        [pullDelegate pullTableViewDidTriggerRefresh:self];
    } else if (pullTableIsRefreshing && !isRefreshing) {
        [refreshView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
        pullTableIsRefreshing = NO;
    }
}

- (void)setPullTableIsLoadingMore:(BOOL)isLoadingMore
{
    if (loadMoreViewEnable) {
        if (!pullTableIsLoadingMore && isLoadingMore) {
            // If not allready loading more start refreshing
            [loadMoreView startAnimatingWithScrollView:self];
            pullTableIsLoadingMore = YES;
            [pullDelegate pullTableViewDidTriggerLoadMore:self];
        } else if (pullTableIsLoadingMore && !isLoadingMore) {
            [loadMoreView egoRefreshScrollViewDataSourceDidFinishedLoading:self];
            pullTableIsLoadingMore = NO;
        }
    }
}

#pragma mark - Display properties

@synthesize pullArrowImage;
@synthesize pullBackgroundColor;
@synthesize pullTextColor;
@synthesize pullLastRefreshDate;

- (void)configDisplayProperties
{
    [refreshView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
    if (loadMoreViewEnable) {
        [loadMoreView setBackgroundColor:self.pullBackgroundColor textColor:self.pullTextColor arrowImage:self.pullArrowImage];
    }
}

- (void)setPullArrowImage:(UIImage *)aPullArrowImage
{
    if (aPullArrowImage != pullArrowImage) {
        pullArrowImage = aPullArrowImage;
        [self configDisplayProperties];
    }
}

- (void)setPullBackgroundColor:(UIColor *)aColor
{
    if (aColor != pullBackgroundColor) {
        pullBackgroundColor = aColor;
        [self configDisplayProperties];
    } 
}

- (void)setPullTextColor:(UIColor *)aColor
{
    if (aColor != pullTextColor) {
        pullTextColor = aColor;
        [self configDisplayProperties];
    } 
}

- (void)setPullLastRefreshDate:(NSDate *)aDate
{
    if (aDate != pullLastRefreshDate) {
        pullLastRefreshDate = aDate;
        [refreshView refreshLastUpdatedDate];
    }
}

- (void)setInsets:(UIEdgeInsets)insets
{
    _insets = insets;
}

- (void)setRefreshViewOffset:(CGFloat)offset
{
    self.refreshView.y = -self.frame.size.height-offset;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self]) {
        [refreshView egoRefreshScrollViewDidScroll:scrollView];
        if (loadMoreViewEnable) {
            [loadMoreView egoRefreshScrollViewDidScroll:scrollView];
        }
        // Also forward the message to the real delegate
        if ([delegateInterceptor.receiver
             respondsToSelector:@selector(scrollViewDidScroll:)]) {
            [delegateInterceptor.receiver scrollViewDidScroll:scrollView];
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([scrollView isEqual:self]) {
        [refreshView egoRefreshScrollViewDidEndDragging:scrollView];
        
        if (loadMoreViewEnable && !_lastPage) {
            [loadMoreView egoRefreshScrollViewDidEndDragging:scrollView];
        }
        // Also forward the message to the real delegate
        if ([delegateInterceptor.receiver
             respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
            [delegateInterceptor.receiver scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([scrollView isEqual:self]) {
        [refreshView egoRefreshScrollViewWillBeginDragging:scrollView];
        
        if (_lastPage) {
            loadMoreView.footImage = [UIImage imageNamed:@"loading_foot_icon"];
            return;
        } else {
            loadMoreView.footImage = nil;
        }
        // Also forward the message to the real delegate
        if ([delegateInterceptor.receiver
             respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
            [delegateInterceptor.receiver scrollViewWillBeginDragging:scrollView];
        }
    }
}

#pragma mark - EGORefreshTableHeaderDelegate

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    pullTableIsRefreshing = YES;
    [pullDelegate pullTableViewDidTriggerRefresh:self];
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return self.pullLastRefreshDate;
}

#pragma mark - LoadMoreTableViewDelegate

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView *)view
{
    pullTableIsLoadingMore = YES;
    [pullDelegate pullTableViewDidTriggerLoadMore:self];
}


@end
