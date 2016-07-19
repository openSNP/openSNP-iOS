//
//  OSHealthPair.h
//  openSNP
//
//  Created by gdyer on 16/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;

// An OSHealthPair very simple struct-like object that's a health identifier with its SI unit
@interface OSHealthPair : NSObject

- (id)initWithQuantityTypeId:(NSString *)qtIdentifier unit:(HKUnit *)unit;

@property (strong) HKQuantityType *type;
@property (strong) HKUnit *unit;


@end
