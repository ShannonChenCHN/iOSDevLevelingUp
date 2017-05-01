//
//  EGORefreshTableHeaderView.m
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
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

#import "LoadMoreTableFooterView.h"
#import "PullTableView.h"
#import "UIView+Layout.h"

@interface LoadMoreTableFooterView (Private)

- (void)setState:(EGOPullState)aState;
- (CGFloat)scrollViewOffsetFromBottom:(UIScrollView *) scrollView;
- (CGFloat)visibleTableHeightDiffWithBoundsHeight:(UIScrollView *) scrollView;

@end

@implementation LoadMoreTableFooterView
@synthesize statusMessageDic;

@synthesize delegate=_delegate;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        isLoading = NO;
        
        CGFloat midY = PULL_AREA_HEIGTH/2;
        
        /* Config Status Updated Label */
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY - 10, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        label.font = [UIFont boldSystemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		
        /* Config Arrow Image */
		CALayer *layer = [[CALayer alloc] init];
		layer.frame = CGRectMake(25.0f,midY - 20, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
        /* Config activity indicator */
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:DEFAULT_ACTIVITY_INDICATOR_STYLE];
		view.frame = CGRectMake(25.0f,midY - 8, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;		
		
		[self setState:EGOOPullNormal]; // Also transform the image
        
        /* Configure the default colors and arrow image */
        [self setBackgroundColor:nil textColor:nil arrowImage:nil];
        
        lastPageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), PULL_AREA_HEIGTH)];
        lastPageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        lastPageLabel.font = [UIFont boldSystemFontOfSize:13.f];
        lastPageLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
        lastPageLabel.backgroundColor = [UIColor clearColor];
        lastPageLabel.textAlignment = NSTextAlignmentCenter;
        lastPageLabel.hidden = YES;
        [self addSubview:lastPageLabel];
        
        _footImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), PULL_AREA_HEIGTH)];
        _footImgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _footImgView.contentMode = UIViewContentModeScaleAspectFit;
        _footImgView.hidden = YES;
        [self addSubview:_footImgView];
    }
	
    return self;
}

- (void)setLastPageMessage:(NSString *)lastPageMessage
{
    if (![lastPageMessage isEqualToString:@""]) {
        _statusLabel.hidden = YES;
        lastPageLabel.text = lastPageMessage;
        lastPageLabel.hidden = NO;
    } else {
        _statusLabel.hidden = NO;
        lastPageLabel.text = @"";
        lastPageLabel.hidden = YES;
    }
}

- (void)setFootImage:(UIImage *)footImage
{
    _footImage = footImage;
    
    if (_footImage) {
        _footImgView.hidden = NO;
        _statusLabel.hidden = YES;
        _footImgView.image = _footImage;
        _footImgView.frame = CGRectMake(self.width/2.f-_footImage.size.width/2.f, PULL_AREA_HEIGTH/2.f-_footImage.size.height/2.f, _footImage.size.width, _footImage.size.height);
    } else {
        _footImgView.hidden = YES;
        _statusLabel.hidden = NO;
        _footImgView.image = nil;
    }
}

#pragma mark - Util

- (CGFloat)scrollViewOffsetFromBottom:(UIScrollView *) scrollView
{
    CGFloat scrollAreaContenHeight = scrollView.contentSize.height;
    CGFloat visibleTableHeight = MIN(scrollView.bounds.size.height, scrollAreaContenHeight);
    CGFloat scrolledDistance = scrollView.contentOffset.y + visibleTableHeight; // If scrolled all the way down this should add upp to the content heigh.
    CGFloat normalizedOffset = scrollAreaContenHeight-scrolledDistance;
    
    return normalizedOffset;
}

- (CGFloat)visibleTableHeightDiffWithBoundsHeight:(UIScrollView *) scrollView
{
    PullTableView *tableView = (PullTableView *)scrollView;
    CGFloat bottom = tableView.insets.bottom;
    return (scrollView.bounds.size.height - MIN(scrollView.bounds.size.height, scrollView.contentSize.height))+bottom;
}

#pragma mark - Setters

