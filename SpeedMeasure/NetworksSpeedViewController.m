//
//  NetworksSpeedViewController.m
//  SpeedMeasure
//
//  Created by Bryan Yuan on 1/12/17.
//  Copyright © 2017 BryanYuan. All rights reserved.
//

#import "NetworksSpeedViewController.h"
#import "DownloadSpeedHandler.h"

#define KSCreenWidth [UIScreen mainScreen].bounds.size.width
#define KSCreenHeight [UIScreen mainScreen].bounds.size.height

@interface NetworksSpeedViewController () <DownloadSpeedDelegate>
@property DownloadSpeedHandler *downloadHandler;
@property NSTimer *timeUp;

@property (nonatomic, strong) UIImageView *panelImage;//Panel
@property (nonatomic, strong) CALayer *pinLayer;//Pin
@property (nonatomic, strong) UILabel *speedRateLabel;

@property (nonatomic, strong) NSMutableArray<NSNumber *> *speedRateArray;

@end

@implementation NetworksSpeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.panelImage];
    [_panelImage.layer addSublayer:self.pinLayer];
    [self.view addSubview:self.speedRateLabel];
    [self resetSpeedRate];
    
    self.title = @"Speed Measure";
    [self.speedButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    self.speedButton.layer.cornerRadius = 5.0f;
    [self.speedButton setBackgroundColor:XY_TILT_COLOR];
    
}

- (NSMutableArray<NSNumber *> *)speedRateArray
{
    if (!_speedRateArray) {
        _speedRateArray = [NSMutableArray array];
    }
    return _speedRateArray;
}

- (void)insertRateArray:(CGFloat)rate
{
    if (rate <= 1) {
        return;
    }
    
    NSNumber *rateNumber = [NSNumber numberWithFloat:rate];
    [self.speedRateArray addObject:rateNumber];
}
- (CGFloat)averageRate
{
    NSLog(@"%s", __func__);
    CGFloat total;
    NSUInteger count = self.speedRateArray.count;
    if (count <= 0) {
        return 0;
    }
    
    for (NSNumber *num in self.speedRateArray) {
        CGFloat rate = [num floatValue];
        total += rate;
    }
    CGFloat average = total/count;
    return average;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.speedRateLabel setBounds:CGRectMake(0, 0, 150, 30)];
    CGPoint panelCenter = self.panelImage.center;
    [self.speedRateLabel setCenter:CGPointMake(panelCenter.x, panelCenter.y + 130)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.timeUp invalidate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self.downloadHandler downloadTask];
}

- (void)stopDownload
{
    
    [self.downloadHandler stop];
    self.downloadHandler = nil;
}

- (void)updateSpeedButtonTitleByStatus:(BOOL)isTesting
{
    if (isTesting) {
        [self.speedButton setTitle:@"Stop" forState:UIControlStateNormal];
    } else {
        [self.speedButton setTitle:@"Start" forState:UIControlStateNormal];
    }
}

- (void)timeUpHandler
{
    NSLog(@"%s", __func__);
    if (!self.downloadHandler.isDownloading) {
        return;
    }
    
    [self stopDownload];
    [self resetSpeedRate];
    [self resetSpeedRateLabel];
    
    [self updateSpeedButtonTitleByStatus:NO];
    [self setSpeedRateLabelWithAverage];
}

- (IBAction)speedButtonClicked:(id)sender
{
    if (!self.downloadHandler) {
        self.downloadHandler = [[DownloadSpeedHandler alloc] init];
        self.downloadHandler.delegate = self;
        [self.downloadHandler start];
        
        [self updateSpeedButtonTitleByStatus:YES];
        [self resetSpeedRateLabel];
    } else {
        [self stopDownload];
        
        [self.timeUp invalidate];
        self.timeUp = nil;
        
        [self updateSpeedButtonTitleByStatus:NO];
        [self setSpeedRateLabelWithAverage];
    }
    
    [self resetSpeedRate];
}

