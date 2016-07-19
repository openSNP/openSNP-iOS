//
//  OSHomeViewController.m
//  iphone-client
//
//  Created by gdyer on 13/06/2016.
//  Copyright © 2016 openSNP. All rights reserved.
//

#import "OSHomeViewController.h"
#import "OSTableViewCell.h"
#import "OSFeedItem.h"
#import "OSHealthPair.h"
#import "NSArray+OSFunctionalMap.h"

@interface OSHomeViewController ()
@property (strong, nonatomic) NSMutableArray<OSFeedItem *> *cellData;
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

- (void)displayError:(NSString *)message {
    [_cellData removeAllObjects];
    OSFeedItem *errorItem = [[OSFeedItem alloc] initWithBody:message date:[NSDate date] imageName:@"exclamation_mark.png"];
    [_cellData addObject:errorItem];
    [self.tableView reloadData];
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
                // update based on user's health information.
                [self checkAccess];
            });
        }];
    } else {
        [self displayError:@"Health data isn't available on this device!"];
    }
}

- (void)checkAccess {
    // TODO
    NSSet *typesToRead = [self dataTypesToRead];
    
    
    for (HKObjectType *type in [self dataTypesToRead]) {
        HKQuantityType *quantity = [HKObjectType quantityTypeForIdentifier:type.identifier];
        
    }
}


- (NSArray *)dataTypesAndUnits {
    return @[@[HKQuantityTypeIdentifierBodyMassIndex, [HKUnit countUnit]],
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
             @[HKQuantityTypeIdentifierHeartRate, [HKUnit unitFromString:@"count/sec"]],
             @[HKQuantityTypeIdentifierBodyTemperature, [HKUnit degreeCelsiusUnit]],
             @[HKQuantityTypeIdentifierBasalBodyTemperature, [HKUnit degreeCelsiusUnit]],
             @[HKQuantityTypeIdentifierBloodPressureSystolic, [HKUnit millimeterOfMercuryUnit]],
             @[HKQuantityTypeIdentifierBloodPressureDiastolic, [HKUnit millimeterOfMercuryUnit]],
             @[HKQuantityTypeIdentifierRespiratoryRate, [HKUnit unitFromString:@"count/sec"]],
             @[HKQuantityTypeIdentifierOxygenSaturation, [HKUnit percentUnit]],
             @[HKQuantityTypeIdentifierPeripheralPerfusionIndex, [HKUnit percentUnit]],
             @[HKQuantityTypeIdentifierBloodGlucose, [[HKUnit moleUnitWithMetricPrefix:HKMetricPrefixMilli molarMass:HKUnitMolarMassBloodGlucose] unitDividedByUnit:[HKUnit literUnit]]],
             @[HKQuantityTypeIdentifierNumberOfTimesFallen, [HKUnit countUnit]],
             @[HKQuantityTypeIdentifierElectrodermalActivity, [HKUnit siemenUnit]],
             @[HKQuantityTypeIdentifierBloodAlcoholContent, [HKUnit percentUnit]],
             @[HKQuantityTypeIdentifierInhalerUsage, [HKUnit countUnit]],
             @[HKQuantityTypeIdentifierForcedVitalCapacity, [HKUnit unitFromString:@"cm^3"]],
             @[HKQuantityTypeIdentifierForcedExpiratoryVolume1, [HKUnit unitFromString:@"cm^3"]],
             @[HKQuantityTypeIdentifierPeakExpiratoryFlowRate, [HKUnit unitFromString:@"cm^3"]]];
}


// Returns data to upload
- (NSSet *)dataTypesToRead {
    NSArray *types = [[self dataTypesAndUnits] map:^(id x, NSUInteger i) {
        return x[0];
    }];
    
    
    return [NSSet setWithArray:
            [types arrayByAddingObjectsFromArray:@[[HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                                                   [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                                                   [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType],
                                                   [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierFitzpatrickSkinType]]]];
}



#pragma mark Segues

- (void)viewSettings {
    // TODO
}

#pragma mark Table view delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *iden = @"reuseCell";
    OSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
    if (!cell) {
        cell = [[OSTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:iden];
    }
    OSFeedItem *item = [_cellData objectAtIndex:[indexPath row]];
    cell.articleBody.text = item.body;
    cell.imgView.image = item.image;
    cell.dateTag.text = item.dateLabel;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68.;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellData.count;
}

#pragma mark Connections
- (void)updateFeed {
    
}


@end
