//
//  ViewController.m
//  RingRadarView
//
//  Created by Dai Bo on 2024/10/24.
//

#import "ViewController.h"

#import "GradientRingView.h"
#import "RadarView.h"


@interface ViewController ()

@property (nonatomic, assign) float progress;
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) RadarView * scanRadarView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    _progress = 0;
    
    GradientRingView *ringView = [[GradientRingView alloc] initWithFrame:CGRectMake(50, 100, 300, 300)];
    ringView.ringWidth = 8.0;
    ringView.progress = _progress;  // 75% 的进度
    ringView.backgroundGradientColors = @[
        [UIColor colorWithWhite:1.f alpha:0.5],
        [UIColor colorWithWhite:1.f alpha:0.2],
    ];
    ringView.progressGradientColors = @[
        [UIColor colorWithRed:254/255.0 green:53/255.0 blue:50/255.0 alpha:1.0],  // 深红
        [UIColor colorWithRed:26/255.0 green:2/255.0 blue:1/255.0 alpha:1.0],  // 淡红
    ];
    [self.view addSubview:ringView];
    
    // 创建一个每秒都会触发的定时器，但我们在回调中检查是否达到10秒
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 0.5 * NSEC_PER_SEC);

    dispatch_source_set_event_handler(self.timer, ^{
        [self updateData:ringView]; // 调用更新数据的方法
    });

    dispatch_resume(self.timer);
    
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(ringView.frame), self.view.bounds.size.width, self.view.bounds.size.width)];
    [self.view addSubview:view];
    
    _scanRadarView = [RadarView scanRadarViewWithRadius:80 angle:400 radarLineNum:10 hollowRadius:10];
    _scanRadarView.startColor = [UIColor redColor];
    _scanRadarView.endColor = [UIColor colorWithRed:237.f/255 green:120.f/255 blue:76.f/255 alpha:1];
    _scanRadarView.radarLineColor = [UIColor redColor];
    
    [_scanRadarView showTargetView:view];
    [_scanRadarView startAnimatian];
    
}

-(void)updateData:(GradientRingView*)ringView{
    if (_progress >= 1) {
        _progress = 0;
    }else{
        _progress +=0.1;
    }
    ringView.progress = _progress;
}


@end
