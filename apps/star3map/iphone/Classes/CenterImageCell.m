//
//  CenterImageCell.m
//  ProPlayer
//
//  Created by Alex on 21.10.16.
//  Copyright © 2016 Azurcoding. All rights reserved.
//

#import "CenterImageCell.h"

@implementation CenterImageCell

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
    CGFloat aHeight = 70; // Set height according your requirement.
    self.imageView.frame = CGRectMake((self.frame.size.width-70)/2, 15, aHeight, aHeight);
}

@end
