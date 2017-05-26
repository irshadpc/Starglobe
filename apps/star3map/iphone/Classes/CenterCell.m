//
//  CenterCell.m
//  ProPlayer
//
//  Created by Alex on 11.10.16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import "CenterCell.h"

@implementation CenterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews {
    [super layoutSubviews];
    CGFloat aHeight = 80.0f; // Set height according your requirement.
    self.textLabel.frame = CGRectMake(10, 10, self.frame.size.width-20, aHeight);
}

@end
