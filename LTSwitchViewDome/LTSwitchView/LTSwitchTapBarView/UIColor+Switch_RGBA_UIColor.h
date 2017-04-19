//
//  UIColor+Switch_RGBA_UIColor.h
//  LTSwitchViewDome
//
//  Created by 瞿杰 on 2017/4/19.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Switch_RGBA_UIColor)

/**
    把UIColor 对象转换成 red、green、blue 与 alpha 按顺序放在数组里
 */
+(NSArray *)switchCurrentUIColorToRGBA:(UIColor *)color ;

/**
    把 red、green、blue 与 alpha 按顺序放在数组里 转成 UIColor 对象
 */
+(UIColor *)switchRGBAToUIColor:(NSArray *)RGBAValues ;


@end
