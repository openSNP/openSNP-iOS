//
//  OSLoginViewController.h
//  openSNP
//
//  Created by gdyer on 7/19/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSLoginViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>

- (IBAction)cancel:(id)sender;
// create an instance with urlString as the starting URL
- (id)initWithURLString:(NSString *)urlString;

@end
