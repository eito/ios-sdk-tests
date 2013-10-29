//
//  EAISimulatedLocationManager.h
//  Pulled from here: https://github.com/eito/ios-sdk-tests
//

#import <CoreLocation/CoreLocation.h>

typedef enum {
    EAISimulatedLocationModeRealTime = 0,
    EAISimulatedLocationMode2X,
    EAISimulatedLocationMode4X,
    EAISimulatedLocationMode10X,
    EAISimulatedLocationModeCustom
} EAISimulatedLocationMode;

//
// 
@interface EAISimulatedLocationManager : CLLocationManager

//
// expects an array of CLLocation objects
- (id)initWithLocations:(NSArray*)locations;

//
// the simulated locations
@property (nonatomic, copy, readonly) NSArray *simulatedLocations;

//
// Defaults to NO, if YES, will restart at 0th location
@property (nonatomic, assign) BOOL repeats;

//
// specifies the simulation mode -- the default is EAISimulatedLocationModeRealTime
//
// NOTE: if simuationMode is Custom, the speedup will not be used.
@property (nonatomic, assign) EAISimulatedLocationMode simulationMode;

//
// if simulation mode is EAISimulatedLocationModeCustom
// the time between location updates will be (the actual diff / speedup)
//
// for instance, 10X mode is interval/10.0
@property (nonatomic, assign) double speedup;

//
// if specified, all of the locations will be fired within the duration
// set to 0 to use actual times
//
// NOTE: the simulationDuration must be >= 5.0 seconds
@property (nonatomic, assign) NSTimeInterval simulationDuration;

@end
