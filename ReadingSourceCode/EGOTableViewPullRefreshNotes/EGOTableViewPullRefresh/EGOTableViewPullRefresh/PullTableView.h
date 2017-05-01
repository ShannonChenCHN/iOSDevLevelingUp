//
//  PullTableView.h
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


#import <UIKit/UIKit.h>
#import "MessageInterceptor.h"
#import "EGORefreshTableHeaderView.h"
#import "LoadMoreTableFooterView.h"

@class PullTableView;
@protocol PullTableViewDelegate <NSObject>

/* After one of the delegate methods is invoked a loading animation is started, to end it use the respective status update property */
@optional

- (void)pullTableViewDidTriggerRefresh:(PullTableView*)pullTableView;
- (void)pullTableViewDidTriggerLoadMore:(PullTableView*)pullTableView;

- (void)tableView:(UITableView *)tableView touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView touchesEnded:(NSSet *)touches  withEvent:(UIEvent *)event;
- (void)tableView:(UITableView *)tableView touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end

@interface PullTableView : UITableView <EGORefreshTableHeaderDelegate, LoadMoreTableFooterDelegate>{

    // Since we use the contentInsets to manipulate the view we need to store the the content insets originally specified.
    UIEdgeInsets realContentInsets;
    
    // For intercepting the scrollView delegate messages.
    MessageInterceptor * delegateInterceptor;
    
    // Config
    UIImage *pullArrowImage;
    UIColor *pullBackgroundColor;
    UIColor *pullTextColor;
    NSDate *pullLastRefreshDate;
    
    // Status
    BOOL pullTableIsRefreshing;
    BOOL pullTableIsLoadingMore;

}

/* The configurable display properties of PullTableView. Set to nil for default values */
@property (nonatomic, retain) UIImage *pullArrowImage;
@property (nonatomic, retain) UIColor *pullBackgroundColor;
@property (nonatomic, retain) UIColor *pullTextColor;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshView;
@property (nonatomic, retain) LoadMoreTableFooterView *loadMoreView;

/* Set to nil to hide last modified text */
@property (nonatomic, retain) NSDate *pullLastRefreshDate;

/* Properties to set the status of the refresh/loadMore operations. */
/* After the delegate methods are triggered the respective properties are automatically set to YES. After a refresh/reload is done it is necessary to set the respective property to NO, otherwise the animation won't disappear. You can also set the properties manually to YES to show the animations. */
@property (nonatomic, assign) BOOL pullTableIsRefreshing;
@property (nonatomic, assign) BOOL pullTableIsLoadingMore;

@property (nonatomic, assign) BOOL loadMoreViewEnable;
@property (nonatomic, assign) BOOL refreshingViewEnable;

@property (nonatomic, assign) BOOL lastPage;

@property (nonatomic, assign) UIEdgeInsets insets;

- (void)setRefreshViewOffset:(CGFloat)offset;
/* Delegate */
@property (nonatomic, weak) IBOutlet id<PullTableViewDelegate> pullDelegate;

@end
