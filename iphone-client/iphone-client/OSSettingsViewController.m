//
//  OSSettingsViewController.m
//  openSNP
//
//  Created by gdyer on 7/20/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSSettingsViewController.h"
#import "OSFeedItem.h"
#import "OSActionTableViewCell.h"
#import "KeychainItemWrapper.h"
#import "OSConstants.h"


@implementation OSSettingsViewController
// TODO: delete data from server

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"settings";
    
    _logoutButton.layer.cornerRadius = 2;
    _logoutButton.layer.borderWidth = 2;
    _logoutButton.layer.borderColor = [UIColor colorWithRed:160. green:0. blue:0. alpha:1.].CGColor;
}


- (IBAction)logout:(id)sender {
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"you're sure?" message:@"※ logging out will stop future uploads but won't delete previous ones stored on openSNP's servers." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"yes, logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
        
        // TODO: this doesn't appear to be working...
        [keychain resetKeychainItem];
    }];
    
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"no, I was joking" style:UIAlertActionStyleCancel handler:nil];
    
    [logoutAlert addAction:close];
    [logoutAlert addAction:confirm];
    
    [self presentViewController:logoutAlert animated:YES completion:^{
        // TODO: update HomeVC's feed
    }];
}

@end