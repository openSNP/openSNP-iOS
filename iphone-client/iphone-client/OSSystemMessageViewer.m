//
//  OSSystemMessageViewer.m
//  openSNP
//
//  Created by gdyer on 09/08/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSSystemMessageViewer.h"

@implementation OSSystemMessageViewer

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:@"sys. message"];
    [self.message setText:_messageText];
    [self.message setFont:[UIFont fontWithName:@"Avenir Book" size:15.0f]];
    
    if (_isError) {
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
    
    composeVC.navigationBar.barTintColor = [UIColor colorWithRed:98. green:152. blue:196. alpha:1.];
    composeVC.mailComposeDelegate = self;
    
    [composeVC setToRecipients:@[@"gdyer@post.cz",
                                 @"info@opensnp.org"]];
    [composeVC setSubject:@"openSNP iOS bug report"];
    [composeVC setMessageBody:_messageText isHTML:FALSE];
    
    [self presentViewController:composeVC animated:YES completion:nil];
}

- (void)reportBug {
    BOOL canSendMail = [MFMailComposeViewController canSendMail];
    NSString *reportMessage = (canSendMail) ? @"Send us a message if you've encountered unexpected behaviour" : @"Send us an SMS if you've encountered unexpected behaviour. Note: your device can't send email, which is the default composition method. International SMS fees may now apply.";
    NSString *composeActionTitle = (canSendMail) ? @"compose report email" : @"compose report SMS";
    
    UIAlertController *reportAlert = [UIAlertController alertControllerWithTitle:@"Report a bug?" message:reportMessage preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:composeActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (canSendMail) {
                [self composeEmail];
            } else {
                // TODO: compose SMS
            }
        });
    }];
    
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"※" style:UIAlertActionStyleCancel handler:nil];
    
    [reportAlert addAction:close];
    [reportAlert addAction:reportAction];
    
    [self presentViewController:reportAlert animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end