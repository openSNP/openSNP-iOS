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
#import "HKHealthStore+OSExtensions.h"

@interface OSHomeViewController () {
    unsigned long n_types_obtained;
}
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

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:NULL readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            if (!success) {
                NSLog(@"HealthKit access error: %@", error);
                return;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // update based on user's health information.
                [self checkAccess];
            });
        }];
    } else {
    }
}

- (void)checkAccess {
    NSSet *typesToRead = [self dataTypesToRead];
    n_types_obtained = [typesToRead count];
    
    
    for (HKObjectType *type in [self dataTypesToRead]) {
        HKQuantityType *quantity = [HKObjectType quantityTypeForIdentifier:type.identifier];
        
        [self.healthStore os_mostRecentQuantitySampleOfType:quantity predicate:nil completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
            if (!mostRecentQuantity) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // quantity not available
                    n_types_obtained--;
                });
            }
            else {
                // Determine the weight in the required unit.
                HKUnit *weightUnit = [HKUnit poundUnit];
                double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
                
                // Update the user interface.
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"%@", [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle]);
                });
            }
        }];
    }
}


// Returns data to upload
- (NSSet *)dataTypesToRead {
    return [NSSet setWithObjects:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMassIndex],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierLeanBodyMass],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyFatPercentage],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierFlightsClimbed],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierAppleExerciseTime],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierElectrodermalActivity],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierInhalerUsage],
                                [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierNumberOfTimesFallen],
                                [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex],
                                [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth],
                                [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBloodType],
                                [HKCharacteristicType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierFitzpatrickSkinType], nil];
}

#pragma mark Segues

- (void)viewSettings {
    // TODO
}

#pragma mark Table view delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *iden = @"reuseCell";
    OSTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:iden];
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

#pragma mark Connections
- (void)updateFeed {
    
}


@end