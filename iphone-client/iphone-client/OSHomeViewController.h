//
//  OSHomeViewController.h
//  iphone-client
//
//  Created by gdyer on 13/06/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

@import UIKit;
@import HealthKit;

// the main VC, feed
@interface OSHomeViewController : UITableViewController <NSURLConnectionDelegate>
// init'ed upon launch from app-delegate
@property (nonatomic) HKHealthStore *healthStore;

// the HKQuantityTypeIdentifier's to read
- (NSSet *)dataTypesToRead;
// cleanup and update the feed after logging-in
- (void)updateAfterLogin;

@end

