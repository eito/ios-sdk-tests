//
//  ViewController.m
//  NSURLSessionTest
//
//  Created by Eric Ito on 12/10/13.
//  Copyright (c) 2013 Eric Ito. All rights reserved.
//

#define TEN_MB_FILE_URL     [NSURL URLWithString:@"http://mirror.internode.on.net/pub/test/10meg.test"]

#import "ViewController.h"

@interface ViewController ()<NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate, NSURLSessionDataDelegate>
{
    NSURLSessionDownloadTask *_dlTask;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // create a default background configuration
    NSURLSessionConfiguration *bgConfig = [NSURLSessionConfiguration backgroundSessionConfiguration:@"com.ericito.backgroundSession"];
    
    // create our session and setup delegate
    NSURLSession *dlSession = [NSURLSession sessionWithConfiguration:bgConfig delegate:self delegateQueue:nil];
    
    // instantiate download task with the URL to a 10MB test file
    _dlTask = [dlSession downloadTaskWithURL:TEN_MB_FILE_URL];
    
    // all tasks are created in a suspended state
    [_dlTask resume];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSURLSessionDelegate/NSURLSessionDownloadDelegate

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    // should copy from location to a destination in the app's Documents directory
    NSLog(@"Downloaded to URL: %@", location);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    NSLog(@"wrote %lld bytes of data: %lld of %lld ", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    NSLog(@"session completed: %@", error);
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    NSLog(@"events for background session finished");
    
    //
    // we need to have been passed the completion handler to let app delegate know
    // we are done
    if (self.completion) {
        self.completion();
        self.completion = nil;
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes {
    NSLog(@"Resumed...");
}

@end
