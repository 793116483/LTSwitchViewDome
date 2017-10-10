//
//  LTViewColloerSwitchView.m
//  LawTea
//
//  Created by 瞿杰 on 2017/4/5.
//
//

#import "LTSwitchView.h"
#import "LTSwitchViewCollectionCell.h"


@interface LTSwitchView ()<UICollectionViewDelegate,UICollectionViewDataSource,
UITableViewDelegate , UITableViewDataSource , UIGestureRecognizerDelegate>


//【1】 与代理有关
//【1.1】 判断调用次数频率高的代理方法是否可以调用
@property (nonatomic , assign) BOOL canCallPageIndexChanging;
@property (nonatomic , assign) BOOL canCallPageIndexChanged;



//【2】 与 collectionView 有关
@property (nonatomic , weak) UIViewController * topViewController ;
@property (nonatomic , strong) UICollectionView * collectionView ;

//【2.1】 里面只放两种类型的对象,除此之外全被删除：
// UIViewController 、UIViewController子类、UIView 和 UIView子类； 默认是 nil
@property (nonatomic , strong)NSMutableArray * childViewsOrViewControllers ;
//【2.1.1】记录 view or viewController 第一次显示在界面上时 view or viewController 所在childViewsOrViewControllers中的位置( 为了记录只调用一次 代理 可能需要加载数据的方法 )
@property (nonatomic , strong) NSMutableArray * needFirstLoadDataViewIndex ;

//【2.2】【 保留需要计算 collectionView 滑动的 方向 】
@property (nonatomic , assign) UICollectionViewScrollPosition scrollPosition;

//【2.3】【 对于手指滑动 collectionView ,则 = YES 表示需要告诉代理 页面已经切换了；= NO 反之 】。
@property (nonatomic , assign) BOOL isNeedNoticePageChanged;

//【2.4】 与 collectionView 滑动有关
//【2.4.1】滑动 collectionView 时 判断某个view or viewController 是否将要出来
@property (nonatomic , assign) BOOL isWillAppear ;
//【2.4.2】collectionView 将要开始滑动时 记录每次的 初始位置值
@property (nonatomic , assign) CGFloat startLoaction ;
@property (nonatomic , assign) CGFloat startPageLocation ;
//【2.4.3】collectionView 的 (contentOffset.x or contentOffset.y)由 slideDirection 滑动方向决定
@property (nonatomic , assign) CGFloat slideLoaction ;
//【2.4.4】值 = headerView.height - headerViewAlwayShowHeightWhenMoveUp
@property (nonatomic , assign)CGFloat tmpHeaderViewAlwayShowHeightWhenMoveUp ;

//【2.5】collectionView 可以滑动的范围相关 ，类似 contentSize 限制
//【2.5.1】向右 最小可以滑动的位置，默认为 0.0
@property (nonatomic , assign)CGFloat minSlideLocation ;
//【2.5.2】向左 最大可以滑动的位置，默认为 (itemSize.width or itemSize.height)*(childViewsOrViewControllers.count - 1)
@property (nonatomic , assign)CGFloat maxSlideLocation ;


//【2.6】将要消失时 的某个页面（即 刚好开始滑动 时这一刻当前页面就有可能消失，同时另一个页面 将要出现）
@property (nonatomic , weak)id willDisAppearSubViewOrVc ;



/**
 * 【3】subview 引起的 滑动
 * 【3.1】与 subview 对象有关，subview的类型只有是：UIScrollView 、 UIScrollView 子类;
 * 【3.2】如果 UIViewController.view 也添加了 UIScrollView 或 UIScrollView子类 对象，
 以最后添加的该类对象为准
 */
@property (nonatomic , assign)CGFloat preMoveY ;
@property (nonatomic , assign)BOOL isNeedScrollHeaderViewFromGesture;
// 记录 由每个页面的 subview 滑动引起的移动到的 位置字典
@property (nonatomic , strong)NSMutableDictionary * currentMoveYDict ;


// 被监听的对象（监听的是contentOffset属性）
@property (nonatomic , weak) UIScrollView * observerScrollView ;
// 如果某个页面不是 scrollView ，那么就用 UIView 占位
@property (nonatomic , strong) NSMutableArray * subScrollViews ;


@end

#define ZYWeakSelf __weak typeof(self) weakSelf = self

