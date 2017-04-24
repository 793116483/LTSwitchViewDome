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


typedef enum : NSUInteger {
    LTSwitchTapBarViewSlidDirectionHorizontal,  // 默认水平方向
    LTSwitchTapBarViewSlidDirectionVertical,    // 垂直方向
} LTSwitchTapBarViewSlidDirection;



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
@property (nonatomic , assign)NSInteger selectionIndex ;


/**
 【1.3】move indicator to progress 范围(0.0 ~ 1.0)，设置该属性表示 指示器 移动到的 位置占总
 cotnetOfSize.width比例，需要时 用户自已设置。
 例如：n = 2，indicator 滑动到两个 title 中间，用户只需设置 0.5 就能达到效果。
 */
@property (nonatomic , assign)CGFloat   moveIndicatorProgress ;
/**
 【1.3.1】selection title 颜色变化 是否需要过渡, 默认 YES 。 <提示: 必须与 moveIndicatorProgress 配套使用>
 */
@property (nonatomic , getter=isTransitionTitleColorEnabled)BOOL   transitionTitleColorEnabled ;
/**
 【1.3.2】indicator 在滑动时 是否 可以伸缩 , 默认 YES 。 <提示: 必须与 moveIndicatorProgress 配套使用>
 */
@property (nonatomic , getter=isIndicatorStretchEnabled)BOOL   indicatorStretchEnabled ;
/**
 【1.3.3】每页切换周期比例：指示器滑动到了每个页面的 titleItemWidth * percentPageSlidCycle 的位置 就会变更 selectionIndex 记录的下标。（0.5 <= percentPageSlidCycle <= 1.0）, 默认为 1.0。 <提示: 必须与 moveIndicatorProgress 配套使用>
 */
@property (nonatomic , assign)CGFloat   percentPageSlidCycle ;


/**
 【1.4】title字体 是否需要 加粗(当选中的时候)，默认 NO
 */
@property (nonatomic , getter=isNeedBoldToTitleWhenSelection)BOOL needBoldToTitleWhenSelection ;
/**
 【1.5】通常不被选中状态下 title 颜色值 ，默认颜色 = UIColorFromRGB(0x666666)
 */
@property (nonatomic , strong)UIColor * titleColorNormal ;
/**
 【1.6】选中状态下 title 颜色值 ，默认颜色 = UIColorFromRGB(0x333333)
 */
@property (nonatomic , strong)UIColor * titleColorSelection ;
/**
 【1.7】每个 title 宽度大小，默认 = (self.bounds.size.widht / titleArray.count )
 */
@property (nonatomic , assign) CGFloat  titleItemWidth ;
/**
 【1.8】每个 title 字体大小，默认 = 16.0
 */
@property (nonatomic , assign) CGFloat  titleFontSize ;
/**
 【1.9】值表示 指示器移动到的位置 左边或右边总是会预留 titleItemWidth * reservedAlwaysShowItemWidthMultiple 的大小暴露在可视区域中，默认 = 2.0 ;
 reservedAlwaysShowItemWidthMultiple >= 0 永恒
 */
@property (nonatomic , assign) CGFloat  reservedAlwaysShowItemWidthMultiple ;



/**
 【 2 】内容 titles 显示超出了边框时提供的一些属性
 */
/**
 【2.1】是否可以拖动内容当 bounds 不够显示时需要拖动显示全，默认 = YES
 */
@property (nonatomic , getter=isUserDraggable) BOOL userDraggable ;
/**
 【2.2】可以拖动的范围大小，值的大小随 titleItemWidth 改变而改变
 恒等 = CGSize( titleItemWidth * count , self.bounds.size.height - topLineHeight - bottomLineHeight)，
 */
@property (nonatomic , assign) CGSize   contentSize ;



/**
 【 3 】指示器 相关属性
 */
/**
 【3.1】指示器 的高度；默认 = 2.5
 */
@property (nonatomic , assign)CGFloat   selectionIndicatorHeight ;
/**
 【3.2】指示器 的宽度；默认 = titleItemWidth
 */
@property (nonatomic , assign)CGFloat   selectionIndicatorWidht ;
/**
 【3.3】指示器 的颜色；默认 = UIColorFromRGB(0x333333) 灰色偏黑
 */
@property (nonatomic , strong)UIColor * selectionIndicatorColor ;
/**
 【3.4】当用户点击了某一块区域 指示器 move 时是否需要做动画，默认 = YES
 */
@property (nonatomic , getter=isShouldAnimateUserSelection) BOOL shouldAnimateUserSelection ;
/**
 【3.5】指示器 move 时动画的时间，默认 = 0.25
 */
@property (nonatomic , assign)NSTimeInterval  animationDuration ;



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
 【 5 】滑动方向，默认是 水平方向
 */
//@property (nonatomic , assign)LTSwitchTapBarViewSlidDirection slidDirection ;



/**
 【 6 】代理 , 如果当前对象 是集成在 LTSwitchView 类里面，则默认是当前 LTSwitchView 对象
 */
@property (nonatomic , weak)id<LTSwitchTapBarViewDelegate> delegate ;




@end
