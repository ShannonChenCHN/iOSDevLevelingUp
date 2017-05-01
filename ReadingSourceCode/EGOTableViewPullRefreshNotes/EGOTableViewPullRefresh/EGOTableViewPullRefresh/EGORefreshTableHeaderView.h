//
//  EGORefreshTableHeaderView.h
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

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	EGOOPullPulling = 0,
	EGOOPullNormal,
	EGOOPullLoading,	
} EGOPullState;

#define DEFAULT_ARROW_IMAGE         [UIImage imageNamed:@"blueArrow.png"]
//#define DEFAULT_BACKGROUND_COLOR    [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]
#define DEFAULT_BACKGROUND_COLOR [UIColor clearColor]
#define DEFAULT_TEXT_COLOR          [UIColor colorWithRed:90.0/255.0 green:90.0/255.0 blue:90.0/255.0 alpha:1.0]
#define DEFAULT_ACTIVITY_INDICATOR_STYLE    UIActivityIndicatorViewStyleGray

#define FLIP_ANIMATION_DURATION 0.18f

#define PULL_AREA_HEIGTH 60.0f
#define PULL_TRIGGER_HEIGHT (PULL_AREA_HEIGTH + 5.0f)

@class EGORefreshTableHeaderView;

@protocol EGORefreshTableHeaderDelegate<NSObject>
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view;
@optional
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view;

@end

@interface EGORefreshTableHeaderView : UIView {
	EGOPullState _state;
	
    UIImageView *_animationView;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
    
    // Set this to Yes when egoRefreshTableHeaderDidTriggerRefresh delegate is called and No with egoRefreshScrollViewDataSourceDidFinishedLoading
    BOOL isLoading;
}

@property (nonatomic ,weak) id <EGORefreshTableHeaderDelegate> delegate;
@property (nonatomic ,strong) NSDictionary *statusMessageDic;
@property (nonatomic ,strong) UILabel *_lastUpdatedLabel;
@property (nonatomic ,strong) UILabel *statusLabel;

- (void)refreshLastUpdatedDate;
- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView;
- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *) textColor arrowImage:(UIImage *) arrowImage;
- (void)setState:(EGOPullState)aState;

@end


