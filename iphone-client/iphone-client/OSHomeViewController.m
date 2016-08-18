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
    - remaining 2 TODOs on this page
 */
@interface OSHomeViewController ()
@property (strong, nonatomic) NSMutableArray<OSFeedItem *> *cellData;
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSDictionary *toUpload;
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

// show an action cell
- (void)serveItem:(OSFeedItem *)item {
    [_cellData addObject:item];
    [self.tableView reloadData];
}

// displays a non-actionable error item
- (void)displayError:(NSString *)message {
    [_cellData removeAllObjects];
    OSFeedItem *errorItem = [[OSFeedItem alloc] initWithBody:message
                                                        date:[NSDate date]
                                                   imageName:@"stop_sign.png"];
    errorItem.isError = TRUE;
    [self serveItem:errorItem];
}


- (void)displayLoginAction {
    [_cellData removeAllObjects];
    OSFeedItem *loginAction = [[OSFeedItem alloc] initWithActionDescription:@"— Please login —" completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            // display login webview
            OSLoginViewController *loginVC = [[OSLoginViewController alloc] init];
            [self presentViewController:loginVC animated:YES completion:nil];
        });
    }];
                       
    [self serveItem:loginAction];
}

- (void)displayAuthorizeAction {
    [_cellData removeAllObjects];
    OSFeedItem *actionItem = [[OSFeedItem alloc] initWithActionDescription:@"— Please authorize health access —" completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestHealthAccess];
        });
    }];
                       
    [self serveItem:actionItem];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:READ_WELCOME_USER_KEY]) {
        UIAlertController *welcomeAlert = [UIAlertController alertControllerWithTitle:@"Welcome to openSNP Health!"
                                                                              message:WELCOME_MESSAGE
                                                                       preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *close = [UIAlertAction actionWithTitle:@"※" style:UIAlertActionStyleCancel handler:nil];
        [welcomeAlert addAction:close];
        [self presentViewController:welcomeAlert animated:YES completion:^{
            [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:READ_WELCOME_USER_KEY];
        }];
    }
}

- (void)authorizedHealth {
    // set default to avoid re-requesting access
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:AUTHORIZED_HEALTH_USER_KEY];
    
    // add authorization to the user's feed
    NSMutableURLRequest *authorizedRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:AUTHORIZED_EVENT_URL]];
    
    // set the user's key in the request header
    NSString *accountUsername = [[self getKeychain] objectForKey:(__bridge NSString *)kSecAttrAccount];
    [authorizedRequest setValue:[self getUUID] forHTTPHeaderField:KEY_HTTP_HEADER_KEY];
    [authorizedRequest setValue:accountUsername forHTTPHeaderField:EMAIL_HTTP_HEADER_KEY];
    
    [[_session dataTaskWithRequest:authorizedRequest
                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                     // it's not very important that this request succeeds, so no error checking
                 }] resume];
}

- (void)requestHealthAccess {
    if ([HKHealthStore isHealthDataAvailable]) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:AUTHORIZED_HEALTH_USER_KEY]) {
            // the user has already answered the request to authorize
            return;
        }
        
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:NULL readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                // view updates must occur on the main thread
                if (!success) {
                    [self displayError:@"There was a problem getting Health data!"];
                }
                
                [self authorizedHealth];
                [self updateFeed];
            });
            
            for (OSHealthPair *pair in [self dataTypesAndUnits]) {
                // request weekly notifications when data is modified
                [_healthStore enableBackgroundDeliveryForType:pair.type frequency:HKUpdateFrequencyWeekly withCompletion:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        // background delivery was successful; upload the attribute
                        [self performUpload:pair];
                    } else {
                        // TODO add item to (server) feed about failure
                    }
                }];
            }
        }];
        
    } else {
        [self displayError:@"Health data isn't available on this device!"];
    }
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // requesting health access will call
    [self updateFeed];
    
    for (OSHealthPair *pair in [self dataTypesAndUnits]) {
        [self performUpload:pair];
    }
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
                // convert the 2D-array to health-pairs (this is just convenience/nomenclature)
                return [[OSHealthPair alloc] initWithQuantityTypeId:x[0] unit:x[1]];
            }];
}



// returns data to upload
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
        cell.action = item.action;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // action and info cells are the same height
    return 68.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    OSFeedItem *item = _cellData[indexPath.row];
    
    if (item.cellClass == [OSActionTableViewCell class]) {
        item.action();
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellData.count;
}


