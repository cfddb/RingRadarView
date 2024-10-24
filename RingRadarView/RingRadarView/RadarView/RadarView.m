//
//  RadarView.m
//  HooCircleProgressView
//
//  Created by Dai Bo on 2024/10/22.
//  Copyright © 2024 PIngAnHealth. All rights reserved.
//

#import "RadarView.h"
 
#define CenterX self.bounds.size.width*0.5
#define CenterY self.bounds.size.height*0.5
 
#define DefaultRadarLineColor [UIColor colorWithWhite:1 alpha:0.7]
#define DefaultStartColor [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5]
#define DefaultEndColor [UIColor colorWithRed:1 green:1 blue:1 alpha:0]
 
#define DefaultCircleColor [UIColor colorWithWhite:1 alpha:0.5]
 
@interface RadarView ()
 
#pragma mark - 扫描类型的RadarView 属性
/** 扇形半径 */
@property (nonatomic, assign) CGFloat sectorRadius;
/** 扇形 角度 */
@property (nonatomic, assign) int angle;
/** 雷达 空心圆圈的数量 */
@property (nonatomic, assign) int radarLineNum;
/** 中心 空心圆的半径 (一般 这里放置一个圆形的头像) */
@property (nonatomic, assign) int hollowRadius;
 
#pragma mark - 扩散类型的RadarView 属性
/** 扩散动画 起始 的半径 */
@property (nonatomic, assign) CGFloat startRadius;
/** 扩散动画 结束 的半径 */
@property (nonatomic, assign) CGFloat endRadius;
/** 圆圈的颜色 */
@property (nonatomic, strong) UIColor * circleColor;
 
@property (nonatomic, strong) NSTimer * timer;
 
@property (nonatomic, assign) RadarViewType radarViewType;

@property (nonatomic, assign) CGFloat sectorRadius11111;
 
@end
 
@implementation RadarView
 
+ (RadarView *)scanRadarViewWithRadius:(CGFloat)radius angle:(int)angle radarLineNum:(int)radarLineNum hollowRadius:(CGFloat)hollowRadius {
    return [[self alloc] initWithRadius:radius angle:angle radarLineNum:radarLineNum hollowRadius:hollowRadius];
}
 
