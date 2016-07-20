//
//  OSHomeViewController.h
//  iphone-client
//
//  Created by gdyer on 13/06/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

@import UIKit;
@import HealthKit;

@interface OSHomeViewController : UITableViewController
@property (nonatomic) HKHealthStore *healthStore;

- (NSSet *)dataTypesToRead;
- (void)updateAfterLogin;

@end

