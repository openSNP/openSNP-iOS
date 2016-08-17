//
//  OSHomeViewController.m
//  iphone-client
//
//  Created by gdyer on 13/06/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSHomeViewController.h"
#import "OSInfoTableViewCell.h"
#import "OSSystemMessageViewer.h"
#import "OSActionTableViewCell.h"
#import "OSFeedItem.h"
#import "OSHealthPair.h"
#import "NSArray+OSFunctionalMap.h"
#import "OSLoginViewController.h"
#import "OSConstants.h"
#import "KeychainItemWrapper.h"

/* TODO:
    - it appears logging in/out doesn't successfully update the feed afterwards (manually works, though)
    - remaining 2 TODOs on this page
 */
@interface OSHomeViewController ()
@property (strong, nonatomic) NSMutableArray<OSFeedItem *> *cellData;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSDictionary *toUpload;
typedef enum : NSInteger {
    OSCellActionLogin = 0,
    OSCellActionAuthorize = 1
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
    
    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    self.navigationItem.title = @"openSNP";
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(updateFeed) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    
    // configure session so that cache is ignored
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    sessionConfig.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    self.session = [NSURLSession sessionWithConfiguration:sessionConfig];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"systemMessage"]) {
        OSFeedItem *selectedCell = _cellData[[[self tableView] indexPathForSelectedRow].row];
        if (selectedCell.cellClass == [OSInfoTableViewCell class]) {
            [(OSSystemMessageViewer *)segue.destinationViewController setFeedItem:selectedCell];
        }
    }
}

- (KeychainItemWrapper *)getKeychain {
    return [[KeychainItemWrapper alloc] initWithIdentifier:KEYCHAIN_ID accessGroup:nil];
}

- (NSString *)getUUID {
    return [[self getKeychain] objectForKey:(__bridge NSString *)kSecValueData];
}

- (BOOL)userExists {
    NSString *uuid = [self getUUID];
    return (uuid != nil) && ([uuid length] > 0);
}

- (void)serveItem:(OSFeedItem *)item {
    [_cellData addObject:item];
    [self.tableView reloadData];
}

// displays a non-actionable error item
- (void)displayError:(NSString *)message {
    [_cellData removeAllObjects];
    OSFeedItem *errorItem = [[OSFeedItem alloc] initWithBody:message date:[NSDate date] imageName:@"exclamation_mark.png"];
    errorItem.isError = TRUE;
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
            // view updates must occur on the main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!success) {
                    [self displayError:@"There was a problem getting Health data!"];
                }
                if (![self userExists]) {
                    // user hasn't authenticated
                    self.navigationItem.rightBarButtonItem.enabled = false;
                    [self displayLoginAction];
                } else {
                    [self updateFeed];
                    for (OSHealthPair *pair in [self dataTypesAndUnits]) {
                        [_healthStore enableBackgroundDeliveryForType:pair.type frequency:HKUpdateFrequencyWeekly withCompletion:^(BOOL success, NSError * _Nullable error) {
                            if (success) {
                                [self performUpload:pair];
                            } else {
                                // TODO add item to (server) feed about failure
                            }
                        }];
                    }
                }
            });
        }];
        
    } else {
        self.navigationItem.rightBarButtonItem.enabled = false;
        [self displayError:@"Health data isn't available on this device!"];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // requesting health access will call
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
            case OSCellActionAuthorize:
                [self requestHealthAccess];
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
        // there's a 400-coded error
        [self displayError:[NSString stringWithFormat:@"Request denied because \"%@\". This is likely a bug; tap to file a report.", respDict[@"message"]]];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [dateFormatter setTimeZone:tz];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        for (NSDictionary *event in respDict[@"message"]) {
            OSFeedItem *item = [[OSFeedItem alloc] initWithBody:event[@"message"]
                                                           date:[dateFormatter dateFromString:event[@"ts"]]
                                                      imageName:event[@"image"]];
            item.verb = event[@"verb"];
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
        [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
        
        NSMutableURLRequest *feedRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FEED_URL]];
        
        // set the user's key in the request header
        NSString *accountUsername = [[self getKeychain] objectForKey:(__bridge NSString *)kSecAttrAccount];
        [feedRequest setValue:[self getUUID] forHTTPHeaderField:KEY_HTTP_HEADER_KEY];
        [feedRequest setValue:accountUsername forHTTPHeaderField:EMAIL_HTTP_HEADER_KEY];
        
        [[_session dataTaskWithRequest:feedRequest
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         [_cellData removeAllObjects];
                         
                         if (!error) {
                             
                             NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                             
                             NSError *jsonError = nil;
                             NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:kNilOptions
                                                                                        error:&jsonError];
                             if (jsonError) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self displayError:[NSString stringWithFormat:@"Unable to parse JSON: %@", jsonError.localizedDescription]];
                                 });
                             } else {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self updateFeedFromDictionary:respDict];
                                 });
                             }
                         } else {
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [self displayError:[NSString stringWithFormat:@"Connection error: %@", error.localizedDescription]];
                             });
                         }
                     }] resume];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = FALSE;
    [self.refreshControl endRefreshing];
}

- (void)updateAfterLogin {
    [_cellData removeAllObjects];
    self.navigationItem.rightBarButtonItem.enabled = true;
    [self updateFeed];
}

- (void)performUpload:(OSHealthPair *)pair {
    _toUpload = nil;
    [self getPairAverage:pair];
    while (_toUpload == nil) { /* spin */ }
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_toUpload
                                                       options:0
                                                         error:&error];
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setHTTPBody:jsonData];
    
    [uploadRequest setValue:[self getUUID] forHTTPHeaderField:KEY_HTTP_HEADER_KEY];
    NSString *email = [[self getKeychain] objectForKey:(__bridge NSString *)kSecAttrAccount];
    [uploadRequest setValue:email forHTTPHeaderField:EMAIL_HTTP_HEADER_KEY];
    
    [[_session dataTaskWithRequest:uploadRequest
                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                     [_cellData removeAllObjects];
                     
                     if (error) {
                         // TODO: handle connection error (prompt to retry)
                     }
                 }] resume];
}


#pragma mark Health queries

// find the average of the type of ``pair`` above some time
- (void)getPairAverage:(OSHealthPair *)pair {
    NSDate *end = [NSDate date];
    NSDate *start = [NSDate dateWithTimeInterval:-60*60*24*7 sinceDate:end];
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:start endDate:end options:HKQueryOptionStrictStartDate];
    
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:pair.type
                                                       quantitySamplePredicate:predicate
                                                                       options:HKStatisticsOptionNone
                                                             completionHandler:^(HKStatisticsQuery *q, HKStatistics *result, NSError *error) {
                                                                 HKQuantity *quantity = result.averageQuantity;
                                                                 CGFloat d_value = [quantity doubleValueForUnit:pair.unit];
                                                                 _toUpload = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                              [NSNumber numberWithFloat:d_value], @"value",
                                                                              [NSString stringWithFormat:@"%@", pair.type], @"type",
                                                                              nil];
                                                             }];
    [self.healthStore executeQuery:query];
}

@end