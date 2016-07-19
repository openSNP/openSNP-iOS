//
//  OSFeedItem.m
//  openSNP
//
//  Created by gdyer on 03/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSFeedItem.h"

@implementation OSFeedItem

- (id)initWithBody:(NSString *)b date:(NSDate *)d imageName:(NSString *)i {
    self = [super init];
    if (self) {
        self.body = b;
        self.imageName = i;
        self.image = [UIImage imageNamed:self.imageName];
        self.date = d;
        self.dateLabel = [self formatDateLabel];
    }
    
    return self;
}

- (NSString *)formatDateLabel {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    return [dateFormatter stringFromDate:self.date];
}

@end