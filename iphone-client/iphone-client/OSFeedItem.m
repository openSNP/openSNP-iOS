//
//  OSFeedItem.m
//  openSNP
//
//  Created by gdyer on 03/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSFeedItem.h"
#import "OSInfoTableViewCell.h"
#import "OSActionTableViewCell.h"
@interface OSFeedItem()
@property (strong) NSString *imageName;
@end

@implementation OSFeedItem

- (id)initWithBody:(NSString *)b date:(NSDate *)d imageName:(NSString *)i  {
    self = [super init];
    if (self) {
        self.body = b;
        self.imageName = i;
        self.image = [UIImage imageNamed:self.imageName];
        if (!_image) {
            self.image = [UIImage imageNamed:@"questions.png"];
        }
        self.date = d;
        self.dateLabel = [self formatDateLabel];
        self.cellClass = [OSInfoTableViewCell class];
    }
    
    return self;
}

- (id)initWithActionDescription:(NSString *)d andCompletion:(void (^)(void))block {
    self = [super init];
    if (self) {
        self.actionDescription = d;
        self.action = block;
        self.cellClass = [OSActionTableViewCell class];
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