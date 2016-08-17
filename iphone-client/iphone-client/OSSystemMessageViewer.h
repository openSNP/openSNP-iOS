//
//  OSSystemMessageViewer.h
//  openSNP
//
//  Created by gdyer on 09/08/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "OSFeedItem.h"

@interface OSSystemMessageViewer : UIViewController <MFMailComposeViewControllerDelegate>
@property (strong) OSFeedItem *feedItem;
@end