@implementation LTSwitchView
@synthesize preMoveY = _preMoveY ;
@synthesize contentView = _contentView ;
@synthesize currentSubViewOrVc = _currentSubViewOrVc ;
@synthesize childViewsOrViewControllers = _childViewsOrViewControllers ;


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.isWillAppear = YES ;
        self.isNeedScrollHeaderViewFromGesture = YES ;
        self.headerViewSlideEnabled = YES ;
        self.headerViewAlwayShowSettingEffective = YES ;
        self.percentPageSlidCycle = 1.0 ;
        
        self.minSlideLocation = 0 ;
        self.maxSlideLocation = -1 ;
        
        [self addSubview:self.contentView];
    }
    return self ;
}

-(instancetype)initWithChildViewsOrVcs:(NSMutableArray *)childViewsOrVcs
{
    if (self = [self init]) {
        self.childViewsOrViewControllers = childViewsOrVcs ;
    }
    return self ;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self topViewController];
    
    self.contentView.frame = self.bounds ;
    
    self.headerView.frame = self.headerView.bounds ;
    self.contentView.tableHeaderView = self.headerView ;
    self.tmpHeaderViewAlwayShowHeightWhenMoveUp = self.headerView.frame.size.height - self.headerViewAlwayShowHeightWhenMoveUp ;
    
    self.collectionView.frame = CGRectMake(0, 0, self.itemSize.width, self.itemSize.height);
    self.contentView.rowHeight = self.itemSize.height ;
    [self.contentView reloadData];
}

-(void)dealloc
{
    [_headerView removeObserver:self forKeyPath:@"frame"];
    [self.observerScrollView removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1 ;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.childViewsOrViewControllers.count != 0? 1:0 ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [[UITableViewCell alloc] init];
    cell.selectionStyle = UITableViewCellSelectionStyleNone ;
    cell.tag = 10002 ;
    [cell addSubview:self.collectionView];
    
    return cell ;
}



#pragma mark - 子 scrollView 移动 conentOffset 变化
-(void)moveSubScrollViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"=== subScrollViewDidScroll = %f  ,  %f",scrollView.contentOffset.y,self.contentView.contentOffset.y);
    
    if (!self.isNeedScrollHeaderViewFromGesture || !self.headerViewSlideEnabled) {
        return ;
    }
    
    // 1 表示向上，2表示向下
    CGFloat offY = scrollView.contentOffset.y - self.preMoveY  ;
    NSInteger directionUpOrDown = offY > 0 ? 1:2;
    
    if (scrollView.contentOffset.y <= 0){
        
        if (directionUpOrDown == 1 && scrollView.contentOffset.y > self.contentView.contentOffset.y     ) { //
            
            self.contentView.contentOffset = CGPointMake(0, offY + self.contentView.contentOffset.y);
        }
        else if( directionUpOrDown == 2 && scrollView.contentOffset.y < self.contentView.contentOffset.y ){ // 向下滑动，
            if (self.contentView.contentOffset.y > 0) {
                offY *= 1.8 ;
            }
            if (offY + self.contentView.contentOffset.y < self.headerViewAlwayShowLocationWhenMoveDown && self.headerViewAlwayShowSettingEffective) {
                self.contentView.contentOffset = CGPointMake(0, self.headerViewAlwayShowLocationWhenMoveDown);
            }
            else{
                self.contentView.contentOffset = CGPointMake(0, offY + self.contentView.contentOffset.y);
            }
        }
    }
    else if ( (directionUpOrDown == 1 && scrollView.contentOffset.y > self.contentView.contentOffset.y)
             || (directionUpOrDown == 2 && scrollView.contentOffset.y < self.contentView.contentOffset.y) ) {
        self.contentView.contentOffset = CGPointMake(0, offY + self.contentView.contentOffset.y);
    }
    
    self.preMoveY = scrollView.contentOffset.y ;
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.childViewsOrViewControllers.count ;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LTSwitchViewCollectionCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LTSwitchViewCollectionCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"LTSwitchViewCollectionCell" owner:nil options:nil].lastObject;
    }
    
    id viewOrVc = self.childViewsOrViewControllers[indexPath.row];
    cell.viewOrVc = viewOrVc ;
    
    if (![self.needFirstLoadDataViewIndex containsObject:@(indexPath.row)]) {
        [self.needFirstLoadDataViewIndex addObject:@(indexPath.row)];
        [self viewOrVcLoadingDataIfNeed:viewOrVc];
    }
    
    return cell ;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(switchView:didSelectItemAtIndex:)]) {
        [self.delegate switchView:self didSelectItemAtIndex:indexPath.row];
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isNeedNoticePageChanged = YES ;
    self.isWillAppear = YES ;
    self.startLoaction = self.slideLoaction ;
    self.startPageLocation = self.slideLoaction ;
    //    NSLog(@"开始手动滑动 === %f",self.slideLoaction);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.contentView) { // 是contentView在滑动
        [self contentViewDidScrollView:scrollView];
    }
    else{
        [self collectionViewDidScroll:scrollView];
    }
}