#pragma mark -
- (void)updateFeedFromDictionary:(NSDictionary *)respDict {
    if ([respDict[@"error"] integerValue] == 1) {
        // there's a 400-coded error
        [self displayError:[NSString stringWithFormat:@"Request denied because \"%@\". This could be a bug; tap to file a report.", respDict[@"message"]]];
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
        self.navigationItem.rightBarButtonItem.enabled = false;
        [self displayLoginAction];
    } else if (![[NSUserDefaults standardUserDefaults] boolForKey:AUTHORIZED_HEALTH_USER_KEY]) {
        [self displayAuthorizeAction];
    } else {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
        
        NSMutableURLRequest *feedRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:FEED_URL]];
        
        // set the user's key in the request header
        NSString *accountUsername = [[self getKeychain] objectForKey:(__bridge NSString *)kSecAttrAccount];
        [feedRequest setValue:[self getUUID] forHTTPHeaderField:KEY_HTTP_HEADER_KEY];
        [feedRequest setValue:accountUsername forHTTPHeaderField:EMAIL_HTTP_HEADER_KEY];
        
        [[_session dataTaskWithRequest:feedRequest
                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                         if (_cellData && _cellData.count)
                             [_cellData removeAllObjects];
                         else
                             _cellData = [NSMutableArray array];
                         
                         //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                         if (!error) {
                             
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

// called after successful login from OSLoginVC
- (void)updateAfterLogin {
    self.navigationItem.rightBarButtonItem.enabled = true;
}

// upload an individual health-pair
- (void)performUpload:(OSHealthPair *)pair {
    _toUpload = nil;
    [self getPairAverage:pair];
    while (_toUpload == nil) { /* spin */ }
    NSLog(@"%@", _toUpload);
    
    NSError *error;
    // serialize the ``_toUpload`` dict (with attribute name and weekly average)
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:_toUpload
                                                       options:0
                                                         error:&error];
    NSMutableURLRequest *uploadRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:UPLOAD_URL]];
    [uploadRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    // data will be sent via POST
    [uploadRequest setHTTPMethod:@"POST"];
    [uploadRequest setHTTPBody:jsonData];
    
    // authentication is the same as ``/feed``: credentials are put in the request's header
    [uploadRequest setValue:[self getUUID] forHTTPHeaderField:KEY_HTTP_HEADER_KEY];
    NSString *email = [[self getKeychain] objectForKey:(__bridge NSString *)kSecAttrAccount];
    [uploadRequest setValue:email forHTTPHeaderField:EMAIL_HTTP_HEADER_KEY];
    
    [[_session dataTaskWithRequest:uploadRequest
                 completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                     [self updateFeed];
                     
                     if (error) {
                         // TODO: handle connection error (prompt to retry)
                     }
                 }] resume];
}


#pragma mark Health queries

// find the average of the type of ``pair`` above some time
- (void)getPairAverage:(OSHealthPair *)pair {
    NSDate *end = [NSDate date];
    // ``start`` is a week ago
    NSDate *start = [NSDate dateWithTimeInterval:-60*60*24*7 sinceDate:end];
    // predicate with range for this past week
    NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:start
                                                               endDate:end
                                                               options:HKQueryOptionStrictStartDate];
    HKStatisticsQuery *query = [[HKStatisticsQuery alloc] initWithQuantityType:pair.type
                                                       quantitySamplePredicate:predicate
                                                                       options:HKStatisticsOptionNone
                                                             completionHandler:^(HKStatisticsQuery *q, HKStatistics *result, NSError *error) {
                                                                 NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                                                 NSTimeZone *tz = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
                                                                 [dateFormatter setTimeZone:tz];
                                                                 [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                                                                 
                                                                 // average value over the course of the week
                                                                 HKQuantity *average = result.averageQuantity;
                                                                 HKQuantity *min = result.minimumQuantity;
                                                                 HKQuantity *max = result.maximumQuantity;
                                                                 
                                                                 CGFloat d_average = [average doubleValueForUnit:pair.unit];
                                                                 CGFloat d_min = [min doubleValueForUnit:pair.unit];
                                                                 CGFloat d_max = [max doubleValueForUnit:pair.unit];
                                                                 // create a dictionary with the string-classname of the attribute along with value ``quantity``
                                                                 _toUpload = [NSDictionary dictionaryWithObjectsAndKeys:
                                                                              [NSNumber numberWithFloat:d_average], @"average",
                                                                              [NSNumber numberWithFloat:d_min], @"min",
                                                                              [NSNumber numberWithFloat:d_max], @"max",
                                                                              [NSString stringWithFormat:@"%@", pair.unit], @"unit",
                                                                              [NSString stringWithFormat:@"%@", pair.type], @"type",
                                                                              [dateFormatter stringFromDate:start], @"utc_start_date",
                                                                              [dateFormatter stringFromDate:end], @"utc_end_date",
                                                                              [[NSTimeZone localTimeZone] name], @"local_timezone_name",
                                                                              nil];
                                                             }];
    [self.healthStore executeQuery:query];
}

@end