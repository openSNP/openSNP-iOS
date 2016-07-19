//
//  OSHealthPair.m
//  openSNP
//
//  Created by gdyer on 16/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSHealthPair.h"

@implementation OSHealthPair
- (id)initWithQuantityTypeId:(nonnull NSString *)qtIdentifier unit:(HKUnit *)unit {
    self = [super init];
    if (self) {
        _type = [HKObjectType quantityTypeForIdentifier:qtIdentifier];
        _unit = unit;
    }
    
    return self;
}

- (double)doubleForValue:(HKQuantity *)value {
    return [value doubleValueForUnit:_unit];
}

- (NSString *)localizedStringValue:(HKQuantity *)value {
    return [NSNumberFormatter localizedStringFromNumber:@([self doubleForValue:value]) numberStyle:NSNumberFormatterNoStyle];
}


@end