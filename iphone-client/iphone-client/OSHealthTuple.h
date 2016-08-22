//
//  OSHealthTuple.h
//  openSNP
//
//  Created by gdyer on 16/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;

// An OSHealthPair very simple struct-like object that's a health identifier with its SI unit
@interface OSHealthTuple : NSObject
NS_ASSUME_NONNULL_BEGIN

- (id)initWithQuantityTypeId:(nonnull NSString *)qtIdentifier unit:(HKUnit *)unit name:(NSString *)name;

@property (strong) HKQuantityType *type;
@property (strong) HKUnit *unit;
@property (strong) NSString *name;

NS_ASSUME_NONNULL_END

@end