-(void)contentViewDidScrollView:(UIScrollView *)scrollView
{
    //   NSLog(@"contentView ----- %f",scrollView.contentOffset.y);
    
    if (self.isHeaderViewAlwayShowSettingEffective) {
        if (scrollView.contentOffset.y > self.tmpHeaderViewAlwayShowHeightWhenMoveUp) {
            scrollView.contentOffset = CGPointMake(0, self.tmpHeaderViewAlwayShowHeightWhenMoveUp);
        }
        else if (scrollView.contentOffset.y < self.headerViewAlwayShowLocationWhenMoveDown){
            scrollView.contentOffset = CGPointMake(0, self.headerViewAlwayShowLocationWhenMoveDown);
        }
    }
    else if (scrollView.contentOffset.y > self.headerView.frame.size.height){
        scrollView.contentOffset = CGPointMake(0, self.headerView.frame.size.height);
    }
}

-(void)collectionViewDidScroll:(UIScrollView *)scrollView
{
    //    NSLog(@"collectionView scrolling ==== %f",scrollView.contentOffset.x);
    // 下面是collection 滑动
    
    if (self.slideLoaction < self.minSlideLocation) {
        if (self.slideDirection == LTSwitchViewSlideDirectionHorizontal) {
            scrollView.contentOffset = CGPointMake(self.minSlideLocation, scrollView.contentOffset.y);
        }
        else{
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, self.minSlideLocation);
        }
        
        return ;
    }
    else if (self.slideLoaction > self.maxSlideLocation){
        if (self.slideDirection == LTSwitchViewSlideDirectionHorizontal) {
            scrollView.contentOffset = CGPointMake(self.maxSlideLocation, scrollView.contentOffset.y);
        }
        else{
            scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, self.maxSlideLocation);
        }
        
        return ;
    }
    
    //    self.isNeedScrollHeaderViewFromGesture = NO ;
    if (scrollView.contentOffset.x == (NSInteger)scrollView.contentOffset.x
        && scrollView.contentOffset.x == self.currentPageIndex * self.itemSize.width) {
        self.isNeedScrollHeaderViewFromGesture = YES ;
        
        [self viewOrVcDidDisAppear];
    }
    
    if (self.isNeedNoticePageChanged == NO ) { // 说明是外面设置了currentPageIndex
        return ;
    }
    
    if (self.isWillAppear && self.startLoaction != self.slideLoaction) {
        self.isWillAppear = NO ;
        
        CGFloat offx = self.slideLoaction - self.startLoaction ;
        id _willShowSubViewOrVc = nil ;
        
        if (offx > 0 && self.currentPageIndex + 1 < self.childViewsOrViewControllers.count) { // 向左滑的
            _willShowSubViewOrVc = self.childViewsOrViewControllers[self.currentPageIndex + 1];
            [self viewOrVcWillAppear:_willShowSubViewOrVc];
        }
        else if (offx < 0 && self.currentPageIndex - 1 >= 0){ // 向右滑的，将要显示的是上一个
            _willShowSubViewOrVc = self.childViewsOrViewControllers[self.currentPageIndex - 1];
            [self viewOrVcWillAppear:_willShowSubViewOrVc];
        }
    }
    
    // 正在滑动的位置告诉代理
    [self viewOrVcPageChanging];
    
    [self dragging:scrollView];
}
-(void)dragging:(UIScrollView *)scrollView
{
    NSInteger pageIndex = 0;
    CGFloat offset = self.slideLoaction - self.startPageLocation ;
    // 向左向下为 1 ，向右向上为 2
    NSInteger direction = offset > 0 ? 1 : 2 ;
    
    if (self.slideDirection == LTSwitchViewSlideDirectionHorizontal) {
        pageIndex = (NSInteger)(self.slideLoaction / self.itemSize.width);
        CGFloat tmpPageSlidCycle = self.itemSize.width * self.percentPageSlidCycle ;
        if (direction == 1 && self.slideLoaction - pageIndex * self.itemSize.width >= tmpPageSlidCycle) {
            pageIndex = pageIndex + 1 ;
        }
        else if (direction == 2 && self.itemSize.width - (self.slideLoaction - pageIndex * self.itemSize.width) < tmpPageSlidCycle) {
            pageIndex = pageIndex + 1 ;
        }
    }
    else{
        pageIndex = (NSInteger)(self.slideLoaction / self.itemSize.height);
        CGFloat tmpPageSlidCycle = self.itemSize.height * self.percentPageSlidCycle ;
        if (direction == 1 && self.slideLoaction - pageIndex * self.itemSize.height >= tmpPageSlidCycle) {
            pageIndex = pageIndex + 1 ;
        }
        else if (direction == 2 && self.itemSize.height - (self.slideLoaction - pageIndex * self.itemSize.height) < tmpPageSlidCycle) {
            pageIndex = pageIndex + 1 ;
        }
    }
    
    if (pageIndex == _currentPageIndex || pageIndex >= self.childViewsOrViewControllers.count ||  pageIndex < 0) {
        return ;
    }
    
    self.startPageLocation = self.slideLoaction ;
    
    _currentPageIndex = pageIndex;
    _currentSubViewOrVc = self.childViewsOrViewControllers[_currentPageIndex];
    
    [self viewOrVcPageChanged];
}


