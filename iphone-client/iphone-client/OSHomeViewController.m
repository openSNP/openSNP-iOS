//
//  OSHomeViewController.m
//  iphone-client
//
//  Created by gdyer on 13/06/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSHomeViewController.h"
#import "OSInfoTableViewCell.h"
#import "OSActionTableViewCell.h"
#import "OSFeedItem.h"
#import "OSHealthPair.h"
#import "NSArray+OSFunctionalMap.h"
#import "OSLoginViewController.h"
#import "OSConstants.h"
#import "KeychainItemWrapper.h"


@interface OSHomeViewController ()
@property (strong, nonatomic) NSMutableArray<OSFeedItem *> *cellData;
typedef enum : NSInteger {
    OSCellActionLogin = 0
} OSCellAction;
@end

@implementation OSHomeViewController

- (void)viewDidLoad {
    // Do any additional setup after loading the view, typically from a nib.
    [super viewDidLoad];
    self.healthStore = [[HKHealthStore alloc] init];
    self.cellData = [[NSMutableArray alloc] init];
    
    // don't show lines for empty cells
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 20)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;
    [self.tableView setContentInset:UIEdgeInsetsMake(20, 0, 0, 0)];
    
    // set the view's background color
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    self.navigationItem.title = @"openSNP";
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(updateFeed) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSString *)getUUID {
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
    return [keychain objectForKey:(__bridge NSString *)kSecValueData];
}

- (BOOL)userExists {
    return [self getUUID] != nil;
}


- (void)serveItem:(OSFeedItem *)item {
    [_cellData addObject:item];
    [self.tableView reloadData];
}


// displays a non-actionable error item
- (void)displayError:(NSString *)message {
    [_cellData removeAllObjects];
    OSFeedItem *errorItem = [[OSFeedItem alloc] initWithBody:message date:[NSDate date] imageName:@"exclamation_mark.png"];
    [self serveItem:errorItem];
}


- (void)displayLoginAction {
    [_cellData removeAllObjects];
    OSFeedItem *actionItem = [[OSFeedItem alloc] initWithActionDescription:@"— Please login —" actionId:OSCellActionLogin];
    [self serveItem:actionItem];
}


- (void)requestHealthAccess {
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:NULL readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                [self displayError:@"There was a problem getting Health data!"];
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![self userExists]) {
                    // user hasn't authenticated
                    [self displayLoginAction];
                } else {
                    [self updateFeed];
                }
            });
        }];
    } else {
        [self displayError:@"Health data isn't available on this device!"];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self requestHealthAccess];
}


