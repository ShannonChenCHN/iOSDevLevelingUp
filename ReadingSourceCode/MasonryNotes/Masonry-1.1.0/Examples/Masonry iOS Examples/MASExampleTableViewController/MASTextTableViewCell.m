//
//  MASTextTableViewCell.m
//  Masonry iOS Examples
//
//  Created by ShannonChen on 2018/1/30.
//  Copyright © 2018年 Jonas Budelmann. All rights reserved.
//

#import "MASTextTableViewCell.h"

@interface MASTextTableViewCell ()

@property (nonatomic, strong) UILabel *exampleLabel;

@end

@implementation MASTextTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _exampleLabel = [UILabel new];
        
        _exampleLabel.textColor = [UIColor grayColor];
        _exampleLabel.font = [UIFont systemFontOfSize:14];
        _exampleLabel.layer.masksToBounds = YES;
        _exampleLabel.layer.borderWidth = 0.5f;
        _exampleLabel.layer.borderColor = [UIColor brownColor].CGColor;
        _exampleLabel.numberOfLines = 0;
        [self.contentView addSubview:_exampleLabel];
        
        [_exampleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@180);
            make.top.equalTo(self.contentView.mas_topMargin);
            make.centerX.equalTo(self.contentView.mas_centerX);
            make.bottom.lessThanOrEqualTo(self.contentView.mas_bottomMargin);
        }];
    }
    return self;
}

- (void)configWithText:(NSString *)cellText {
    
    self.exampleLabel.text = cellText;
}


@end
