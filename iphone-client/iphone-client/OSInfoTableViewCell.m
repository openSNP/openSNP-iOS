//
//  OSTableViewCell.m
//  openSNP
//
//  Created by gdyer on 03/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSInfoTableViewCell.h"

@implementation OSInfoTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    if (highlighted) {
        [self setBackgroundColor:[UIColor colorWithRed:193. green:220. blue:242. alpha:1.]];
    }
}

@end