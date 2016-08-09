//
//  OSSystemMessageViewer.h
//  openSNP
//
//  Created by gdyer on 09/08/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSystemMessageViewer : UIViewController
@property (weak, nonatomic) IBOutlet UITextView *message;
@property (strong) NSString *messageText;
@end