#pragma mark - view or viewController 的6个动作
-(void)viewOrVcLoadingDataIfNeed:(id)viewOrVc
{
    if ([self.delegate respondsToSelector:@selector(switchView:subViewOrVcLoadingDataIfNeed:)]) {
        [self.delegate switchView:self subViewOrVcLoadingDataIfNeed:viewOrVc];
    }
}
-(void)viewOrVcWillAppear:(id)viewOrVc
{
    if ([self.delegate respondsToSelector:@selector(switchView:willAppearSubViewOrVc:)]) {
        [self.delegate switchView:self willAppearSubViewOrVc:viewOrVc];
    }
    
    [self viewOrVcWillDisAppear:self.currentSubViewOrVc];
}
-(void)viewOrVcPageChanging
{
    if (self.canCallPageIndexChanging) {
        CGFloat floatPageIndex = self.slideLoaction / self.maxSlideLocation ;
        if (floatPageIndex > 1.0) {
            floatPageIndex = 1.0 ;
        }
        else if (floatPageIndex < 0){
            floatPageIndex = 0 ;
        }
        
        [self.delegate switchView:self pageIndexChanging:floatPageIndex];
    }
}
-(void)viewOrVcPageChanged
{
    if (self.currentPageIndex < self.subScrollViews.count) {
        self.observerScrollView = self.subScrollViews[self.currentPageIndex];
    }
    
    if (self.canCallPageIndexChanged && self.currentPageIndex < self.childViewsOrViewControllers.count) {
        [self.delegate switchView:self pageIndexChanged:self.currentPageIndex];
    }
}
-(void)viewOrVcWillDisAppear:(id)viewOrVc
{
    self.willDisAppearSubViewOrVc = viewOrVc ;
    if ([self.delegate respondsToSelector:@selector(switchView:willDisAppearSubViewOrVc:)]
        && self.willDisAppearSubViewOrVc) {
        [self.delegate switchView:self willDisAppearSubViewOrVc:self.willDisAppearSubViewOrVc];
    }
}
-(void)viewOrVcDidDisAppear
{
    if (self.willDisAppearSubViewOrVc != self.currentSubViewOrVc) {
        if ([self.delegate respondsToSelector:@selector(switchView:didDisAppearSubViewOrVc:)]
            && self.willDisAppearSubViewOrVc) {
            [self.delegate switchView:self didDisAppearSubViewOrVc:self.willDisAppearSubViewOrVc];
        }
    }
    self.willDisAppearSubViewOrVc = nil ;
}


#pragma mark - 功能模块提取
-(NSArray *)allChildViewsAndViewControllers
{
    if (self.allChildViewsAndViewControllers.count) {
        return [NSArray arrayWithArray:self.allChildViewsAndViewControllers];
    }
    return [NSArray array];
}

