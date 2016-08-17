//
//  OSHomeViewController.h
//  iphone-client
//
//  Created by gdyer on 13/06/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

@import UIKit;
@import HealthKit;

@interface OSHomeViewController : UITableViewController <NSURLConnectionDelegate>
@property (nonatomic) HKHealthStore *healthStore;

// the HKQuantityTypeIdentifier's to read
- (NSSet *)dataTypesToRead;
// cleanup and update the feed after logging-in
- (void)updateAfterLogin;

@end

