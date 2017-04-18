//
//  LTSwitchTapBarView.h
//  LTSwitchViewDome-页面切换
//
//  Created by 瞿杰 on 2017/4/13.
//  Copyright © 2017年 yiniu. All rights reserved.
//  页面切换的 tapBar



//十六进制的颜色转为iOS可用的UIColor
#define UIColorFromRGB(hexValue) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromRGBA(hexValue,alphaValue)  [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue]



#import <UIKit/UIKit.h>


@class LTSwitchTapBarView ;

@protocol LTSwitchTapBarViewDelegate <NSObject>

@required
-(void)switchTapBarView:(LTSwitchTapBarView *)tapBarView selectionIndex:(NSInteger)index ;

@end


@interface LTSwitchTapBarView : UIView


/**
    【 1 】内容相关
 */
/**
    【1.1】title array 包含了所有文字内容信息，默认 = nil
*/
@property (nonatomic , strong)NSArray<NSString *> * titleArray ;
/**
    【1.2】当前选中的位置 (0...n-1) ，默认 = 0
*/
@property (nonatomic , readonly)NSInteger selectionIndex ;
/**
    【1.3】move indicator to location 范围(0.0 ~ 1.0)，设置该属性表示 指示器 移动到的 位置占总
          cotnetOfSize.width比例，需要时 用户自已设置。
          例如：n = 2，indicator 滑动到两个 title 中间，用户只需设置 0.5 就能达到效果。
 */
@property (nonatomic , assign)CGFloat   moveIndicatorToLocation ;
/**
    【1.4】通常不被选中状态下 title 颜色值 ，默认颜色 = UIColorFromRGB(0x666666)
 */
@property (nonatomic , strong)UIColor * titleColorNormal ;
/**
    【1.5】选中状态下 title 颜色值 ，默认颜色 = UIColorFromRGB(0x333333)
 */
@property (nonatomic , strong)UIColor * titleColorSelection ;
/**
    【1.6】每个 title 宽度大小，默认 = (self.bounds.size.widht / titleArray.count )
 */
@property (nonatomic , assign) CGFloat  titleItemWidth ;
/**
    【1.7】每个 title 字体大小，默认 = 16.0
 */
@property (nonatomic , assign) CGFloat  titleFontSize ;



/**
    【 2 】内容 titles 显示超出了边框时提供的一些属性
 */
/**
    【2.1】是否可以拖动内容当 bounds 不够显示时需要拖动显示全，默认 = YES
 */
@property (nonatomic , getter=isUserDraggable) BOOL userDraggable ;
/**
    【2.2】可以拖动的范围大小，值的大小随 titleItemWidth 改变而改变
          默认 = CGSize( titleItemWidth * count , self.bounds.size.height - 1)，
 */
@property (nonatomic , assign) CGSize   contentSize ;




/**
    【 3 】指示器 相关属性
 */
/**
    【3.1】指示器 的高度；默认 = 2.0
 */
@property (nonatomic , assign)CGFloat   selectionIndicatorHeight ;
/**
    【3.2】指示器 的宽度；默认 = 8.0
 */
@property (nonatomic , assign)CGFloat   selectionIndicatorWidht ;
/**
    【3.3】指示器 的颜色；默认 = UIColorFromRGB(0x333333) 灰色偏黑
 */
@property (nonatomic , strong)UIColor * selectionIndicatorColor ;
/**
    【3.4】当用户点击了某一块区域 指示器 move 时是否需要做动画，默认 = YES
 */
//@property (nonatomic , getter=isShouldAnimateUserSelection) BOOL shouldAnimateUserSelection ;



/**
    【 4 】分割线 相关属性
*/
/**
    【4.1】top 分割线 的颜色；默认 = UIColorFromRGB(0xdddddd)
 */
@property (nonatomic , strong)UIColor * topLineColor ;
/**
    【4.2】top 分割线 的高度；默认 = 0.5
 */
@property (nonatomic , assign)CGFloat   topLineHeight ;
/**
    【4.3】bottom 分割线 的颜色；默认 = UIColorFromRGB(0xdddddd)
 */
@property (nonatomic , strong)UIColor * bottomLineColor ;
/**
    【4.4】bottom 分割线 的高度；默认 = 0.5
 */
@property (nonatomic , assign)CGFloat   bottomLineHeight ;



/**
    【 5 】代理
 */
@property (nonatomic , weak)id<LTSwitchTapBarViewDelegate> delegate ;




@end