-(void)addChildViewsOrVcs:(NSMutableArray *)childViewsOrVcs
{
    [self addChildViewsOrVcsIfNeed:childViewsOrVcs];
}

-(void)addViewOrVc:(id)viewOrVc
{
    [self addViewOrVcIfNeed:viewOrVc needRefreshData:YES];
}

-(void)removeAllViewsAndVcs
{
    [self viewOrVcWillDisAppear:self.currentSubViewOrVc];
    
    [self.needFirstLoadDataViewIndex removeAllObjects];
    [self.childViewsOrViewControllers removeAllObjects];
    [self.subScrollViews removeAllObjects];
    self.observerScrollView = nil ;
    self.currentMoveYDict = nil ;
    
    self.maxSlideLocation = -1 ;
    [self needRefreshDataOfCollectionView];
    
    [self viewOrVcDidDisAppear];
}

-(void)removeViewOrVc:(id)viewOrVc
{
    if (viewOrVc != nil && [self.childViewsOrViewControllers containsObject:viewOrVc]) {
        
        if (self.currentSubViewOrVc == viewOrVc) {
            [self viewOrVcWillDisAppear:self.currentSubViewOrVc];
            self.observerScrollView = nil ;
        }
        
        [self.needFirstLoadDataViewIndex removeObject:@([self.childViewsOrViewControllers indexOfObject:viewOrVc])];
        NSInteger vcIndex = [self.childViewsOrViewControllers indexOfObject:viewOrVc];
        [self.currentMoveYDict removeObjectForKey:[NSString stringWithFormat:@"%ld",vcIndex]];
        [self.childViewsOrViewControllers removeObject:viewOrVc];
        UIView * scrollView = [self getScrollViewWithViewOrVc:viewOrVc];
        [self.subScrollViews removeObject:scrollView];
        
        self.maxSlideLocation = -1 ;
        [self needRefreshDataOfCollectionView];
        
        if (self.currentSubViewOrVc == viewOrVc) {
            [self viewOrVcDidDisAppear];
        }
    }
}

-(void)calculateSlideDirectionWithPageIndex:(NSInteger)nextPageIndex
{
    if (nextPageIndex > _currentPageIndex) {
        self.scrollPosition = self.slideDirection == LTSwitchViewSlideDirectionHorizontal? UICollectionViewScrollPositionLeft : UICollectionViewScrollPositionTop ;
    }
    else if (nextPageIndex < _currentPageIndex){
        self.scrollPosition = self.slideDirection == LTSwitchViewSlideDirectionHorizontal? UICollectionViewScrollPositionRight : UICollectionViewScrollPositionBottom ;
    }
    else{
        self.scrollPosition = UICollectionViewScrollPositionNone ;
    }
}

-(void)slideToPageIndex:(NSInteger)pageIndex animated:(BOOL)animated
{
    if (pageIndex < 0) {
        pageIndex = 0 ;
    }
    
    [self calculateSlideDirectionWithPageIndex:pageIndex];
    
    _currentPageIndex = pageIndex ;
    
    if (self.childViewsOrViewControllers.count > pageIndex) {
        [self setCurrentSubViewOrVc:self.childViewsOrViewControllers[pageIndex]];
    }
    else{
        _currentPageIndex = self.childViewsOrViewControllers.count - 1 ;
        [self setCurrentSubViewOrVc:self.childViewsOrViewControllers.lastObject];
    }
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:pageIndex inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:self.scrollPosition animated:animated];
}



-(void)newCollectionViewFlowLayoutToCollectionView
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.itemSize = self.itemSize;
    layout.minimumLineSpacing = 0 ;
    layout.minimumInteritemSpacing = 0 ;
    layout.scrollDirection = (UICollectionViewScrollDirection)!self.slideDirection;
    
    [self.collectionView setCollectionViewLayout:layout animated:YES];
}

