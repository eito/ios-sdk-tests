//
//  EAISimulatedLocationManager.m
//  SimulatedLocationTest
//
//  Created by Eric Ito on 10/27/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "EAISimulatedLocationManager.h"

@interface EAISimulatedLocationManager ()
@property (nonatomic, copy, readwrite) NSArray *simulatedLocations;
@end

@implementation EAISimulatedLocationManager {
    //
    // applied to the passed in locations' corresponding timestamps
    // in order to have the time values be the real values.
    //
    // for instance, if the locations are from 2 hours ago, but you want
    // to play them back as if they were right now, each location would have an offset
    // of 2 * 60 * 60 == 7200 seconds such that the delegate receives locations
    // corresponding the the present time
    NSTimeInterval _timeOffset;
    
    //
    // index of the current location
    NSUInteger _currentIndex;
    
    //
    // fires location updates
    NSTimer *_timer;
}

- (id)initWithLocations:(NSArray *)locations {
    self = [super init];
    if (self) {
        self.simulatedLocations = locations;
    }
    return self;
}

- (void)startUpdatingLocation {
    // begin simulated locations
    if (![self.delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
        @throw [NSException exceptionWithName:@"Error" reason:@"You must implement the appropriate delegate methods" userInfo:nil];
        return;
    }
    CLLocation *first = [self.simulatedLocations firstObject];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval firstTimestamp = [[first timestamp] timeIntervalSince1970];
    _timeOffset = now - firstTimestamp;

    [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(fireLocationUpdates) userInfo:nil repeats:NO];
}

- (void)stopUpdatingLocation {
    // end simulated locations
}

- (void)fireLocationUpdates {
    CLLocation *userSpecifiedLoc = self.simulatedLocations[_currentIndex++];
    NSTimeInterval userSpecifiedLocTimestamp = [[userSpecifiedLoc timestamp] timeIntervalSince1970];
    NSDate *timestamp = [NSDate dateWithTimeIntervalSince1970: userSpecifiedLocTimestamp + _timeOffset];
    CLLocation *newLoc = [[CLLocation alloc] initWithCoordinate:userSpecifiedLoc.coordinate
                                                       altitude:userSpecifiedLoc.altitude
                                             horizontalAccuracy:userSpecifiedLoc.horizontalAccuracy
                                               verticalAccuracy:userSpecifiedLoc.verticalAccuracy
                                                         course:userSpecifiedLoc.course
                                                          speed:userSpecifiedLoc.speed
                                                      timestamp:timestamp];
    [self.delegate locationManager:self didUpdateLocations:@[newLoc]];

    if (_currentIndex < self.simulatedLocations.count) {
        // figure out next fire date
        CLLocation *nextLoc= self.simulatedLocations[_currentIndex];
        NSTimeInterval nextTime = [nextLoc.timestamp timeIntervalSince1970];
        NSTimeInterval diff = nextTime - userSpecifiedLocTimestamp;
        
        if (self.simulationMode == EAISimulatedLocationMode2X) {
            diff /= 2.0;
        }
        else if (self.simulationMode == EAISimulatedLocationMode4X) {
            diff /= 4.0;
        }
        else if (self.simulationMode == EAISimulatedLocationMode10X) {
            diff /= 10.0;
        }
        else if (self.simulationMode == EAISimulatedLocationModeCustom) {
            // check speed up
            if (self.speedup > 1.0) {
                diff /= self.speedup;
            }
        }
        [NSTimer scheduledTimerWithTimeInterval:diff target:self selector:@selector(fireLocationUpdates) userInfo:nil repeats:NO];
    }
}
@end
