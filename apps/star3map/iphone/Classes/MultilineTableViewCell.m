//
//  MultilineTableViewCell.m
//
//  Created by Gareth Bestor on 14/04/16.
//  Copyright © 2016 xiphware. All rights reserved.
//

#import "MultilineTableViewCell.h"

@implementation MultilineTableViewCell

- (CGSize)systemLayoutSizeFittingSize:(CGSize)targetSize
        withHorizontalFittingPriority:(UILayoutPriority)horizontalFittingPriority
              verticalFittingPriority:(UILayoutPriority)verticalFittingPriority
{
    CGSize size = [super systemLayoutSizeFittingSize:targetSize
                       withHorizontalFittingPriority:horizontalFittingPriority
                             verticalFittingPriority:verticalFittingPriority];
    CGFloat detailHeight = CGRectGetHeight(self.detailTextLabel.frame);
    if (detailHeight) { // if no detailTextLabel (or UITableViewCellStyleDefault) then no adjustment necessary
        // Determine UITableViewCellStyle by looking at textLabel vs detailTextLabel layout
        if (CGRectGetMinX(self.detailTextLabel.frame) > CGRectGetMinX(self.textLabel.frame)) {
            // detailTextLabel right of textLabel means UITableViewCellStyleValue1 or UITableViewCellStyleValue2
            if (CGRectGetHeight(self.detailTextLabel.frame) > CGRectGetHeight(self.textLabel.frame)) {
                // If detailTextLabel is taller than textLabel then add difference to cell height
                size.height += CGRectGetHeight(self.detailTextLabel.frame) - CGRectGetHeight(self.textLabel.frame);
            }
        } else {
            // Otherwise UITableViewCellStyleSubtitle, in which case add detailTextLabel height to cell height
            size.height += CGRectGetHeight(self.detailTextLabel.frame);
        }
    }
    return size;
}

@end
