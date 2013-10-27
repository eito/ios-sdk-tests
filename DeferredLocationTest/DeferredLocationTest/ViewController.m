//
//  ViewController.m
//  DeferredLocationTest
//
//  Created by Eric Ito on 10/26/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) CLLocationManager *locationManager;
//
// array of arrays...each array contains location updates we received at given time

@property (nonatomic, strong) NSMutableArray *locations;
@property (nonatomic, strong) NSMutableArray *singleLocationUpdates;
@property (nonatomic, strong) NSMutableArray *multiLocationUpdates;
@end

@implementation ViewController {
    BOOL _atLeastFiveLocations;
    CLLocation *_lastLocation;
    BOOL _deferring;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.navigationItem.title = @"Location Test";
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
//    self.locationManager.activityType = CLActivityTypeFitness;
    
    self.locations = [@[]mutableCopy];
    self.multiLocationUpdates = [@[]mutableCopy];
    self.singleLocationUpdates = [@[]mutableCopy];
    
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"All locations";
    }
    else if (section == 1) {
        return @"Single location updates";
    }
    else {
        return @"Deferred location updates";
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 1;
    }
    else {
        return self.multiLocationUpdates.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    }
    
    //
    // total location updates
    if (indexPath.section == 0) {
        cell.textLabel.text = [NSString stringWithFormat:@"%lu location updates", (unsigned long)self.locations.count];
        cell.detailTextLabel.text = nil;
    }
    //
    // regular location updates
    else if (indexPath.section == 1) {
        cell.textLabel.text = [NSString stringWithFormat:@"%lu single location updates", (unsigned long)self.singleLocationUpdates.count];
        cell.detailTextLabel.text = nil;
    }
    //
    // deferred location updates
    else {
        NSArray *updates = self.multiLocationUpdates[indexPath.row];
        CLLocation *firstLoc = [updates firstObject];
        CLLocation *lastLoc = [updates lastObject];

        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setTimeStyle:NSDateFormatterMediumStyle];
        cell.textLabel.text = [NSString stringWithFormat:@"%lu updates @ %@", (unsigned long)updates.count, [df stringFromDate:lastLoc.timestamp]];
        CLLocationDistance distance = [firstLoc distanceFromLocation:lastLoc];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fm", distance];
    }

    return cell;
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    NSLog(@"%s -- error: %@", __PRETTY_FUNCTION__, error);
    _deferring = NO;
    _atLeastFiveLocations = NO;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%s -- %lu locations", __PRETTY_FUNCTION__, (unsigned long)locations.count);
    
    [self.locations addObjectsFromArray:locations];
    
    if (locations.count == 1) {
        [self.singleLocationUpdates addObject:locations];
    }
    else if (locations.count > 1) {
        [self.multiLocationUpdates addObject:locations];
    }
    
    _atLeastFiveLocations = (self.locations.count >= 5);
    
    if (!_deferring && _atLeastFiveLocations && [CLLocationManager deferredLocationUpdatesAvailable]) {
        NSLog(@"allow deferred location updates");
        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:CLTimeIntervalMax];
        _deferring = YES;
    }
    
    _lastLocation = [locations lastObject];
    
    [self.tableView reloadData];
}

@end
