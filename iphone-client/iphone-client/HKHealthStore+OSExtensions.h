//
//  HKHealthStore+OSExtensions.h
//  openSNP
//
//  Created by gdyer on 16/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <HealthKit/HealthKit.h>

@interface HKHealthStore (OSExtensions)

// fetches the single most recent quantity of the specified type
- (void)os_mostRecentQuantitySampleOfType:(HKQuantityType *)quantityType predicate:(NSPredicate *)predicate completion:(void (^)(HKQuantity *mostRecentQuantity, NSError *error))completion;

@end
