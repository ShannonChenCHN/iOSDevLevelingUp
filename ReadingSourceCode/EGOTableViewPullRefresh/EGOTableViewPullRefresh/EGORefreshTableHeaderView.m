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

#import "EGORefreshTableHeaderView.h"
#import "PullTableView.h"
#import "UIView+Layout.h"

@interface EGORefreshTableHeaderView (Private)

- (void)setState:(EGOPullState)aState;

@end

@implementation EGORefreshTableHeaderView
@synthesize statusMessageDic;

@synthesize delegate = _delegate;
@synthesize _lastUpdatedLabel;
@synthesize statusLabel = _statusLabel;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
		
        isLoading = NO;
        
        CGFloat midY = frame.size.height - PULL_AREA_HEIGTH/2;
        
        
        /* Config Last Updated Label */
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont systemFontOfSize:12.f];
		label.shadowOffset = CGSizeMake(0.0f, 1.0f);
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_lastUpdatedLabel=label;
		
        /* Config Status Updated Label */
		label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, midY - 18, self.frame.size.width, 20.0f)];
		label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		label.font = [UIFont boldSystemFontOfSize:14];
		label.backgroundColor = [UIColor clearColor];
		label.textAlignment = NSTextAlignmentCenter;
		[self addSubview:label];
		_statusLabel=label;
		
        /* Config Arrow Image */
		CALayer *layer = [[CALayer alloc] init];
		layer.frame = CGRectMake(25.0f,midY - 35, 30.0f, 55.0f);
		layer.contentsGravity = kCAGravityResizeAspect;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
		if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
			layer.contentsScale = [[UIScreen mainScreen] scale];
		}
#endif
		[[self layer] addSublayer:layer];
		_arrowImage=layer;
		
        /* Config activity indicator */
        UIActivityIndicatorViewStyle style = DEFAULT_ACTIVITY_INDICATOR_STYLE;
		UIActivityIndicatorView *view = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
		view.frame = CGRectMake(25.0f,midY - 8, 20.0f, 20.0f);
		[self addSubview:view];
		_activityView = view;		
		
		[self setState:EGOOPullNormal];
        
        /* Configure the default colors and arrow image */
        [self setBackgroundColor:nil textColor:nil arrowImage:nil];
    }
	
    return self;
}

#pragma mark - Setters

#define aMinute 60
#define anHour 3600
#define aDay 86400

- (void)refreshLastUpdatedDate
{
    NSDate * date = nil;
	if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDataSourceLastUpdated:)]) {
		date = [_delegate egoRefreshTableHeaderDataSourceLastUpdated:self];
	}
    if (date) {
        NSTimeInterval timeSinceLastUpdate = [date timeIntervalSinceNow];
        NSInteger timeToDisplay = 0;
        timeSinceLastUpdate *= -1;
        
        if(timeSinceLastUpdate < anHour) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aMinute);
            
            if(timeToDisplay == /* Singular*/ 1) {
            _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 分钟前更新",@"PullTableViewLan",@"Last uppdate in minutes singular"),(long)timeToDisplay];
                
            } else if(timeToDisplay == /* Singular*/ 0) {
                /* Plural */
                _lastUpdatedLabel.text = @"刚刚更新";
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 分钟前更新",@"PullTableViewLan",@"Last uppdate in minutes plural"), (long)timeToDisplay];
            }
            
        } else if (timeSinceLastUpdate < aDay) {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / anHour);
            if(timeToDisplay == /* Singular*/ 1) {
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 小时前更新",@"PullTableViewLan",@"Last uppdate in hours singular"), (long)timeToDisplay];
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 小时前更新",@"PullTableViewLan",@"Last uppdate in hours plural"), (long)timeToDisplay];
                
            }
            
        } else {
            timeToDisplay = (NSInteger) (timeSinceLastUpdate / aDay);
            if(timeToDisplay == /* Singular*/ 1) {
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 天前更新",@"PullTableViewLan",@"Last uppdate in days singular"), (long)timeToDisplay];
            } else {
                /* Plural */
                _lastUpdatedLabel.text = [NSString stringWithFormat:NSLocalizedStringFromTable(@"%ld 天前更新",@"PullTableViewLan",@"Last uppdate in days plural"), (long)timeToDisplay];
            }
        }
    } else {
        _lastUpdatedLabel.text = nil;
    }
    
    // Center the status label if the lastupdate is not available
    CGFloat midY = self.frame.size.height - PULL_AREA_HEIGTH/2;
    if(!_lastUpdatedLabel.text) {
        _statusLabel.frame = CGRectMake(0.0f, midY - 8, self.frame.size.width, 20.0f);
    } else {
        _statusLabel.frame = CGRectMake(0.0f, midY - 18, self.frame.size.width, 20.0f);
    }
}

