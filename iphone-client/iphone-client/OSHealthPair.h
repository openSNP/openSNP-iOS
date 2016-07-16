//
//  OSHealthPair.h
//  openSNP
//
//  Created by gdyer on 16/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <Foundation/Foundation.h>
@import HealthKit;

@interface OSHealthPair : NSObject

- (id)initWithQuantityType:(HKQuantityType *)quantityType unit:(HKUnit *)unit;

@property (strong) HKQuantityType *type;
@property (strong) HKUnit *unit;


@end
