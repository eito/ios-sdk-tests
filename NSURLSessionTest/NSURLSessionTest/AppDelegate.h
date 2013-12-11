//
//  AppDelegate.h
//  NSURLSessionTest
//
//  Created by Eric Ito on 12/10/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy) void (^backgroundSessionCompletionHandler)();
@end