- (instancetype)initWithRadius:(CGFloat)radius
                         angle:(int)angle
                  radarLineNum:(int)radarLineNum
                  hollowRadius:(CGFloat)hollowRadius {
    if (self = [super init]) {
        self.radarViewType = RadarViewTypeScan;
        self.sectorRadius = radius;
        self.frame = CGRectMake(0, 0, radius*2, radius*2);
        self.angle = angle;
        self.radarLineNum = radarLineNum-1;
        self.hollowRadius = hollowRadius;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
 
+ (RadarView *)diffuseRadarViewWithStartRadius:(CGFloat)startRadius endRadius:(CGFloat)endRadius circleColor:(UIColor *)circleColor {
    return [[self alloc] initWithStartRadius:startRadius endRadius:endRadius circleColor:circleColor];
}
 
- (instancetype)initWithStartRadius:(CGFloat)startRadius endRadius:(CGFloat)endRadius circleColor:(UIColor *)circleColor {
    if (self = [super init]) {
        self.radarViewType = RadarViewTypeDiffuse;
        self.frame = CGRectMake(0, 0, endRadius*2, endRadius*2);
        self.startRadius = startRadius;
        self.endRadius = endRadius;
        self.circleColor = circleColor;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
 
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (_radarViewType == RadarViewTypeScan) {
        if (!_startColor) {
            _startColor = DefaultStartColor;
        }
        if (!_endColor) {
            _endColor = DefaultEndColor;
        }
        if (!_radarLineColor) {
            _radarLineColor = DefaultRadarLineColor;
        }
        
        // 画雷达线
        [self drawRadarLine];
        
        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetShouldAntialias(context, YES); // 开启抗锯齿
        CGFloat step = (_sectorRadius - _hollowRadius) / (_radarLineNum - 1);
        CGFloat radius111 = _hollowRadius + step * (_radarLineNum - 2);
        _sectorRadius11111 = radius111;
        // 把要画的扇形 分开画，一次画1°,每次的颜色渐变
        for (int i = 0; i < _angle; i++) {
            UIColor * color = [self colorWithCurrentAngleProportion:i*1.0/_angle];
            [self drawSectorWithContext:context color:color startAngle:-90-i];
        }
    }
}
 
/** 画扇形 */
- (void)drawSectorWithContext:(CGContextRef)context
                        color:(UIColor *)color
                   startAngle:(CGFloat)startAngle {
//    // 设置抗锯齿
//        CGContextSetAllowsAntialiasing(context, true);
//        CGContextSetShouldAntialias(context, true);
    //画扇形，也就画圆，只不过是设置角度的大小，形成一个扇形
    CGContextSetFillColorWithColor(context, color.CGColor);//填充颜色
    CGContextSetLineWidth(context, 0);//线的宽度
    //以self.radius为半径围绕圆心画指定角度扇形
    CGContextMoveToPoint(context, CenterX, CenterY);
    
    CGContextAddArc(context, CenterX, CenterY, _sectorRadius11111, startAngle * M_PI / 180, (startAngle-1) * M_PI / 180, 1);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFillStroke); //绘制路径
}
 
 
///** 画雷达线 */
//- (void)drawRadarLine {
//    CGFloat minRadius = (_sectorRadius-_hollowRadius)*(pow(0.618, _radarLineNum-1));
//    /** 画 围着空心半径的第一个空心圆，此圆不在计数内 */
//    [self drawLineWithRadius:_hollowRadius+minRadius*0.382];
//    
//    for (int i = 0; i < _radarLineNum; i++) {
//        [self drawLineWithRadius:_hollowRadius + minRadius/pow(0.618, i)];
//    }
//}
// 
///** 画空心圆 */
//- (void)drawLineWithRadius:(CGFloat)radius {
//    CAShapeLayer *solidLine =  [CAShapeLayer layer];
//    CGMutablePathRef solidPath =  CGPathCreateMutable();
//    solidLine.lineWidth = 1.0f ;
//    solidLine.strokeColor = _radarLineColor.CGColor;
//    solidLine.fillColor = [UIColor clearColor].CGColor;
//    CGPathAddEllipseInRect(solidPath, nil, CGRectMake(self.bounds.size.width*0.5-radius, self.bounds.size.height*0.5-radius, radius*2, radius*2));
//    solidLine.path = solidPath;
//    CGPathRelease(solidPath);
//    [self.layer addSublayer:solidLine];
//}

/** 画雷达线 */
- (void)drawRadarLine {
    // Calculate the step for even spacing between circles
    CGFloat step = (_sectorRadius - _hollowRadius) / (_radarLineNum - 1);
    
    for (int i = 0; i < _radarLineNum; i++) {
        CGFloat radius = _hollowRadius + step * i;
        // 判断是否为最外圈
        CGFloat lineWidth = (i == _radarLineNum - 1) ? 3.f : 1.f;
        [self drawLineWithRadius:radius lineWidth:lineWidth];
    }
}
 
/** 画空心圆 */
- (void)drawLineWithRadius:(CGFloat)radius lineWidth:(CGFloat)lineWidth{
    CAShapeLayer *solidLine = [CAShapeLayer layer];
    CGMutablePathRef solidPath = CGPathCreateMutable();
    solidLine.lineWidth = lineWidth;
    solidLine.strokeColor = _radarLineColor.CGColor;
    solidLine.fillColor = [UIColor clearColor].CGColor;
    CGPathAddEllipseInRect(solidPath, nil, CGRectMake(self.bounds.size.width * 0.5 - radius, self.bounds.size.height * 0.5 - radius, radius * 2, radius * 2));
    solidLine.path = solidPath;
    CGPathRelease(solidPath);
    [self.layer addSublayer:solidLine];
}

#pragma mark - 展示
- (void)showTargetView:(UIView *)targerView {
    [targerView addSubview:self];
    self.center = CGPointMake(targerView.bounds.size.width/2, targerView.bounds.size.height/2);
}
 
#pragma mark -
- (void)dismiss {
    [self removeFromSuperview];
}
 
#pragma mark - 开始动画
- (void)startAnimatian {
    if (_radarViewType == RadarViewTypeScan) {
        CABasicAnimation* rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat: 1 * M_PI * 2.0 ];
        rotationAnimation.duration = 2;
        rotationAnimation.cumulative = YES;
        rotationAnimation.repeatCount = INT_MAX;
        [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    } else {
        [self diffuseAnimation];
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(diffuseAnimation) userInfo:nil repeats:YES];
    }
}
 
#pragma mark - 结束动画
- (void)stopAnimation {
    if (_radarViewType == RadarViewTypeScan) {
        [self.layer removeAnimationForKey:@"rotationAnimation"];
    } else {
        [_timer invalidate];
        _timer = nil;
    }
}
 
- (UIColor *)colorWithCurrentAngleProportion:(CGFloat)angleProportion {
    NSArray * startRGBA = [self RGBA_WithColor:_startColor];
    NSArray * endRGBA = [self RGBA_WithColor:_endColor];
    CGFloat currentR = [startRGBA[0] floatValue] - ([startRGBA[0] floatValue]-[endRGBA[0] floatValue]) * angleProportion;
    CGFloat currentG = [startRGBA[1] floatValue] - ([startRGBA[1] floatValue]-[endRGBA[1] floatValue]) * angleProportion;
    CGFloat currentB = [startRGBA[2] floatValue] - ([startRGBA[2] floatValue]-[endRGBA[2] floatValue]) * angleProportion;
    CGFloat currentA = [startRGBA[3] floatValue] - ([startRGBA[3] floatValue]-[endRGBA[3] floatValue]) * angleProportion;
    return [UIColor colorWithRed:currentR green:currentG blue:currentB alpha:currentA];
}
 
/**
 *  将UIColor对象解析成RGBA 值 的数组
 *
 *  @param color UIColor对象，有RGBA值 初始化的
 *[UIColor colorWithRed:rValue green:gValue blue:bValue alpha:aValue]
 *
 *  @return 包含RGBA值得数组[rValue, gValue, bValue, aValue]
 */
- (NSArray *)RGBA_WithColor:(UIColor *)color {
    NSString * colorStr = [NSString stringWithFormat:@"%@", color];
    //将RGB值描述分隔成字符串
    NSArray * colorValueArray = [colorStr componentsSeparatedByString:@" "];
    NSString * R = colorValueArray[1];
    NSString * G = colorValueArray[2];
    NSString * B = colorValueArray[3];
    NSString * A = colorValueArray[4];
    return @[R, G, B, A];
}
 
/** 画圆 */
- (UIImage *)drawCircle {
    UIGraphicsBeginImageContext(CGSizeMake(_endRadius*2, _endRadius*2));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, CenterX, CenterY);
    CGContextSetFillColorWithColor(context, _circleColor.CGColor);
    CGContextAddArc(context, CenterX, CenterY, _endRadius, 0, -2*M_PI, 1);
    CGContextFillPath(context);
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}
 
- (void)diffuseAnimation {
    UIImageView * imgView = [[UIImageView alloc] init];
    imgView.image = [self drawCircle];
    imgView.frame = CGRectMake(0, 0, _startRadius, _startRadius);
    imgView.center = CGPointMake(CenterX, CenterY);
    [self addSubview:imgView];
    
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        imgView.frame = CGRectMake(0, 0, _endRadius*2, _endRadius*2);
        imgView.center = CGPointMake(CenterX, CenterY);
        imgView.alpha = 0;
    } completion:^(BOOL finished) {
        [imgView removeFromSuperview];
    }];
}
 
@end
