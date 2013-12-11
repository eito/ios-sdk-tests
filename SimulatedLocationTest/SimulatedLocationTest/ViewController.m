//
//  ViewController.m
//  SimulatedLocationTest
//
//  Created by Eric Ito on 10/27/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "ViewController.h"
#import "EAISimulatedLocationManager.h"

@interface ViewController ()<CLLocationManagerDelegate>
@property (nonatomic, strong) EAISimulatedLocationManager *lm;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.lm = [[EAISimulatedLocationManager alloc] initWithLocations:[self populateLocations]];
    self.lm.delegate = self;
    self.lm.simulationMode = EAISimulatedLocationMode10X;
    [self.lm startUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    NSLog(@"updated location: %@", [locations firstObject]);
}

-(NSArray*)populateLocations {
    NSMutableArray *simLocations = [@[] mutableCopy];
#warning Implement your method for population CLLocation objects here
    NSURL *url = [NSURL fileURLWithPath:@"/Users/eito/Desktop/simulated_huldacrooks.json"];
    NSData *jsonData = [NSData dataWithContentsOfURL:url];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
    NSArray *locations = [json valueForKey:@"locations"];
    for (NSDictionary *locationJSON in locations) {
        double speed = [locationJSON[@"speed"] doubleValue];
        double timestamp = [locationJSON[@"timestamp"] doubleValue];
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:timestamp];
        double latitude = [locationJSON[@"latitude"] doubleValue];
        double longitude = [locationJSON[@"longitude"] doubleValue];
        double elevation = [locationJSON[@"elevation"] doubleValue];
        double course = [locationJSON[@"course"] doubleValue];
        CLLocationAccuracy hAcc = [locationJSON[@"hAccuracy"] doubleValue];
        CLLocationAccuracy vAcc = [locationJSON[@"vAccuracy"] doubleValue];
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude, longitude);
        CLLocation *loc = [[CLLocation alloc] initWithCoordinate:coordinate
                                                        altitude:elevation
                                              horizontalAccuracy:hAcc
                                                verticalAccuracy:vAcc
                                                          course:course
                                                           speed:speed
                                                       timestamp:time];
        [simLocations addObject:loc];
    }
    
    return simLocations;
}
@end