- (NSArray *)characteristicsToRead {
    // characteristics are attributes users set only once, unlike quantities
    return @[[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
             [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
             [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType],
             [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierFitzpatrickSkinType]];
}


- (NSArray <OSHealthPair *>*)dataTypesAndUnits {
    return [@[@[HKQuantityTypeIdentifierBodyMassIndex, [HKUnit countUnit]],
              @[HKQuantityTypeIdentifierBodyFatPercentage, [HKUnit percentUnit]],
              @[HKQuantityTypeIdentifierHeight, [HKUnit meterUnit]],
              @[HKQuantityTypeIdentifierBodyMass, [HKUnit gramUnit]],
              @[HKQuantityTypeIdentifierLeanBodyMass, [HKUnit gramUnit]],
              @[HKQuantityTypeIdentifierStepCount, [HKUnit countUnit]],
              @[HKQuantityTypeIdentifierDistanceWalkingRunning, [HKUnit meterUnit]],
              @[HKQuantityTypeIdentifierDistanceCycling, [HKUnit meterUnit]],
              @[HKQuantityTypeIdentifierBasalEnergyBurned, [HKUnit jouleUnit]],
              @[HKQuantityTypeIdentifierActiveEnergyBurned, [HKUnit jouleUnit]],
              @[HKQuantityTypeIdentifierFlightsClimbed, [HKUnit countUnit]],
              @[HKQuantityTypeIdentifierNikeFuel, [HKUnit countUnit]],
              @[HKQuantityTypeIdentifierAppleExerciseTime, [HKUnit secondUnit]],
              @[HKQuantityTypeIdentifierHeartRate, [HKUnit unitFromString:@"count/min"]],
              @[HKQuantityTypeIdentifierBodyTemperature, [HKUnit degreeCelsiusUnit]],
              @[HKQuantityTypeIdentifierBasalBodyTemperature, [HKUnit degreeCelsiusUnit]],
              @[HKQuantityTypeIdentifierBloodPressureSystolic, [HKUnit millimeterOfMercuryUnit]],
              @[HKQuantityTypeIdentifierBloodPressureDiastolic, [HKUnit millimeterOfMercuryUnit]],
              @[HKQuantityTypeIdentifierRespiratoryRate, [HKUnit unitFromString:@"count/min"]],
              @[HKQuantityTypeIdentifierOxygenSaturation, [HKUnit percentUnit]],
              @[HKQuantityTypeIdentifierPeripheralPerfusionIndex, [HKUnit percentUnit]],
              @[HKQuantityTypeIdentifierBloodGlucose, [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli
                                                                              molarMass:HKUnitMolarMassBloodGlucose]
                                                       unitDividedByUnit:[HKUnit literUnit]]],
              @[HKQuantityTypeIdentifierNumberOfTimesFallen, [HKUnit countUnit]],
              @[HKQuantityTypeIdentifierElectrodermalActivity, [HKUnit siemenUnit]],
              @[HKQuantityTypeIdentifierBloodAlcoholContent, [HKUnit percentUnit]],
              @[HKQuantityTypeIdentifierInhalerUsage, [HKUnit countUnit]],
              @[HKQuantityTypeIdentifierForcedVitalCapacity, [HKUnit unitFromString:@"cm^3"]],
              @[HKQuantityTypeIdentifierForcedExpiratoryVolume1, [HKUnit unitFromString:@"cm^3"]],
              @[HKQuantityTypeIdentifierPeakExpiratoryFlowRate, [HKUnit unitFromString:@"cm^3"]]]
            map:^(id x, NSUInteger i) {
                return [[OSHealthPair alloc] initWithQuantityTypeId:x[0] unit:x[1]];
            }];
}



// Returns data to upload
- (NSSet *)dataTypesToRead {
    NSArray *types = [[self dataTypesAndUnits] map:^(OSHealthPair *x, NSUInteger i) {
        return x.type;
    }];
    
    
    return [NSSet setWithArray:
            [types arrayByAddingObjectsFromArray:[self characteristicsToRead]]];
}




#pragma mark Table view delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OSFeedItem *item = _cellData[indexPath.row];
    
    if (item.cellClass == [OSInfoTableViewCell class]) {
        static NSString *iden = @"infoCell";
        OSInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        if (!cell) {
            // the style choice is meaningless; this is simpler than writing a custom initializer
            cell = [[OSInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
        }
        cell.articleBody.text = item.body;
        cell.imgView.image = item.image;
        cell.dateTag.text = item.dateLabel;
        return cell;
    } else {
        static NSString *iden = @"actionCell";
        OSActionTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
        if (!cell) {
            // the style choice is meaningless; this is simpler than writing a custom initializer
            cell = [[OSActionTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
        }
        
        cell.actionDescriptionLabel.text = item.actionDescription;
        cell.actionId = item.actionId;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OSFeedItem *item = _cellData[indexPath.row];
    
    if (item.cellClass == [OSActionTableViewCell class]) {
        switch (item.actionId) {
            case OSCellActionLogin:
                [self presentLogin];
                break;
            default:
                break;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellData.count;
}


#pragma mark Transitions 
- (void)presentLogin {
    OSLoginViewController *loginVC = [[OSLoginViewController alloc] initWithURLString:LOGIN_URL];
    [self presentViewController:loginVC animated:YES completion:nil];
}


#pragma mark Connections
- (void)updateFeedFromDictionary:(NSDictionary *)respDict {
    if ([respDict[@"error"] integerValue] == 1) {
        // TODO: show an action cell allowing a refresh or contacting us
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        for (NSDictionary *event in respDict[@"message"]) {
            OSFeedItem *item = [[OSFeedItem alloc] initWithBody:event[@"message"]
                                                           date:[dateFormatter dateFromString:event[@"ts"]]
                                                      imageName:event[@"image"]];
            [_cellData addObject:item];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }
    
}
- (void)updateFeed {
    if (![self userExists]) {
        [self displayLoginAction];
    } else {
        NSMutableURLRequest *feedRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FEED_URL]];
        // set the user's key in the request header
        [feedRequest setValue:[self getUUID] forHTTPHeaderField:KEY_HTTP_HEADER_KEY];
        
        [[[NSURLSession sharedSession] dataTaskWithRequest:feedRequest
                                         completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                             [_cellData removeAllObjects];
                                             
                                             if (!error) {
                                                 NSError *jsonError = nil;
                                                 NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                          options:kNilOptions
                                                                                                            error:&jsonError];
                                                 if (jsonError) {
                                                     // TODO: ask user to file a bug report
                                                 } else {
                                                     [self updateFeedFromDictionary:respDict];
                                                 }
                                             } else {
                                                 // TODO: handle connection error (prompt to retry)
                                             }
                                         }] resume];
    }
    
    [self.refreshControl endRefreshing];
}

- (void)updateAfterLogin {
    [_cellData removeAllObjects];
    [self updateFeed];
}

- (void)performUpload {
    // TODO
}


#pragma mark Health queries

- (void)getPairAverage:(OSHealthPair *)pair {
    NSDate *end = [NSDate date];
    // TODO: allow customization of this span
    NSDate *start = [NSDate dateWithTimeInterval:-60*60*24*7 sinceDate:end];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:start endDate:end options:HKQueryOptionStrictStartDate];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:pair.type quantitySamplePredicate:predicate options:HKStatisticsOptionNone completionHandler:^(HKStatisticsQuery *q, HKStatistics *result, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                HKQuantity *quantity = result.averageQuantity;
                double d_value = [quantity doubleValueForUnit:pair.unit];
                // TODO: send d_value to a callback
            });
    }];
    [self.healthStore executeQuery:query];

}

@end