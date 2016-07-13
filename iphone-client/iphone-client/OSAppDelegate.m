//
//  OSAppDelegate.m
//  iphone-client
//
//  Created by gdyer on 13/06/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSAppDelegate.h"
#import "OSHomeViewController.h"
@import HealthKit;

@interface OSAppDelegate ()
@property (nonatomic) HKHealthStore *healthStore;
@end

@implementation OSAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont fontWithName:@"Avenir" size:16], NSFontAttributeName, [UIColor blackColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];

    // Override point for customization after application launch.
    //_healthStore = [[HKHealthStore alloc] init];
    //UIWindow *window = [UIApplication sharedApplication].keyWindow;
    //OSHomeViewController *hvc = (OSHomeViewController *)window.rootViewController;
    //[hvc setHealthStore:_healthStore];
    //
    //if ([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]) {
    //    NSSet *readTypes = [hvc dataTypesToRead];
    //    for (HKObjectType *type in readTypes) {
    //        [_healthStore enableBackgroundDeliveryForType:type frequency:HKUpdateFrequencyImmediate withCompletion:^(BOOL success, NSError * _Nullable error) {
    //            if (success) {
    //                // TODO
    //            } else {
    //                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@""
    //                                                                               message:@"This is an alert."
    //                                                                        preferredStyle:UIAlertControllerStyleAlert];
    //            }
    //            
    //        }];
    //    }
    //}
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
