//
//  UIColor+Switch_RGBA_UIColor.m
//  LTSwitchViewDome
//
//  Created by 瞿杰 on 2017/4/19.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "UIColor+Switch_RGBA_UIColor.h"

@implementation UIColor (Switch_RGBA_UIColor)

#pragma mark - 将UIColor转换为RGBA值
+(NSArray *)switchCurrentUIColorToRGBA:(UIColor *)color
{
    CIColor * ciColor = [CIColor colorWithCGColor:color.CGColor];
    NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:4];
    [resultArr addObject:@(ciColor.red)];
    [resultArr addObject:@(ciColor.green)];
    [resultArr addObject:@(ciColor.blue)];
    [resultArr addObject:@(ciColor.alpha)];
    
    return resultArr;
}
#pragma mark - 将RGBA值转换为UIColor
+(UIColor *)switchRGBAToUIColor:(NSArray *)RGBAValues
{
    if (RGBAValues.count != 4) {
        return nil ;
    }
    CGFloat red = [RGBAValues[0] floatValue];
    CGFloat green = [RGBAValues[1] floatValue];
    CGFloat blue = [RGBAValues[2] floatValue];
    CGFloat alpha = [RGBAValues[3] floatValue];
    UIColor * color = [UIColor colorWithRed:red green:green blue:blue alpha:alpha];

    return color ;
}


@end
