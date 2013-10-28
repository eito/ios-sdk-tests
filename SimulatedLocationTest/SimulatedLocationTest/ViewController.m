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
    return simLocations;
}
@end
