//
//  GradientRingView.h
//  HooCircleProgressView
//
//  Created by Dai Bo on 2024/10/17.
//  Copyright © 2024 PIngAnHealth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GradientRingView : UIView

// 底色圆环的渐变色数组（从灰到白）返着放入数组（白灰）
@property (nonatomic, strong) NSArray<UIColor *> *backgroundGradientColors;

// 进度圆环的渐变色数组（从淡红到深红）返着放入数组
@property (nonatomic, strong) NSArray<UIColor *> *progressGradientColors;

// 圆环的宽度
@property (nonatomic, assign) CGFloat ringWidth;

// 进度 [0, 1]，表示总进度
@property (nonatomic, assign) CGFloat progress;

// 更新视图的方法
- (void)updateView;

@end