-(UIViewController *)currentViewController {
    for (UIView *next = [self superview]; next; next = next.superview) {
        UIResponder *nextResponser = [next nextResponder];
        if ([nextResponser isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponser;
        }
    }
    return nil;
}

-(BOOL)needAddObjectWithViewOrVc:(id)viewOrVc
{
    if ([viewOrVc isKindOfClass:[UIView class]]) {
        // 选不用管
        return YES ;
    }
    else if ([viewOrVc isKindOfClass:[UIViewController class]]) {
        return YES ;
    }
    else{ // 过滤掉非UIViewController对象、UIViewController子类对象 、UIView对象 和 UIView子类对象
        return NO ;
    }
}

-(void)addViewOrVcIfNeed:(id)viewOrVc needRefreshData:(BOOL)needRefreshData
{
    NSInteger preCount = self.childViewsOrViewControllers.count ;
    
    if ([self needAddObjectWithViewOrVc:viewOrVc]) {
        if ([viewOrVc isKindOfClass:[UIViewController class]]) {
            [self.topViewController addChildViewController:viewOrVc];
        }
        [self.childViewsOrViewControllers addObject:viewOrVc];
        UIView * scrollView = [self getScrollViewWithViewOrVc:viewOrVc];
        if (scrollView) {
            [self.subScrollViews addObject:scrollView];
        }
    }
    
    if (needRefreshData && self.childViewsOrViewControllers.count != preCount) {
        self.maxSlideLocation = -1 ;
        [self needRefreshDataOfCollectionView];
    }
}

-(void)addChildViewsOrVcsIfNeed:(NSMutableArray *)ChildViewsOrVcs
{
    NSInteger preCount = self.childViewsOrViewControllers.count ;
    
    for (id viewOrVc in ChildViewsOrVcs) {
        [self addViewOrVcIfNeed:viewOrVc needRefreshData:NO];
    }
    
    if (self.childViewsOrViewControllers.count != preCount) {
        self.maxSlideLocation = -1 ;
        [self needRefreshDataOfCollectionView];
    }
}

-(void)prepareForRefreshData
{
    CGFloat itemSize = self.itemSize.width ;
    if (self.slideDirection == LTSwitchViewSlideDirectionVertical) {
        itemSize = self.itemSize.height ;
    }
    self.maxSlideLocation = itemSize * (self.childViewsOrViewControllers.count - 1) ;
}

-(void)refreshAllDataOfCollectionView
{
    [self prepareForRefreshData];
    
    [self.collectionView reloadData];
    self.currentPageIndex = self.currentPageIndex ;
}

-(void)needRefreshDataOfCollectionView
{
    [self refreshAllDataOfCollectionView];
}

-(UIView *)getScrollViewWithViewOrVc:(id)viewOrVc
{
    UIView * scrollView = nil ;
    
    if ([viewOrVc isKindOfClass:[UIViewController class]]) {
        
        if ([viewOrVc isKindOfClass:[UITableViewController class]]) {
            scrollView = ((UITableViewController *)viewOrVc).tableView ;
        }
        else if ([viewOrVc isKindOfClass:[UICollectionViewController class]]){
            scrollView = ((UICollectionViewController *)viewOrVc).collectionView ;
        }
        else{
            UIViewController * controller = (UIViewController *)viewOrVc ;
            for (NSInteger index = controller.view.subviews.count -1; index >= 0 ; index--) {
                id subView = controller.view.subviews[index];
                if ([subView isKindOfClass:[UIScrollView class]]) {
                    scrollView = (UIScrollView *)subView ;
                    break ;
                }
            }
            
            if (!scrollView) {
                scrollView = controller.view;
            }
        }
    }
    else if([viewOrVc isKindOfClass:[UIView class]]){
        UIView * view = (UIView *)viewOrVc ;
        if ([view isKindOfClass:[UIScrollView class]]) {
            scrollView = (UIScrollView *)view ;
        }
        
        if (!scrollView) {
            scrollView = view;
        }
    }
    
    return scrollView ;
}


#pragma mark - KVO 监听 headerView.frame
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        CGRect headerFrame = [change[@"new"] CGRectValue];
        if (headerFrame.origin.y != self.headerView.frame.origin.y ||
            headerFrame.size.height != self.headerView.frame.size.height) {
            [self setNeedsLayout];
        }
    }
    else if ([keyPath isEqualToString:@"contentOffset"]){
        [self moveSubScrollViewDidScroll:self.observerScrollView];
    }
}

#pragma mark - setter & getter
-(void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    [self slideToPageIndex:currentPageIndex animated:YES];
}

-(void)setCurrentSubViewOrVc:(id)currentSubViewOrVc
{
    if (currentSubViewOrVc == nil) {
        return ;
    }
    self.isWillAppear = NO ;
    [self viewOrVcWillAppear:currentSubViewOrVc];
    
    _currentSubViewOrVc = currentSubViewOrVc ;
    if (self.currentPageIndex < self.subScrollViews.count) {
        self.observerScrollView = self.subScrollViews[self.currentPageIndex];
    }
    
    self.isNeedNoticePageChanged = NO ;
}

