//
//  ViewController.h
//  NSURLSessionTest
//
//  Created by Eric Ito on 12/10/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (nonatomic, copy) void(^completion)();
@end
