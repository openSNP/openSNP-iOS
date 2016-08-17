//
//  OSSettingsViewController.h
//  openSNP
//
//  Created by gdyer on 7/20/16.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OSSettingsViewController : UIViewController
// needed for styling
@property (weak) IBOutlet UIButton *logoutButton;
@property (weak) IBOutlet UILabel *accountNameLabel;

- (IBAction)logout:(id)sender;

@end
