//
//  AppDelegate.m
//  DeferredLocationTest
//
//  Created by Eric Ito on 10/26/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "AppDelegate.h"
#import "LocationNavController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    LocationNavController *nav = [[LocationNavController alloc] initWithRootViewController:self.window.rootViewController];
    self.window.rootViewController = nav;
    return YES;
}
							
@end
