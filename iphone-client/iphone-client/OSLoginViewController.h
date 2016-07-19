//
//  OSLoginViewController.h
//  openSNP
//
//  Created by gdyer on 7/19/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSLoginViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>

- (id)initWithURLString:(NSString *)urlString;

@property (strong) NSURL *url;

@property (weak) IBOutlet UIWebView *webView;
- (IBAction)cancel:(id)sender;

@end
