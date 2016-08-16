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
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"You're sure?"
                                                                         message:@"Logging out will stop future uploads but won't delete previous ones stored on openSNP's servers."
                                                                  preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"logout" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
        [keychain resetKeychainItem];
        
        // from Daij-Djan: https://stackoverflow.com/questions/14086085/how-to-delete-all-keychain-items-accessible-to-an-app
        // thanks!
        NSArray *secItemClasses = @[(__bridge id)kSecClassGenericPassword,
                                    (__bridge id)kSecClassInternetPassword,
                                    (__bridge id)kSecClassCertificate,
                                    (__bridge id)kSecClassKey,
                                    (__bridge id)kSecClassIdentity];
        for (id secItemClass in secItemClasses) {
            NSDictionary *spec = @{(__bridge id)kSecClass: secItemClass};
            SecItemDelete((__bridge CFDictionaryRef)spec);
        }
        
        [self.navigationController popViewControllerAnimated:true];
    }];
    
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"※" style:UIAlertActionStyleCancel handler:nil];
    
    [logoutAlert addAction:close];
    [logoutAlert addAction:confirm];
    
    [self presentViewController:logoutAlert animated:YES completion:nil];
}

@end