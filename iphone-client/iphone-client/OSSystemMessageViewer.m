//
//  OSSystemMessageViewer.m
//  openSNP
//
//  Created by gdyer on 09/08/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSSystemMessageViewer.h"
#import "KeychainItemWrapper.h"
#import "OSConstants.h"

@interface OSSystemMessageViewer ()
@property (weak, nonatomic) IBOutlet UITextView *message;
@end

@implementation OSSystemMessageViewer

- (KeychainItemWrapper *)getKeychain {
    return [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:(_feedItem.verb) ? _feedItem.verb : @"sys. message"];
    [self.message setText:_feedItem.body];
    [self.message setFont:[UIFont fontWithName:@"Avenir Book" size:15.0f]];
    
    if (_feedItem.isError) {
        [self.message setBackgroundColor:[UIColor redColor]];
        [self.message setFont:[UIFont fontWithName:@"Avenir-Heavy" size:15.0f]];
        
        UIBarButtonItem *bugButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bug.png"]
                                                                      style:UIBarButtonItemStylePlain
                                                                     target:self
                                                                     action:@selector(reportBug)];
        self.navigationItem.rightBarButtonItem = bugButton;
    }
    
    [self.message setTextColor:[UIColor whiteColor]];
}

- (void)composeEmail {
    MFMailComposeViewController *composeVC = [[MFMailComposeViewController alloc] init];
    
    [composeVC setMailComposeDelegate:self];
    [[composeVC navigationBar] setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName]];
    
    [composeVC setToRecipients:@[@"gdyer@post.cz",
                                 @"info@opensnp.org"]];
    [composeVC setSubject:@"openSNP iOS bug report"];
    
    NSString *accountUsername = [[self getKeychain] objectForKey:(__bridge NSString *)kSecAttrAccount];
    [composeVC setMessageBody:[_feedItem.body stringByAppendingString:
                               [NSString stringWithFormat:@" (account: %@)", accountUsername]]
                       isHTML:FALSE];
    
    [self presentViewController:composeVC animated:YES completion:nil];
}

- (void)reportBug {
    BOOL canSendMail = [MFMailComposeViewController canSendMail];
    
    UIAlertController *reportAlert = [UIAlertController alertControllerWithTitle:@"Report a bug?" message:@"Send us an email if you've encounterd a bug." preferredStyle:UIAlertControllerStyleActionSheet];
    
    if (canSendMail) {
    
        UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"compose" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self composeEmail];
            });
        }];
        
        [reportAlert addAction:reportAction];
    }
    
    UIAlertAction *close = [UIAlertAction actionWithTitle:(canSendMail) ? @"※" : @"your device can't send mail" style:UIAlertActionStyleCancel handler:nil];
    
    [reportAlert addAction:close];
    
    [self presentViewController:reportAlert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end