- (void)setState:(EGOPullState)aState
{
	switch (aState) {
		case EGOOPullPulling:
			if (statusMessageDic) {
                _statusLabel.text = NSLocalizedStringFromTable(statusMessageDic[@"pullDownStatus"],@"PullTableViewLan", @"Release to refresh status");
            } else {
                _statusLabel.text = NSLocalizedStringFromTable(@"松开立即加载更多",@"PullTableViewLan", @"Release to load more status");
            }
            [self updateContent:NO];
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			break;
		case EGOOPullNormal:
			if (_state == EGOOPullPulling) {
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
				[CATransaction commit];
			}
            if (statusMessageDic) {
                _statusLabel.text = NSLocalizedStringFromTable(statusMessageDic[@"pullStatus"],@"PullTableViewLan", @"Release to refresh status");
            } else {
                _statusLabel.text = NSLocalizedStringFromTable(@"上拉可以加载更多", @"PullTableViewLan",@"Pull down to load more status");
            }
            
			[_activityView stopAnimating];
            [self updateContent:NO];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			break;
		case EGOOPullLoading:
			_statusLabel.text = NSLocalizedStringFromTable(@"正在加载更多的数据...", @"PullTableViewLan",@"Loading Status");
			[_activityView startAnimating];
            [self updateContent:YES];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = YES;
			[CATransaction commit];
			break;
		default:
			break;
	}
	
	_state = aState;
}

- (void)updateContent:(BOOL)isAnimating
{
    CGFloat width = [_statusLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, _statusLabel.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_statusLabel.font} context:nil].size.width;
    _statusLabel.width = width;
    if (isAnimating) {
        CGFloat left = self.width*0.5-(width+12+_activityView.width)*0.5;
        _activityView.x = left;
        _statusLabel.x = _activityView.right+12;
    } else {
        _statusLabel.x = self.width*0.5-width*0.5;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *) textColor arrowImage:(UIImage *) arrowImage
{
    self.backgroundColor = backgroundColor? backgroundColor : DEFAULT_BACKGROUND_COLOR;
    _statusLabel.textColor = textColor? textColor: DEFAULT_TEXT_COLOR;
    _statusLabel.shadowColor = [_statusLabel.textColor colorWithAlphaComponent:0.1f];
    lastPageLabel.textColor = _statusLabel.textColor;
    lastPageLabel.shadowColor = _statusLabel.shadowColor;
}

#pragma mark - ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat bottomOffset = [self scrollViewOffsetFromBottom:scrollView];
	if (_state == EGOOPullLoading) {
        CGFloat offset = MAX(bottomOffset * -1, 0);
		offset = MIN(ceilf(offset), PULL_AREA_HEIGTH);
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.bottom = offset? offset + [self visibleTableHeightDiffWithBoundsHeight:scrollView]: 0;
        scrollView.contentInset = currentInsets;
	} else if (scrollView.isDragging) {
		if (_state == EGOOPullPulling && bottomOffset > -PULL_TRIGGER_HEIGHT && bottomOffset < 0.0f && !isLoading) {
			[self setState:EGOOPullNormal];
		} else if (_state == EGOOPullNormal && bottomOffset < -PULL_TRIGGER_HEIGHT && !isLoading) {
			[self setState:EGOOPullPulling];
		}
        PullTableView *tableView = (PullTableView *)scrollView;
        CGFloat bottom = tableView.insets.bottom;
        if (bottom > 0.f) {
            UIEdgeInsets currentInsets = scrollView.contentInset;
            currentInsets.bottom = bottom;
            scrollView.contentInset = currentInsets;
        } else {
            if (scrollView.contentInset.bottom != 0) {
                UIEdgeInsets currentInsets = scrollView.contentInset;
                currentInsets.bottom = 0;
                scrollView.contentInset = currentInsets;
            }
        }
	}
}

- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView
{
    isLoading = YES;
    [self setState:EGOOPullLoading];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.2];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = PULL_AREA_HEIGTH + [self visibleTableHeightDiffWithBoundsHeight:scrollView];
    scrollView.contentInset = currentInsets;
    [UIView commitAnimations];
    
    if ([self scrollViewOffsetFromBottom:scrollView] == 0) {
        [scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y + PULL_TRIGGER_HEIGHT) animated:YES];
    }
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
	if ([self scrollViewOffsetFromBottom:scrollView] <= - PULL_TRIGGER_HEIGHT && !isLoading) {
        [self startAnimatingWithScrollView:scrollView];
        
        if ([_delegate respondsToSelector:@selector(loadMoreTableFooterDidTriggerLoadMore:)]) {
            [_delegate loadMoreTableFooterDidTriggerLoadMore:self];
        }
	}
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
    isLoading = NO;
    
    PullTableView *tableView = (PullTableView *)scrollView;
    CGFloat bottom = tableView.insets.bottom;
    
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:.3];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.bottom = bottom;
    scrollView.contentInset = currentInsets;
	[UIView commitAnimations];
	
	[self setState:EGOOPullNormal];
}

#pragma mark - Dealloc

- (void)dealloc
{
	
}

@end
