//
//  MASExampleUpdateView.m
//  Masonry iOS Examples
//
//  Created by Jonas Budelmann on 3/11/13.
//  Copyright (c) 2013 Jonas Budelmann. All rights reserved.
//

#import "MASExampleUpdateView.h"

//#define USE_ORIGINAL_APPROACH     1

@interface MASExampleUpdateView ()

@property (nonatomic, strong) UIButton *growingButton;
@property (nonatomic, assign) CGSize buttonSize;

@end

@implementation MASExampleUpdateView

- (id)init {
    self = [super init];
    if (!self) return nil;

    self.growingButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.growingButton setTitle:@"Grow Me!" forState:UIControlStateNormal];
    self.growingButton.layer.borderColor = UIColor.greenColor.CGColor;
    self.growingButton.layer.borderWidth = 3;

    [self.growingButton addTarget:self action:@selector(didTapGrowButton:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.growingButton];

    self.buttonSize = CGSizeMake(100, 100);
    
#ifndef USE_ORIGINAL_APPROACH
    
    [self.growingButton makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(self.buttonSize.width)).priorityMedium();
        make.height.equalTo(@(self.buttonSize.height)).priorityMedium();
        make.width.lessThanOrEqualTo(self);
        
        make.top.greaterThanOrEqualTo(self);
        if (@available(iOS 11.0, *)) {
            make.bottom.lessThanOrEqualTo(self.mas_safeAreaLayoutGuideBottom);
        } else {
            make.bottom.lessThanOrEqualTo(self.mas_bottom);
        }
    }];
    
#endif

    return self;
}

#ifdef USE_ORIGINAL_APPROACH

+ (BOOL)requiresConstraintBasedLayout
{
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {

    [self.growingButton updateConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@(self.buttonSize.width)).priorityMedium();
        make.height.equalTo(@(self.buttonSize.height)).priorityMedium();
        make.width.lessThanOrEqualTo(self);
        make.height.lessThanOrEqualTo(self);
    }];


    //according to apple super should be called at end of method
    [super updateConstraints];
}

#endif

- (void)didTapGrowButton:(UIButton *)button {
    self.buttonSize = CGSizeMake(self.buttonSize.width * 1.3, self.buttonSize.height * 1.3);

#ifdef USE_ORIGINAL_APPROACH
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

#else
    
    [self.growingButton updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(self.buttonSize.width)).priorityMedium();
        make.height.equalTo(@(self.buttonSize.height)).priorityMedium();
    }];
    
#endif

    [UIView animateWithDuration:0.4 animations:^{
        [self layoutIfNeeded];
        
    }];
}

@end
