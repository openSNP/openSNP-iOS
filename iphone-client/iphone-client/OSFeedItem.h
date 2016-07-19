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
@property (strong) NSString *imageName;

@property (strong) NSString *actionDescription;
@property (assign) NSInteger actionId;

// dateLabel and image are set by this class
@property (strong) NSString *dateLabel;
@property (strong) UIImage *image;
// cellClass is set depending on which initilizer is called
@property (strong) Class cellClass;


// use this initializer when creating a OSInfoTableViewCell instance
- (id)initWithBody:(NSString *)b date:(NSDate *)d imageName:(NSString *)i;

// use this initializer when creating a OSActionTableViewCell instance
- (id)initWithActionDescription:(NSString *)d actionId:(NSInteger)aid;
    
@end
