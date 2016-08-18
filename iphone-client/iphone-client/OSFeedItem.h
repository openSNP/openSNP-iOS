//
//  OSFeedItem.h
//  openSNP
//
//  Created by gdyer on 03/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

// An OSFeedItem is a very simple struct-like object that populates a table view cell subclass
@interface OSFeedItem : NSObject

@property (strong) NSString *body;
@property (strong) NSDate *date;
@property (strong) NSString *verb;

@property (strong) NSString *actionDescription;
@property (nonatomic, copy) void (^action)(void);

// set this to get a red background color in sys. message and bug-reporting abilities
@property (assign) BOOL isError;

// cellClass is set depending on which initilizer is called and must be public
@property (strong) Class cellClass;
@property (strong) NSString *dateLabel;
@property (strong) UIImage *image;


// use this initializer when creating a OSInfoTableViewCell instance
- (id)initWithBody:(NSString *)b date:(NSDate *)d imageName:(NSString *)i;

// use this initializer when creating a OSActionTableViewCell instance
- (id)initWithActionDescription:(NSString *)d completion:(void (^)(void))block;
    
@end
