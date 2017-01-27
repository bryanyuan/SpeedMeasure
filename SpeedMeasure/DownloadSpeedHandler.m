//
//  DownloadSpeedHandler.m
//  SpeedMeasure
//
//  Created by Bryan Yuan on 1/12/17.
//  Copyright © 2017 BryanYuan. All rights reserved.
//

#import "DownloadSpeedHandler.h"

@interface DownloadSpeedHandler () <NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@property int64_t totalCount;
@property int64_t completedCount;
@property int64_t lastSecondCount;
@property NSTimer *timer;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@end

@implementation DownloadSpeedHandler

#define UPDATE_PROGRESS_TIME_INTERVAL   0.4

- (instancetype)init
{
    self = [super init];
    return self;
}
- (void)dealloc
{
    NSLog(@"%s", __func__);
    [self destroyTimer];
    [self.dataTask cancel];
    [self.downloadTask cancel];
}
- (void)start
{
    _isDownloading = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self getUrl:@"http://download.thinkbroadband.com/100MB.zip" complete:nil];
    });
    
}

- (void)reStart
{
    NSLog(@"%s", __func__);
    [self start];
}

- (void)destroyTimer
{
    NSLog(@"%s", __func__);
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)stop
{
    NSLog(@"%s", __func__);
    _isDownloading = NO;
    [self destroyTimer];
    [self.dataTask cancel];
    [self.downloadTask cancel];
}

- (void)willDownload
{
    NSLog(@"%s", __func__);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:UPDATE_PROGRESS_TIME_INTERVAL target:self selector:@selector(reportProgress) userInfo:nil repeats:YES];
    [self.timer fire];
    
    if (self.delegate) {
        [self.delegate didStart];
    }
}

- (void)didFinish
{
    NSLog(@"%s", __func__);
    if (self.delegate) {
        [self.delegate didFinishedWithError:nil];
    }
}

- (void)updateProgress:(int64_t)completed ofTotal:(int64_t)total
{
//    NSLog(@"%s %lld %lld", __func__, completed, total);
    if (completed <= 0 || total <= 0) {
        return;
    }
    
    self.completedCount = completed;
    self.totalCount = total;
}

- (void)reportProgress
{
//    NSLog(@"%s", __func__);
    int64_t currentCount = self.completedCount;
    CGFloat kps = (currentCount - self.lastSecondCount)/UPDATE_PROGRESS_TIME_INTERVAL;
    self.lastSecondCount = currentCount;
    
    if (kps < 0) {
        return;
    }
    
    __weak DownloadSpeedHandler *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (weakSelf.delegate) {
            [weakSelf.delegate progress:kps];
        }
    });
    
}

- (void)getUrl:(NSString *)url complete:(void (^)(NSURLResponse *response, id responseObject, NSError *error))completionHandler
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    self.dataTask = [session dataTaskWithRequest:request];
    [self.dataTask resume];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"%s", __func__);
    completionHandler(NSURLSessionResponseBecomeDownload);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    NSLog(@"%s %@", __func__, error);
    if (error) {
        [self didFinish];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask
{
    NSLog(@"%s", __func__);
    self.downloadTask = downloadTask;
    [self.downloadTask resume];
    
    [self willDownload];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"%s", __func__);
    self.downloadTask = nil;
    [self reStart];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    //NSLog(@"%s %lld %lld %lld", __func__, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    [self updateProgress:totalBytesWritten ofTotal:totalBytesExpectedToWrite];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"%s", __func__);
}



@end
