//
//  LTSwitchView.h
//  LawTea
//
//  Created by 瞿杰 on 2017/4/5.
//
//  页面切换view 可以包含的控件为 UIView or UIViewController 


#import <UIKit/UIKit.h>


typedef enum : NSUInteger { // 方向枚举
    LTSwitchViewSlideDirectionHorizontal, // 默认水平方向
    LTSwitchViewSlideDirectionVertical    // 垂直方向
} LTSwitchViewSlideDirection;


@class LTSwitchView ;


@protocol LTSwitchViewDelegate <NSObject>
@optional
// 1.某个 subViewOrVc(view 或 viewController)没有在屏幕上显示过并且将要显示在屏幕上通知代理,每个添加的子对象只调用一次
// viewController 也可以在 自身文件内的 viewWillAppear: 方法里面加载所需的数据
-(void)switchView:(LTSwitchView *)switchView subViewOrVcLoadingDataIfNeed:(id)subViewOrVc ;

// 2.某个 subViewOrVc (view 或 viewController) 将要出现 时通知代理
-(void)switchView:(LTSwitchView *)switchView willAppearSubViewOrVc:(id)subViewOrVc ;

// 3.切换页面的 过程变动 floatPageIndex ：页面切换移动过程占总共可以移动的距离比例；范围：( 0 ~ 1.0 )
-(void)switchView:(LTSwitchView *)switchView pageIndexChanging:(CGFloat)floatPageIndex ;
// 4.切换页面 时通知代理
-(void)switchView:(LTSwitchView *)switchView pageIndexChanged:(NSInteger)currentPageIndex ;

// 5.某个 subViewOrVc (view 或 viewController) 可能将要消失 在可视区域（ 只有在将要出现另一个页面的条件下调用 ）
-(void)switchView:(LTSwitchView *)switchView willDisAppearSubViewOrVc:(id)subViewOrVc ;

// 6.某个 subViewOrVc (view 或 viewController) 已经消失 在可视区域时调用
-(void)switchView:(LTSwitchView *)switchView didDisAppearSubViewOrVc:(id)subViewOrVc ;

@end



@interface LTSwitchView : UIView

// 0.contentView：包含了整个的内容的 View ，可以用于刷新,不要改变一些已设置过的属性
@property (nonatomic , readonly) UITableView * contentView ;

// 1.基于childViewsOrViewControllers可变数组的下标的  当前的页码，默认是0
@property (nonatomic , assign)NSInteger currentPageIndex ;
@property (nonatomic , weak , readonly)id currentSubViewOrVc ;


// 2.可以滑动的方向，默认为 水平方向
@property (nonatomic , assign) LTSwitchViewSlideDirection slideDirection ;


// 3.headerView 默认为 nil
@property (nonatomic , strong)UIView * headerView ;
//  3.1 headerViewSlideEnle 表示是否可以上下滑动（即），默认 YES
@property (nonatomic , assign , getter=isheaderViewSlideEnabled) BOOL headerViewSlideEnabled ;
/**
 *  3.2  默认为 0.0 ;
 * 【在向上滑动时 HeaderView 需要永远显示 headerViewAlwayShowHeightWhenMoveUp 的高度在 switchView 顶部】;
 * 【headerViewAlwayShowHeightWhenMoveUp 从 headerView 底部算起， 恒等于 >= 0.0 】
 */
@property (nonatomic , assign) CGFloat headerViewAlwayShowHeightWhenMoveUp ;
/**
 *  3.3  默认为 0.0 ;
 * 【 在向下滑动时 HeaderView.y 需要永远 >= headerViewAlwayShowLocationWhenMoveDown【即 headerView 距离switchView 顶部 的大小】，从 headerView 底部算起， 恒等于 >= 0.0 】;
 * 【 在向下滑动时 HeaderView 顶部永远与 当前类对象顶部的距离 】
 */
@property (nonatomic , assign) CGFloat headerViewAlwayShowLocationWhenMoveDown ;
/**
 *  3.4 headerViewAlwayShowHeightWhenMoveDown 设置上面两个滑动限制是否有效，默认YES
 * 【=YES效果：headerView 可以无限制地上下滑动 】
 * 【=NO效果：向下滑动时 contentView.contentOffset.y 不能小于0，向上滑动时】
 */
@property (nonatomic , getter=isHeaderViewAlwayShowSettingEffective) BOOL headerViewAlwayShowSettingEffective ;



// 4. 每页显示的页面大小
@property (nonatomic , assign) CGSize itemSize ;

// 4.2 每页切换周期比例：滑动到了 (itemSize.width or itemSize.height)*percentPageSlidCycle 的位置 变更 currentPageIndex 记录的下标，调用代理方法通知代理改变页面。
//【 0.0 <= percentPageSlidCycle <= 1.0 】, 默认为 0.5（即滑到一半时切换页面） 。
@property (nonatomic , assign) CGFloat percentPageSlidCycle ;

// 4.2 设置、添加 和 删除 对象方法
//*【 如果 UIViewController 的 view 里面有多个 UIScrollView or UIScrollView 子类对象，那么如果需要上下滑动时整体的跟着 动，那么以最后添加的为准，如果view.subviews里面只有一个这样的对象，可以不用注意 】。
/**
 *  当前类对象里面只放两种类型的对象,除此之外全被删除：
 * 【 UIViewController 、UIViewController子类、UIView 和 UIView子类 】
 */
-(instancetype)initWithChildViewsOrVcs:(NSMutableArray *)childViewsOrVcs;

//  获取所有的子 views and 子 viewControllers
-(NSArray *)allChildViewsAndViewControllers ;

//  添加 多个view and ViewController
-(void)addChildViewsOrVcs:(NSMutableArray *)childViewsOrVcs ;

//  添加 view Or ViewController
-(void)addViewOrVc:(id)viewOrVc ;
//  viewOrVc 只有是 view Or ViewController 及 它们子类 的对象才会被添加；needRefreshData是否需要刷新
-(void)addViewOrVcIfNeed:(id)viewOrVc needRefreshData:(BOOL)needRefreshData ;

//  删除所有的view Or ViewController
-(void)removeAllViewsAndVcs ;

//  删除 view Or ViewController
-(void)removeViewOrVc:(id)viewOrVc ;


// 5.代理
@property (nonatomic , weak) id<LTSwitchViewDelegate> delegate ;


@end
