//
//  NSArray+OSFunctionalMap.h
//  openSNP
//
//  Created by gdyer on 19/07/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import <Foundation/Foundation.h>

// simple category to provide a functional-programming style map/lambda interface
@interface NSArray (OSFunctionalMap)

- (NSArray *)map:(id (^)(id x, NSUInteger i))lambda ;

@end
