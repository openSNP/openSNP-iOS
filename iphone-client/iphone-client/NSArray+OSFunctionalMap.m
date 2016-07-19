//
//  NSArray+OSFunctionalMap.m
//  openSNP
//
//  Created by gdyer on 19/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "NSArray+OSFunctionalMap.h"

@implementation NSArray (OSFunctionalMap)

- (NSArray *)map:(id (^)(id x, NSUInteger i))lambda {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id x, NSUInteger i, BOOL *stop) {
        [result addObject:lambda(x, i)];
    }];
    return result;
}

@end
