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
// holds all location updates -- array of CLLocations
@property (nonatomic, strong) NSMutableArray *locations;

//
// holds an single-location updates -- array of arrays
@property (nonatomic, strong) NSMutableArray *singleLocationUpdates;

//
// holds an multi-location updates -- array of arrays
@property (nonatomic, strong) NSMutableArray *multiLocationUpdates;
@end

@implementation ViewController {
    //
    // flag to determine if we should try to allow deferred location updates
    BOOL _atLeastFiveLocations;
    
    //
    // if we are currently deferring, we  don't want to attempt to call allowDefer... again
    BOOL _deferring;
    
    //
    // date formatter to specify time of location updates
    NSDateFormatter *_medStyleDF;
    
    CLRegion *_myRegion;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Location Updates Test";
    
    //
    // create our date formatter
    _medStyleDF = [[NSDateFormatter alloc] init];
    [_medStyleDF setTimeStyle:NSDateFormatterMediumStyle];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.activityType = CLActivityTypeFitness;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    
    self.locations = [@[]mutableCopy];
    self.multiLocationUpdates = [@[]mutableCopy];
    self.singleLocationUpdates = [@[]mutableCopy];
    
    [self.locationManager startUpdatingLocation];
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
    if (section == 2) {
        return self.multiLocationUpdates.count;
    }
    else {
        return 1;
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

        cell.textLabel.text = [NSString stringWithFormat:@"%lu updates @ %@", (unsigned long)updates.count, [_medStyleDF stringFromDate:lastLoc.timestamp]];
        CLLocationDistance distance = [firstLoc distanceFromLocation:lastLoc];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%.2fm", distance];
    }

    return cell;
}

#pragma mark CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    NSLog(@"%s -- error: %@", __PRETTY_FUNCTION__, error);
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    localNotif.alertBody = [NSString stringWithFormat:@"DEFER ended with error: %@ @ %@", [error localizedDescription], [_medStyleDF stringFromDate:[NSDate date]]];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = self.multiLocationUpdates.count;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    _deferring = NO;
//    _atLeastFiveLocations = NO;
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"%s -- %lu locations", __PRETTY_FUNCTION__, (unsigned long)locations.count);
    
    [self.locations addObjectsFromArray:locations];
    
    if (locations.count == 1) {
        [self.singleLocationUpdates addObject:locations];
    }
    else if (locations.count > 1) {
        [self.multiLocationUpdates addObject:locations];
        UILocalNotification *localNotif = [[UILocalNotification alloc] init];
        localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
        localNotif.alertBody = [NSString stringWithFormat:@"%d deferred updates @ %@", locations.count, [_medStyleDF stringFromDate:[NSDate date]]];
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        localNotif.applicationIconBadgeNumber = self.multiLocationUpdates.count;
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    }
    
    //_atLeastFiveLocations = (self.locations.count >= 5);
    _atLeastFiveLocations = YES;
    
    if (!_deferring && _atLeastFiveLocations && [CLLocationManager deferredLocationUpdatesAvailable]) {
        NSLog(@"allow deferred location updates");
        [self.locationManager allowDeferredLocationUpdatesUntilTraveled:CLLocationDistanceMax timeout:CLTimeIntervalMax];
        _deferring = YES;
    }
    
    [self.tableView reloadData];
}

-(void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    localNotif.alertBody = [NSString stringWithFormat:@"PAUSED updates @ %@", [_medStyleDF stringFromDate:[NSDate date]]];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = self.multiLocationUpdates.count;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    _myRegion = [[CLCircularRegion alloc] initWithCenter:self.locationManager.location.coordinate radius:100 identifier:@"MYREGION"];
    [self.locationManager startMonitoringForRegion:_myRegion];

    
}

-(void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    localNotif.alertBody = [NSString stringWithFormat:@"RESUMED updates @ %@", [_medStyleDF stringFromDate:[NSDate date]]];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = self.multiLocationUpdates.count;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    localNotif.alertBody = [NSString stringWithFormat:@"FAILED with error: %@", [error localizedDescription]];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = self.multiLocationUpdates.count;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    if (![region.identifier isEqualToString:@"MYREGION"]) {
        return;
    }
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    localNotif.alertBody = [NSString stringWithFormat:@"EXITED REGION"];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = self.multiLocationUpdates.count;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    [self.locationManager stopMonitoringForRegion:_myRegion];
    [self.locationManager startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    if (![region.identifier isEqualToString:@"MYREGION"]) {
        return;
    }
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    localNotif.alertBody = [NSString stringWithFormat:@"ENTERRED REGION"];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = self.multiLocationUpdates.count;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region {
    if (![region.identifier isEqualToString:@"MYREGION"]) {
        return;
    }
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    localNotif.fireDate = [NSDate dateWithTimeIntervalSinceNow:0.1];
    NSString *stateStr = nil;
    if (state == CLRegionStateInside) {
        stateStr = @"inside";
    }
    else if (state == CLRegionStateOutside) {
        stateStr = @"outside";
    }
    else {
        stateStr = @"unknown";
    }
    localNotif.alertBody = [NSString stringWithFormat:@"REGION STATE: %@", stateStr];
    localNotif.soundName = UILocalNotificationDefaultSoundName;
    localNotif.applicationIconBadgeNumber = self.multiLocationUpdates.count;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
}
@end