- (void)setState:(EGOPullState)aState
{
	if (statusMessageDic) {
        _lastUpdatedLabel.hidden = YES;
    }
	switch (aState) {
		case EGOOPullPulling:   // normal -> pulling
			if (statusMessageDic) {
                _statusLabel.text = NSLocalizedStringFromTable(statusMessageDic[@"pullDownStatus"],@"PullTableViewLan", @"Release to refresh status");
            } else {
                _statusLabel.text = NSLocalizedStringFromTable(@"松开立即刷新",@"PullTableViewLan", @"Release to refresh status");
            }
            [self updateContent:NO];
			[CATransaction begin];
			[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
			_arrowImage.transform = CATransform3DMakeRotation((M_PI / 180.0) * 180.0f, 0.0f, 0.0f, 1.0f);
			[CATransaction commit];
			break;
		case EGOOPullNormal:
			if (_state == EGOOPullPulling) { // pulling -> normal
				[CATransaction begin];
				[CATransaction setAnimationDuration:FLIP_ANIMATION_DURATION];
				_arrowImage.transform = CATransform3DIdentity;
				[CATransaction commit];
			}
            
            if (statusMessageDic) {
                _statusLabel.text = NSLocalizedStringFromTable(statusMessageDic[@"pullStatus"],@"PullTableViewLan", @"Release to refresh status");
            } else {
                _statusLabel.text = NSLocalizedStringFromTable(@"下拉可以刷新", @"PullTableViewLan", @"Pull down to refresh status");
            }
			
			[_activityView stopAnimating];
            [self updateContent:NO];
			[CATransaction begin];
			[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions]; 
			_arrowImage.hidden = NO;
			_arrowImage.transform = CATransform3DIdentity;
			[CATransaction commit];
			[self refreshLastUpdatedDate];
			break;
		case EGOOPullLoading:  // normal -> loading
			_statusLabel.text = NSLocalizedStringFromTable(@"正在刷新数据中...",@"PullTableViewLan", @"Loading Status");
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

- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor arrowImage:(UIImage *)arrowImage
{
    self.backgroundColor = backgroundColor? backgroundColor : DEFAULT_BACKGROUND_COLOR;
    
    if(textColor) {
        _lastUpdatedLabel.textColor = textColor;
        _statusLabel.textColor = textColor;
    } else {
        _lastUpdatedLabel.textColor = DEFAULT_TEXT_COLOR;
        _statusLabel.textColor = DEFAULT_TEXT_COLOR;
    }
}

#pragma mark - ScrollView Methods

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView
{

    PullTableView * tableView = (PullTableView *)scrollView;
    CGFloat top = tableView.insets.top;
    
	if (_state == EGOOPullLoading) { // 刷新状态时 scrollView 上边留白停滞一点时间
		CGFloat offset = MAX(scrollView.contentOffset.y * -1, top);
        offset = MIN(offset, PULL_AREA_HEIGTH+top);
        UIEdgeInsets currentInsets = scrollView.contentInset;
        currentInsets.top = offset;
        scrollView.contentInset = currentInsets;
	} else {
		if (_state == EGOOPullPulling && scrollView.contentOffset.y > -PULL_TRIGGER_HEIGHT-top && scrollView.contentOffset.y < 0.0f && !isLoading) { // pulling -> normal
			[self setState:EGOOPullNormal];
		} else if (_state == EGOOPullNormal && scrollView.contentOffset.y < -PULL_TRIGGER_HEIGHT-top && !isLoading) {  // normal -> pulling
			[self setState:EGOOPullPulling];
		}
		
        if (top > 0) {
            UIEdgeInsets currentInsets = scrollView.contentInset;
            currentInsets.top = top;
            scrollView.contentInset = currentInsets;
        } else {
            if (scrollView.contentInset.top != 0) {
                UIEdgeInsets currentInsets = scrollView.contentInset;
                currentInsets.top = 0;
                scrollView.contentInset = currentInsets;
            }
        }
	}
}

- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView
{
    isLoading = YES;
    [self setState:EGOOPullLoading];
}

- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView
{
    PullTableView * tableView = (PullTableView *)scrollView;
    CGFloat top = tableView.insets.top;
    
	if (scrollView.contentOffset.y <= -PULL_TRIGGER_HEIGHT-top && !isLoading) {  // 用户下拉松手后，而且不是正在刷新中时，触发下拉刷新事件
        if ([_delegate respondsToSelector:@selector(egoRefreshTableHeaderDidTriggerRefresh:)]) {
            [_delegate egoRefreshTableHeaderDidTriggerRefresh:self];
        }
        [self startAnimatingWithScrollView:scrollView];
	}
}

- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView
{
    // isLoading 改为 NO
    isLoading = NO;
    
    // 还原 insets
    PullTableView * tableView = (PullTableView *)scrollView;
    CGFloat top = tableView.insets.top;
    
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.3];
    UIEdgeInsets currentInsets = scrollView.contentInset;
    currentInsets.top = top;
    scrollView.contentInset = currentInsets;
	[UIView commitAnimations];
    
    // 更新状态
	[self setState:EGOOPullNormal];
}

- (void)egoRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self refreshLastUpdatedDate]; // 刷新更新时间的显示
}

#pragma mark - Dealloc

- (void)dealloc
{
	_delegate = nil;
}

@end
