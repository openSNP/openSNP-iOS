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

@interface OSSettingsViewController()
// outlets are just for styling
@property (nonatomic, strong) IBOutletCollection(UIButton) NSArray *roundedButtons;
@property (weak) IBOutlet UILabel *accountNameLabel;

@end

@implementation OSSettingsViewController
// TODO: delete data from server

- (KeychainItemWrapper *)getKeychain {
    return [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"settings";
    
    for (UIButton *button in _roundedButtons) {
        button.layer.cornerRadius = 3;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [button backgroundColor].CGColor;
    }
    
    _accountNameLabel.text = [[self getKeychain] objectForKey:(__bridge NSString *)kSecAttrAccount];
}

- (IBAction)showInfo:(id)sender {
    UIAlertController *welcomeAlert = [UIAlertController alertControllerWithTitle:@"Welcome to openSNP Health!"
                                                                          message:WELCOME_MESSAGE
                                                                   preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *close = [UIAlertAction actionWithTitle:@"※" style:UIAlertActionStyleCancel handler:nil];
    [welcomeAlert addAction:close];
    [self presentViewController:welcomeAlert animated:YES completion:nil];
}


- (IBAction)logout:(id)sender {
    UIAlertController *logoutAlert = [UIAlertController alertControllerWithTitle:@"You're sure?"
                                                                         message:@"Logging out will stop future uploads but won't delete previous ones."
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