-(void)setChildViewsOrViewControllers:(NSMutableArray *)childViewsOrViewControllers
{
    [self viewOrVcWillDisAppear:self.currentSubViewOrVc];
    
    [self.needFirstLoadDataViewIndex removeAllObjects];
    [self.childViewsOrViewControllers removeAllObjects];
    [self.subScrollViews removeAllObjects];
    self.observerScrollView = nil ;
    self.currentMoveYDict = nil ;
    
    self.maxSlideLocation = -1 ;
    [self viewOrVcDidDisAppear];
    
    [self addChildViewsOrVcsIfNeed:childViewsOrViewControllers];
}

-(void)setMinSlideLocation:(CGFloat)minSlideLocation
{
    _minSlideLocation = minSlideLocation ;
    if (_minSlideLocation < 0) {
        _minSlideLocation = 0 ;
    }
}

-(CGFloat)slideLoaction
{
    if (self.slideDirection == LTSwitchViewSlideDirectionHorizontal) {
        _slideLoaction = self.collectionView.contentOffset.x ;
    }
    else{
        _slideLoaction = self.collectionView.contentOffset.y ;
    }
    
    return _slideLoaction ;
}

-(void)setHeaderView:(UIView *)headerView
{
    if (![headerView isKindOfClass:[UIView class]] && headerView != nil) {
        return ;
    }
    
    if (_headerView != headerView) {
        
        if (_headerView != nil) {
            [_headerView removeObserver:self forKeyPath:@"frame"];
        }
        if (headerView != nil) {
            [headerView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
        }
        
        [_headerView removeFromSuperview];
        _headerView = headerView ;
    }
    
    [self setNeedsLayout];
}

-(void)setHeaderViewSlideEnabled:(BOOL)headerViewSlideEnabled
{
    _headerViewSlideEnabled = headerViewSlideEnabled ;
    self.contentView.scrollEnabled = headerViewSlideEnabled ;
}

-(void)setHeaderViewAlwayShowHeightWhenMoveUp:(CGFloat)headerViewAlwayShowHeightWhenMoveUp
{
    if (headerViewAlwayShowHeightWhenMoveUp < 0) {
        headerViewAlwayShowHeightWhenMoveUp = -headerViewAlwayShowHeightWhenMoveUp ;
    }
    _headerViewAlwayShowHeightWhenMoveUp = headerViewAlwayShowHeightWhenMoveUp ;
    self.tmpHeaderViewAlwayShowHeightWhenMoveUp = self.headerView.frame.size.height - headerViewAlwayShowHeightWhenMoveUp ;
    
    [self.contentView reloadData];
}

-(void)setTmpHeaderViewAlwayShowHeightWhenMoveUp:(CGFloat)tmpHeaderViewAlwayShowHeightWhenMoveUp
{
    if (tmpHeaderViewAlwayShowHeightWhenMoveUp < 0) {
        tmpHeaderViewAlwayShowHeightWhenMoveUp = -tmpHeaderViewAlwayShowHeightWhenMoveUp ;
    }
    _tmpHeaderViewAlwayShowHeightWhenMoveUp = tmpHeaderViewAlwayShowHeightWhenMoveUp ;
}

-(void)setHeaderViewAlwayShowLocationWhenMoveDown:(CGFloat)headerViewAlwayShowLocationWhenMoveDown
{
    if (headerViewAlwayShowLocationWhenMoveDown > 0) {
        headerViewAlwayShowLocationWhenMoveDown = -headerViewAlwayShowLocationWhenMoveDown ;
    }
    _headerViewAlwayShowLocationWhenMoveDown = headerViewAlwayShowLocationWhenMoveDown ;
    [self.contentView reloadData];
}

-(void)setItemSize:(CGSize)itemSize
{
    _itemSize = itemSize ;
    
    [self newCollectionViewFlowLayoutToCollectionView];
    
    [self setNeedsLayout];
}

-(void)setPercentPageSlidCycle:(CGFloat)percentPageSlidCycle
{
    _percentPageSlidCycle = percentPageSlidCycle ;
    
    if (_percentPageSlidCycle < 0.5 ) {
        _percentPageSlidCycle = 0.5 ;
    }
    else if (_percentPageSlidCycle > 1.0){
        _percentPageSlidCycle = 1.0 ;
    }
}

-(void)setSlideDirection:(LTSwitchViewSlideDirection)slideDirection
{
    _slideDirection = slideDirection ;
    
    [self newCollectionViewFlowLayoutToCollectionView];
}


-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = self.itemSize;
        layout.minimumLineSpacing = 0 ;
        layout.minimumInteritemSpacing = 0 ;
        layout.scrollDirection = (UICollectionViewScrollDirection)self.slideDirection;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, 0,0) collectionViewLayout:layout];
        //        _collectionView.contentInset = UIEdgeInsetsMake(0, 0, 49, 0);
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollsToTop = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        // 分页功能
        _collectionView.pagingEnabled = YES ;
        
        [self newCollectionViewFlowLayoutToCollectionView];
        
        [_collectionView registerNib:[UINib nibWithNibName:@"LTSwitchViewCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"LTSwitchViewCollectionCell"];
        
    }
    return _collectionView ;
}

