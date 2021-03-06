//
//  OSLoginViewController.m
//  openSNP
//
//  Created by gdyer on 7/19/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSLoginViewController.h"
#import "OSConstants.h"
#import "KeychainItemWrapper.h"
#import "OSHomeViewController.h"

@interface OSLoginViewController ()
@property (strong) NSURL *url;
@property (weak) IBOutlet UIWebView *webView;
@end

@implementation OSLoginViewController

- (id)init {
    self = [super initWithNibName:@"LoginView" bundle:nil];
    if (self) {
        NSString *deviceName = [[[UIDevice currentDevice] name]
                                stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
        NSString *urlString = [NSString stringWithFormat:@"%@?device=%@", LOGIN_URL, deviceName];
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
    
    NSCachedURLResponse *resp = [[NSURLCache sharedURLCache] cachedResponseForRequest:webView.request];
    NSDictionary *headers = [(NSHTTPURLResponse*)resp.response allHeaderFields];
    NSString *key, *email;
    NSString *urlString = [[webView request].URL.absoluteString substringToIndex:[LOGIN_URL length]];
    
    if ([urlString isEqualToString:LOGIN_URL] && ((key = headers[KEY_HTTP_HEADER_KEY]) != NULL) && (email = headers[EMAIL_HTTP_HEADER_KEY])) {
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
        [keychain setObject:(__bridge NSString *)kSecAttrAccessibleWhenUnlocked forKey:(__bridge NSString *)kSecAttrAccessible];
        
        // store the user's uuid in their keychain
        [keychain setObject:key forKey:(__bridge NSString *)kSecValueData];
        // store the user's email in their keychain
        [keychain setObject:email forKey:(__bridge NSString *)kSecAttrAccount];
        
        
        // need local pointers since ``self.presentingViewController`` will be cleared before completion is run
        UINavigationController *presentingVC = (UINavigationController *)self.presentingViewController;
        OSHomeViewController *homeVC = (OSHomeViewController *)presentingVC.topViewController;
        [self dismissViewControllerAnimated:TRUE completion:^{
            [homeVC performSelector:@selector(updateAfterLogin)];
         }];
    }
    
}


@end