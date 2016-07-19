//
//  OSLoginViewController.m
//  openSNP
//
//  Created by gdyer on 7/19/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSLoginViewController.h"

@implementation OSLoginViewController

- (id)initWithURLString:(NSString *)urlString {
    self = [super initWithNibName:@"LoginView" bundle:nil];
    if (self) {
        self.url = [NSURL URLWithString:urlString];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView setDelegate:self];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
    self.webView.multipleTouchEnabled = TRUE;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (IBAction)cancel:(id)sender {
    [self.webView stopLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
}




@end
