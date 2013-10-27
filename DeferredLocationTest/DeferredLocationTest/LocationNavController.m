//
//  LocationNavController.m
//  DeferredLocationTest
//
//  Created by Eric Ito on 10/26/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import "LocationNavController.h"

@implementation LocationNavController

#pragma Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    UIColor *navColor = [UIColor blueColor];
//    navColor = [UIColor colorWithRed:(120/255.0) green:(135/255.0) blue:(150/255.0) alpha:1.0];
//    navColor = [UIColor colorWithRed:(57/255.0)  green:(79/255.0)  blue:(96/255.0)  alpha:1.0];
//    navColor = [UIColor colorWithRed:(39/255.0)  green:(87/255.0)  blue:(255/255.0)  alpha:1.0];
    
    [[UINavigationBar appearance] setBarTintColor:navColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    [self setNeedsStatusBarAppearanceUpdate];
    
}
@end