-(NSMutableArray *)needFirstLoadDataViewIndex
{
    if (!_needFirstLoadDataViewIndex) {
        _needFirstLoadDataViewIndex = [NSMutableArray arrayWithCapacity:self.childViewsOrViewControllers.count];
    }
    return _needFirstLoadDataViewIndex ;
}

-(NSMutableArray *)childViewsOrViewControllers
{
    if (!_childViewsOrViewControllers) {
        _childViewsOrViewControllers = [NSMutableArray array];
    }
    return _childViewsOrViewControllers ;
}

-(UIViewController *)topViewController
{
    if (!_topViewController) {
        _topViewController = [self currentViewController];
        
        if (_topViewController != nil) {
            for (id viewOrVc in self.childViewsOrViewControllers) {
                if ([viewOrVc isKindOfClass:[UIViewController class]]) {
                    [_topViewController addChildViewController:viewOrVc];
                }
            }
        }
    }
    return _topViewController ;
}

-(UITableView *)contentView
{
    if (_contentView == nil) {
        _contentView = [[UITableView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.scrollEnabled = NO ;
        _contentView.showsVerticalScrollIndicator = NO ;
        _contentView.showsHorizontalScrollIndicator = NO ;
        _contentView.separatorStyle = UITableViewCellSeparatorStyleNone ;
        _contentView.dataSource = self ;
        _contentView.delegate = self ;
    }
    return _contentView ;
}

-(void)setDelegate:(id<LTSwitchViewDelegate>)delegate
{
    _delegate = delegate ;
    
    if ([_delegate respondsToSelector:@selector(switchView:pageIndexChanging:)]) {
        self.canCallPageIndexChanging = YES ;
    }
    else{
        self.canCallPageIndexChanging = NO ;
    }
    
    if ([_delegate respondsToSelector:@selector(switchView:pageIndexChanged:)]) {
        self.canCallPageIndexChanged = YES ;
    }
    else{
        self.canCallPageIndexChanged = NO ;
    }
    
}

-(void)setPreMoveY:(CGFloat)preMoveY
{
    _preMoveY = preMoveY ;
    [self.currentMoveYDict setObject:@(preMoveY) forKey:[NSString stringWithFormat:@"%ld",self.currentPageIndex]];
}

-(CGFloat)preMoveY
{
    _preMoveY = [[self.currentMoveYDict valueForKey:[NSString stringWithFormat:@"%ld",self.currentPageIndex]] floatValue] ;
    return _preMoveY ;
}

-(NSMutableDictionary *)currentMoveYDict
{
    if (!_currentMoveYDict) {
        _currentMoveYDict = [NSMutableDictionary dictionary];
    }
    return _currentMoveYDict ;
}

-(void)setObserverScrollView:(UIScrollView *)observerScrollView
{
    if ([_observerScrollView isKindOfClass:[UIScrollView class]]) {
        [_observerScrollView removeObserver:self forKeyPath:@"contentOffset"];
        _observerScrollView = nil ;
    }
    
    _observerScrollView = observerScrollView ;
    
    if ([_observerScrollView isKindOfClass:[UIScrollView class]]) {
        [_observerScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        self.preMoveY = _observerScrollView.contentOffset.y ;
    }
}
-(NSMutableArray *)subScrollViews
{
    if (!_subScrollViews) {
        _subScrollViews = [NSMutableArray array];
    }
    return _subScrollViews ;
}
@end
