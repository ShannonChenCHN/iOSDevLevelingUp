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

// This class has derived from the EGORefreshTableHeaderView

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "EGORefreshTableHeaderView.h"

@class LoadMoreTableFooterView;
@protocol LoadMoreTableFooterDelegate<NSObject>

- (void)loadMoreTableFooterDidTriggerLoadMore:(LoadMoreTableFooterView*)view;

@end

@interface LoadMoreTableFooterView : UIView {
	EGOPullState _state;
    
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
    
    // Set this to Yes when egoRefreshTableHeaderDidTriggerRefresh delegate is called and No with egoRefreshScrollViewDataSourceDidFinishedLoading
    BOOL isLoading;
	
    UILabel *lastPageLabel;
    UIImageView *_footImgView;
}

@property (nonatomic,weak) id <LoadMoreTableFooterDelegate> delegate;
@property (nonatomic ,strong) NSDictionary *statusMessageDic;
@property (nonatomic ,strong) NSString *lastPageMessage;
@property (nonatomic, strong) UIImage *footImage;

- (void)egoRefreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)egoRefreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)startAnimatingWithScrollView:(UIScrollView *) scrollView;
- (void)setBackgroundColor:(UIColor *)backgroundColor textColor:(UIColor *) textColor arrowImage:(UIImage *) arrowImage;


@end


