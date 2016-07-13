//
//  OSFeedItem.h
//  openSNP
//
//  Created by gdyer on 03/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface OSFeedItem : NSObject
@property (strong) NSString *body;
@property (strong) NSDate *date;
@property (strong) NSString *imageName;


@property (strong) NSString *dateLabel;
@property (strong) UIImage *image;
@end
