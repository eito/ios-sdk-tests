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
    //
    // reset to 0 each time app launches
    application.applicationIconBadgeNumber = 0;
    
    LocationNavController *nav = [[LocationNavController alloc] initWithRootViewController:self.window.rootViewController];
    self.window.rootViewController = nav;
    return YES;
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    // Handle the notificaton when the app is running
    UIAlertView *localNoteAV = [[UIAlertView alloc] initWithTitle:@"Local Notification"
                                                          message:notif.alertBody
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
    [localNoteAV show];
}
							
@end
