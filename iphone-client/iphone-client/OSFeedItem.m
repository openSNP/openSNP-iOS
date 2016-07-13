//
//  OSFeedItem.m
//  openSNP
//
//  Created by gdyer on 03/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSFeedItem.h"

@implementation OSFeedItem

- (NSString *)formatDateLabel {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    return [dateFormatter stringFromDate:self.date];
}

- (void)setDate:(NSDate *)date {
    self.date = date;
    self.dateLabel = [self formatDateLabel];
}

- (NSDate *)date {
    return self.date;
}

- (void)setImageName:(NSString *)imageName {
    self.imageName = imageName;
    self.image = [UIImage imageNamed:imageName];
    if (!_image) {
        NSLog(@"(!!!) Image \"%@\" not found", imageName);
    }
}

- (NSString *)imageName {
    return self.imageName;
}

@end