- (void)resetSpeedRate
{
    NSLog(@"%s", __func__);
    CGFloat angle = -3 * M_PI_4;
    self.pinLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

- (void)setSpeedRateLabelWithAverage
{
    NSLog(@"%s", __func__);
    
    CGFloat average = [self averageRate];
    if (average < 1.0) {
        return;
    }
    NSString *rateMsg = [self speedRateFormatedString:average];;
    NSString *averRateMsg = [NSString stringWithFormat:@"Average %@", rateMsg];
    [self.speedRateLabel setText:averRateMsg];
    [self.speedRateArray removeAllObjects];
}
- (void)resetSpeedRateLabel
{
    NSLog(@"%s", __func__);
    [self.speedRateLabel setText:@"0 Kps"];
}

- (void)updateSpeedRateLabel:(NSString *)speedStr
{
    [self.speedRateLabel setText:speedStr];
}

-(void)timeChange{
    
    CGFloat secondAngle = M_PI * 2 / 60.0;
    
    CGFloat angleSecond = [[NSCalendar currentCalendar]component:NSCalendarUnitSecond fromDate:[NSDate date]] * secondAngle; //seconds * angle per second
    
    _pinLayer.transform = CATransform3DMakeRotation(angleSecond, 0, 0, 1);
}

-(UIImageView *)panelImage{
    
    if(_panelImage == nil){
        
        _panelImage = [[UIImageView alloc]initWithFrame:CGRectMake(KSCreenWidth/2-130, KSCreenHeight/2-150, 260, 260)];
        _panelImage.image = [UIImage imageNamed:@"speedPanel"];
    }
    return _panelImage;
}

- (CALayer *)pinLayer
{
    if (!_pinLayer) {
        _pinLayer = [CALayer layer];
        UIImage *img = [UIImage imageNamed:@"speedPin"];
        _pinLayer.bounds = CGRectMake(0, 0, 5, 90);
        _pinLayer.contents = (id)img.CGImage;
        _pinLayer.position = CGPointMake(_panelImage.bounds.size.width / 2, _panelImage.bounds.size.height / 2 + 5);//position
        _pinLayer.anchorPoint = CGPointMake(.5, 1);
    }
    return _pinLayer;
}

- (UILabel *)speedRateLabel
{
    if (!_speedRateLabel) {
        _speedRateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _speedRateLabel.textAlignment = NSTextAlignmentCenter;
        _speedRateLabel.textColor = XY_TILT_COLOR;
    }
    return _speedRateLabel;
}

#pragma mark - DownloadSpeedDelegate

#define UNIT_1_K        1024
#define UNIT_128_K      (128*1024)
#define UNIT_512_K      (512*1024)
#define UNIT_1_M        (1*1024*1024)
#define UNIT_2_M        (2*1024*1024)
#define UNIT_5_M        (5*1024*1024)
#define UNIT_10_M       (10*1024*1024)
#define UNIT_20_M       (20*1024*1024)
#define UNIT_50_M       (50*1024*1024)
#define UNIT_100_M      (100*1024*1024)
#define M_PI_8          (M_PI_4/2)

- (NSString *)speedRateFormatedString:(CGFloat)kps
{
    NSString *speedStr = @"0 Kps";
    if (kps < UNIT_1_M) {
        speedStr = [NSString stringWithFormat:@"%0.2f Kps", kps/UNIT_1_K];
    } else {
        speedStr = [NSString stringWithFormat:@"%0.2f Mps", kps/UNIT_1_M];
        NSLog(@"%f %f %@", kps, kps/UNIT_1_M, speedStr);
    }
    
    return speedStr;
}

- (CGFloat)angleOfSpeed:(int64_t)speed betweenLow:(int64_t)low andHigh:(int64_t)high withUnit:(double)unit
{
    CGFloat angle = unit * (speed - low)/(high - low);
    return angle;
}

- (void)progress:(CGFloat)kps
{
    //NSLog(@"%s %f", __func__, kps);
    NSString *speedStr = [self speedRateFormatedString:kps];
    
    [self updateSpeedRateLabel:speedStr];
    
    [self insertRateArray:kps];
    CGFloat angle;
    if (kps < UNIT_128_K) {
        angle = [self angleOfSpeed:kps betweenLow:0 andHigh:UNIT_128_K withUnit:M_PI_4];
    } else if (kps < UNIT_512_K) {
        angle = M_PI_4 + [self angleOfSpeed:kps betweenLow:UNIT_128_K andHigh:UNIT_512_K withUnit:M_PI_4];
    } else if (kps < UNIT_2_M) {
        angle = 2 * M_PI_4 + [self angleOfSpeed:kps betweenLow:UNIT_512_K andHigh:UNIT_2_M withUnit:M_PI_4];
    } else if (kps < UNIT_5_M) {
        angle = 3 * M_PI_4 + [self angleOfSpeed:kps betweenLow:UNIT_2_M andHigh:UNIT_5_M withUnit:M_PI_4];
    } else if (kps < UNIT_10_M) {
        angle = 4 * M_PI_4 + [self angleOfSpeed:kps betweenLow:UNIT_5_M andHigh:UNIT_10_M withUnit:M_PI_8];
    } else if (kps < UNIT_20_M) {
        angle = M_PI + M_PI_8 + [self angleOfSpeed:kps betweenLow:UNIT_10_M andHigh:UNIT_20_M withUnit:M_PI_8];
    } else if (kps < UNIT_50_M) {
        angle = M_PI + 2 * M_PI_8 + [self angleOfSpeed:kps betweenLow:UNIT_20_M andHigh:UNIT_50_M withUnit:M_PI_8];
    } else if (kps < UNIT_100_M) {
        angle = M_PI + 3 * M_PI_8 + [self angleOfSpeed:kps betweenLow:UNIT_50_M andHigh:UNIT_100_M withUnit:M_PI_8];
    }
    angle = angle - 3 * M_PI_4;
    _pinLayer.transform = CATransform3DMakeRotation(angle, 0, 0, 1);
}

- (void)didStart
{
    NSLog(@"%s", __func__);
    [self performSelector:@selector(timeUpHandler) withObject:nil afterDelay:15.0];
}

- (void)didFinishedWithError:(NSError *)err
{
    NSLog(@"%s %@", __func__, err);
}

@end
