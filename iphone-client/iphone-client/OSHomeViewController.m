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

#define LOGIN_URL @"https://opensnp.2pitau.org/login"
#define AUTHENTICATED_DEFAULT_KEY @"user_has_authenticated"

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
    
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStyleDone target:self action:@selector(viewSettings)];
    self.navigationItem.rightBarButtonItem = settings;
    
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(updateFeed) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)serveItem:(OSFeedItem *)item {
    [_cellData addObject:item];
    [self.tableView reloadData];
}

- (void)displayError:(NSString *)message {
    [_cellData removeAllObjects];
    OSFeedItem *errorItem = [[OSFeedItem alloc] initWithBody:message date:[NSDate date] imageName:@"exclamation_mark.png"];
    [self serveItem:errorItem];
}


- (void)displayLoginAction {
    [_cellData removeAllObjects];
    OSFeedItem *actionItem = [[OSFeedItem alloc] initWithActionDescription:@"Please login with openSNP" actionId:OSCellActionLogin];
    [self serveItem:actionItem];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:NULL readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                [self displayError:@"Problem getting Health data!"];
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (![[NSUserDefaults standardUserDefaults] boolForKey:AUTHENTICATED_DEFAULT_KEY]) {
                    // user hasn't authenticated
                    [self displayLoginAction];
                    
                }
            });
        }];
    } else {
        [self displayError:@"Health data isn't available on this device!"];
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
              @[HKQuantityTypeIdentifierBloodGlucose, [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli molarMass:HKUnitMolarMassBloodGlucose] unitDividedByUnit:[HKUnit literUnit]]],
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

- (void)viewSettings {
    // TODO
}
- (void)presentLogin {
    OSLoginViewController *loginVC = [[OSLoginViewController alloc] initWithURLString:LOGIN_URL];
    [self presentViewController:loginVC animated:YES completion:nil];
}

#pragma mark Connections
- (void)updateFeed {
    // TODO
}


@end
