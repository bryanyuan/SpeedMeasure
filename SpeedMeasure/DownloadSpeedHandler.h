//
//  DownloadSpeedHandler.h
//  SpeedMeasure
//
//  Created by Bryan Yuan on 1/12/17.
//  Copyright © 2017 BryanYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol DownloadSpeedDelegate <NSObject>
- (void)didStart;
- (void)didFinishedWithError:(NSError *)err;
- (void)progress:(CGFloat)kps;
@end

@interface DownloadSpeedHandler : NSObject

@property id<DownloadSpeedDelegate> delegate;
@property (nonatomic, readonly) BOOL isDownloading;
- (void)start;
- (void)stop;
@end
