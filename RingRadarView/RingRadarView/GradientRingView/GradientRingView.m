//
//  GradientRingView.m
//  HooCircleProgressView
//
//  Created by Dai Bo on 2024/10/17.
//  Copyright © 2024 PIngAnHealth. All rights reserved.
//

#import "GradientRingView.h"

@implementation GradientRingView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _ringWidth = 20.0;
        _progress = 0.0;
        _backgroundGradientColors = @[
            [UIColor grayColor],
            [UIColor whiteColor]
        ];
        _progressGradientColors = @[
            [UIColor colorWithRed:1.0 green:0.7 blue:0.7 alpha:1.0],  // 淡红
            [UIColor redColor]  // 深红
        ];
        [self setupLayers];
    }
    return self;
}

- (void)setupLayers {
    // 清除之前的层
    [self.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat radius = (MIN(width, height) - _ringWidth) / 2;
    
    // 创建三段圆环
    for (int i = 0; i < 3; i++) {
        CGFloat startAngle = (i * 120.0) * (M_PI / 180.0) - M_PI_2;
        CGFloat endAngle = ((i + 1) * 120.0) * (M_PI / 180.0) - M_PI_2;
        
        // 创建底色渐变圆环
        [self createGradientRingWithColors:self.backgroundGradientColors
                                startAngle:startAngle
                                  endAngle:endAngle
                                  lineWidth:_ringWidth
                                isProgress:NO];
        
        // 创建进度渐变圆环
        [self createGradientRingWithColors:self.progressGradientColors
                                startAngle:startAngle
                                  endAngle:endAngle
                                  lineWidth:_ringWidth
                                isProgress:YES];
    }
}

// 创建渐变圆环的方法
- (void)createGradientRingWithColors:(NSArray<UIColor *> *)colors
                         startAngle:(CGFloat)startAngle
                           endAngle:(CGFloat)endAngle
                           lineWidth:(CGFloat)lineWidth
                         isProgress:(BOOL)isProgress {
    
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat height = CGRectGetHeight(self.bounds);
    CGFloat radius = (MIN(width, height) - lineWidth) / 2;
    
    // 创建渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, width, height);
    
    // 渐变颜色设置
    NSMutableArray *cgColors = [NSMutableArray array];
    for (UIColor *color in colors) {
        [cgColors addObject:(id)color.CGColor];
    }
    gradientLayer.colors = cgColors;
    
    // 计算每个渐变层的起点和终点
    CGPoint endPoint = [self pointForAngle:startAngle];
    CGPoint startPoint = [self pointForAngle:endAngle];
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    
    // 创建用于裁剪渐变的CAShapeLayer (用于创建圆环形状)
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.lineWidth = lineWidth;
    maskLayer.fillColor = [UIColor clearColor].CGColor;
    maskLayer.strokeColor = [UIColor blackColor].CGColor;
    
    // 创建圆环路径
    CGPoint center = CGPointMake(width / 2, height / 2);
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center
                                                        radius:radius
                                                    startAngle:startAngle
                                                      endAngle:endAngle
                                                     clockwise:YES];
    maskLayer.path = path.CGPath;
    if (isProgress) {
        maskLayer.strokeEnd = _progress;  // 进度层根据进度更新
    }
    gradientLayer.mask = maskLayer;  // 将渐变层的 mask 设置为圆环路径
    
    // 添加渐变层到视图中
    [self.layer addSublayer:gradientLayer];
}

// 计算圆周上点的相对位置
- (CGPoint)pointForAngle:(CGFloat)angleInRadians {
    CGFloat x = 0.5 + 0.5 * cos(angleInRadians);
    CGFloat y = 0.5 + 0.5 * sin(angleInRadians);
    return CGPointMake(x, y);
}

- (void)updateView {
    [self setupLayers];  // 更新所有层
}

#pragma mark - Setter
- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self updateView];
}

- (void)setRingWidth:(CGFloat)ringWidth {
    _ringWidth = ringWidth;
    [self updateView];
}

- (void)setBackgroundGradientColors:(NSArray<UIColor *> *)backgroundGradientColors {
    _backgroundGradientColors = backgroundGradientColors;
    [self updateView];
}

- (void)setProgressGradientColors:(NSArray<UIColor *> *)progressGradientColors {
    _progressGradientColors = progressGradientColors;
    [self updateView];
}

@end

