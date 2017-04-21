//
//  LTSwitchTapBarView.m
//  LTSwitchViewDome-页面切换
//
//  Created by 瞿杰 on 2017/4/13.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "LTSwitchTapBarView.h"
#import "UIColor+Switch_RGBA_UIColor.h"


@interface LTSwitchTapBarView ()

@property (nonatomic , strong) UIScrollView * scrollView ;
@property (nonatomic , strong) UIView * contentView ;

@property (nonatomic , strong) UIView * topLine ;
@property (nonatomic , strong) UIView * bottomLine ;

@property (nonatomic , strong) UIView * indicatorView ;

@property (nonatomic , weak) UIButton * selectionBtn ;

@property (nonatomic , assign) CGFloat startProgress ;

@property (nonatomic , getter=isNeedMoveIndicator) BOOL needMoveIndicator ;

@property (nonatomic , getter=isSetedTitleItemWidth) BOOL setedTitleItemWidth ;
@property (nonatomic , getter=isSetedSelectionIndicatorWidht) BOOL setedSelectionIndicatorWidht ;


@end

@implementation LTSwitchTapBarView
//@synthesize selectionIndex = _selectionIndex ;

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self addSubview:self.topLine];
        [self addSubview:self.bottomLine];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.contentView];
        [self.scrollView addSubview:self.indicatorView];
        
        self.transitionTitleColorEnabled = YES ;
        self.indicatorStretchEnabled = YES ;
        _percentPageSlidCycle = 1.0 ;
        _titleColorNormal = UIColorFromRGB(0x666666) ;
        _titleColorSelection = UIColorFromRGB(0x333333) ;
        _titleFontSize = 16.0 ;
        self.reservedAlwaysShowItemWidthMultiple = 2.0 ;
        self.userDraggable = YES ;
        _selectionIndicatorHeight = 2.5 ;
        self.selectionIndicatorColor = UIColorFromRGB(0x333333) ;
        self.shouldAnimateUserSelection = YES ;
        self.topLineColor = UIColorFromRGB(0xdddddd) ;
        _topLineHeight = 0.5 ;
        self.bottomLineColor = UIColorFromRGB(0xdddddd) ;
        _bottomLineHeight = 0.5 ;
        
        self.needMoveIndicator = YES ;
    }
    return self ;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.isSetedTitleItemWidth && self.titleArray.count) {
        _titleItemWidth = self.frame.size.width / self.titleArray.count ;
        if (!self.isSetedSelectionIndicatorWidht) {
            _selectionIndicatorWidht = _titleItemWidth ;
        }
    }
    
    self.topLine.frame = CGRectMake(0, 0, self.bounds.size.width, self.topLineHeight);
    
    self.scrollView.frame = CGRectMake(0, self.topLineHeight, self.bounds.size.width, self.bounds.size.height - self.topLineHeight - self.bottomLineHeight);
    self.contentSize = CGSizeMake(_titleItemWidth * self.titleArray.count, self.scrollView.frame.size.height);
    
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height - self.bottomLineHeight, self.bounds.size.width, self.bottomLineHeight);
    
    self.contentView.frame = CGRectMake(0, 0, self.contentSize.width, self.scrollView.frame.size.height - self.selectionIndicatorHeight);
    
    
    self.indicatorView.frame = CGRectMake(0, self.contentView.frame.size.height, self.selectionIndicatorWidht, self.selectionIndicatorHeight);
    CGFloat centerX = self.titleItemWidth * self.selectionIndex + self.titleItemWidth / 2;
    self.indicatorView.center = CGPointMake(centerX, self.indicatorView.center.y);
    
    [self setupTitleButtonsSomeProperty];
    
}


#pragma mark - 功能模块
-(void)setupTitleButtonsSomeProperty
{
    CGFloat width = self.titleItemWidth , height = self.contentView.bounds.size.height;
    CGFloat x = 0 ;
    
    for (UIButton * btn in self.contentView.subviews) {
        
        btn.frame = CGRectMake(x, 0, width, height);
        x += width ;
        
        btn.titleLabel.font = [UIFont systemFontOfSize:self.titleFontSize];
        [btn setTitleColor:self.titleColorNormal forState:UIControlStateNormal];
        [btn setTitleColor:self.titleColorNormal forState:UIControlStateHighlighted];
        [btn setTitleColor:self.titleColorSelection forState:UIControlStateSelected];
    }
}

-(UIColor *)transitionTitleColorWithColorChangeScale:(CGFloat)colorChangeScale
{
    NSArray * RGBAValuesNormal = [UIColor switchCurrentUIColorToRGBA:self.titleColorNormal];
    NSArray * RGBAValuesSelection = [UIColor switchCurrentUIColorToRGBA:self.titleColorSelection];
    
    CGFloat offRed = ([RGBAValuesSelection[0] floatValue] - [RGBAValuesNormal[0] floatValue]) * colorChangeScale ;
    CGFloat offGreen = ([RGBAValuesSelection[1] floatValue] - [RGBAValuesNormal[1] floatValue]) * colorChangeScale ;
    CGFloat offBlue = ([RGBAValuesSelection[2] floatValue] - [RGBAValuesNormal[2] floatValue]) * colorChangeScale ;
    CGFloat offAlpha = ([RGBAValuesSelection[3] floatValue] - [RGBAValuesNormal[3] floatValue]) * colorChangeScale ;
    
    
    CGFloat red = [RGBAValuesNormal[0] floatValue] + offRed ;
    CGFloat green = [RGBAValuesNormal[1] floatValue] + offGreen ;
    CGFloat blue = [RGBAValuesNormal[2] floatValue] + offBlue ;
    CGFloat alpha = [RGBAValuesNormal[3] floatValue] + offAlpha ;
    
    UIColor * resultColor = [UIColor switchRGBAToUIColor:@[@(red) , @(green) , @(blue) , @(alpha)]];
    
    return resultColor ;
}

-(void)transitionTitleColorProgress:(CGFloat)progress
{
    CGFloat maxOffsetLocation = self.scrollView.contentSize.width - self.titleItemWidth ;
    CGFloat offset = maxOffsetLocation * ( progress - self.startProgress ) ;
    // 向左滑动为 1 ，向右滑动为 2
    NSInteger direction = offset > 0 ? 1 : 2 ;
    offset = offset >= 0 ? offset : -offset ;
    CGFloat moveIndicatorLocation = self.selectionBtn.center.x ;
    CGFloat tmpPageSlidCycle = self.titleItemWidth * self.percentPageSlidCycle ;
    NSInteger pageIndex = (NSInteger)(moveIndicatorLocation / tmpPageSlidCycle) ;
    
    
    if (pageIndex == self.selectionIndex && offset) {
        
        CGFloat colorChangeScale = offset / tmpPageSlidCycle ;
        
        UIColor * nextBtnColor = [self transitionTitleColorWithColorChangeScale:colorChangeScale];
        UIColor * currentBtnColor = [self transitionTitleColorWithColorChangeScale:1- colorChangeScale];
        
        [self.selectionBtn setTitleColor:currentBtnColor forState:UIControlStateSelected];
        UIButton * btn = nil ;
        if (direction == 1 && self.contentView.subviews.count > pageIndex + 1) {
            btn = self.contentView.subviews[pageIndex + 1];
        }
        else if (direction == 2 && pageIndex - 1 >= 0){
            btn = self.contentView.subviews[pageIndex - 1];
        }
        
        if (btn) {
            [btn setTitleColor:nextBtnColor forState:UIControlStateNormal];
        }
    }
}

-(void)changeIndicatorWidthWithProgress:(CGFloat)progress
{
    CGFloat offsetWidth = ( self.titleItemWidth - self.selectionIndicatorWidht ) / 2.0 ;
    CGFloat maxOffsetLocation = self.scrollView.contentSize.width - self.titleItemWidth ;
    
    CGFloat unit = 1.0 / (self.titleArray.count - 1) ;
    CGFloat offsetProgress =  progress - self.startProgress ;
    // 向左滑动为 1 ，向右滑动为 2
    NSInteger direction = offsetProgress > 0 ? 1 : 2 ;
    offsetProgress = offsetProgress >= 0 ? offsetProgress : -offsetProgress ;
    CGFloat percent = offsetProgress / unit  ,  tmpPercent;
    // 总共需要增加的宽度
    CGFloat sumAddWidth = self.titleItemWidth - self.selectionIndicatorWidht ;
    CGFloat indicatorX , indicatorWidth ;
    
    if (direction == 1) {
        
        CGFloat startIndicatorX = maxOffsetLocation * self.startProgress + offsetWidth ;
        
        if (percent <= 0.5) {
            tmpPercent = percent / 0.5 ;
            indicatorWidth = self.selectionIndicatorWidht + sumAddWidth * tmpPercent ;
            indicatorX = startIndicatorX + self.selectionIndicatorWidht * 0.5 * tmpPercent ;
        }
        else{
            tmpPercent = ( percent - 0.5 ) / 0.5 ;
            indicatorWidth = self.titleItemWidth - sumAddWidth * tmpPercent ;
            indicatorX = startIndicatorX + self.selectionIndicatorWidht * 0.5 + ( self.titleItemWidth - self.selectionIndicatorWidht * 0.5 ) * tmpPercent ;
        }
    }
    else{
        
        CGFloat startIndicatorMaxX = maxOffsetLocation * self.startProgress + offsetWidth + self.selectionIndicatorWidht ;
        
        if (percent <= 0.5) {
            tmpPercent = percent / 0.5 ;
            indicatorWidth = self.selectionIndicatorWidht + sumAddWidth * tmpPercent ;
            indicatorX = startIndicatorMaxX - self.selectionIndicatorWidht * 0.5 * tmpPercent ;
        }
        else{
            tmpPercent = ( percent - 0.5 ) / 0.5 ;
            indicatorWidth = self.titleItemWidth - sumAddWidth * tmpPercent ;
            indicatorX = startIndicatorMaxX - self.selectionIndicatorWidht * 0.5 - ( self.titleItemWidth - self.selectionIndicatorWidht * 0.5 ) * tmpPercent ;
        }
        
        indicatorX = indicatorX - indicatorWidth ;
    }
    
    self.indicatorView.frame = CGRectMake(indicatorX , self.indicatorView.frame.origin.y, indicatorWidth, self.indicatorView.frame.size.height);
}

-(void)moveIndicatorWithProgress:(CGFloat)moveIndicatorProgress
{
    if (!self.shouldAnimateUserSelection || self.titleArray.count <= 1) {
        return ;
    }
    
    self.needMoveIndicator = NO ;
    
    if (self.isTransitionTitleColorEnabled) {
        [self transitionTitleColorProgress:moveIndicatorProgress];
    }
    
    if (self.titleItemWidth > self.selectionIndicatorWidht && self.isIndicatorStretchEnabled) {
        [self changeIndicatorWidthWithProgress:moveIndicatorProgress];
    }
    else{
        CGFloat minMoveToLocation = self.titleItemWidth / 2.0 ;
        CGFloat maxOffsetLocation = self.scrollView.contentSize.width - self.titleItemWidth ;
        CGFloat indicatorMoveTo = maxOffsetLocation * moveIndicatorProgress + minMoveToLocation;
        
        self.indicatorView.center = CGPointMake(indicatorMoveTo, self.indicatorView.center.y);
    }
}

-(void)clickedBtn:(UIButton *)btn
{
    if (btn == self.selectionBtn) {
        return ;
    }
    
    self.needMoveIndicator = YES ;
    self.selectionIndex = btn.tag ;
    
    if ([self.delegate respondsToSelector:@selector(switchTapBarView:selectionIndex:)]) {
        [self.delegate switchTapBarView:self selectionIndex:btn.tag];
    }
}

-(void)moveIndicatorToIndex:(NSInteger)index
{
    if (index >= self.contentView.subviews.count) {
        return ;
    }
    UIView * btn = self.contentView.subviews[index];
    CGFloat indicatorMoveTo = btn.center.x ;
    
    if (self.isShouldAnimateUserSelection) {
        [UIView animateWithDuration:0.25 animations:^{
            self.indicatorView.center = CGPointMake(indicatorMoveTo, self.indicatorView.center.y);
        }];
    }
    else{
        self.indicatorView.center = CGPointMake(indicatorMoveTo, self.indicatorView.center.y);
    }
}

-(void)scrollingToIndex:(NSInteger)index
{
    if (!self.userDraggable) {
        if (self.isNeedMoveIndicator) {
            [self moveIndicatorToIndex:index];
        }
        return ;
    }
    
    if (_titleArray.count <= index) {
        index = _titleArray.count - 1 ;
    }
    
    CGFloat currentShowWidth = self.scrollView.contentOffset.x + self.scrollView.frame.size.width  ;
    CGFloat indicatorMoveTo = self.titleItemWidth * index + self.titleItemWidth / 2;
    CGFloat contentOffsetX = self.scrollView.contentOffset.x ;
    
    // 1左<-；2右->
    NSInteger direction = index < self.selectionIndex ? 1 : 2 ;
    CGFloat reservedAlwaysShowItemWidth = self.titleItemWidth * (self.reservedAlwaysShowItemWidthMultiple + 0.5 ) ;
    
    if (direction == 2) {
        contentOffsetX += (indicatorMoveTo + reservedAlwaysShowItemWidth) - currentShowWidth;
    }
    else{
        contentOffsetX = indicatorMoveTo - reservedAlwaysShowItemWidth ;
    }
    
    if (contentOffsetX < 0) {
        contentOffsetX = 0 ;
    }
    else if (contentOffsetX + self.scrollView.frame.size.width > self.contentSize.width) {
        contentOffsetX = self.contentSize.width - self.scrollView.frame.size.width ;
    }
    
    if (self.scrollView.contentOffset.x != contentOffsetX) {
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentOffset = CGPointMake(contentOffsetX, 0);
        }];
        if (self.isNeedMoveIndicator) {
            [self moveIndicatorToIndex:index];
        }
    }
    else if (self.isNeedMoveIndicator){
        [self moveIndicatorToIndex:index];
    }
}

#pragma mark - view getter 方法
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsHorizontalScrollIndicator = NO ;
        _scrollView.showsVerticalScrollIndicator = NO ;
    }
    return _scrollView ;
}
-(UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _contentView ;
}
-(UIView *)topLine
{
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
    }
    return _topLine ;
}
-(UIView *)bottomLine
{
    if (!_bottomLine) {
        _bottomLine = [[UIView alloc] init];
    }
    return _bottomLine ;
}
-(UIView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIView alloc] init];
    }
    return _indicatorView ;
}

#pragma mark - 外部属性 setter 方法

-(void)setTitleArray:(NSArray<NSString *> *)titleArray
{
    _titleArray = titleArray ;
    
    for (UIView * btn in self.contentView.subviews) {
        [btn removeFromSuperview];
    }
    
    NSInteger index = 0 ;
    for (NSString * title in _titleArray) {
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = index++ ;
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateHighlighted];
        [btn setTitle:title forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:btn];
        
        if (index - 1 == self.selectionIndex) {
            self.selectionBtn = btn ;
            self.selectionBtn.selected =YES ;
        }
    }
    
    [self setNeedsLayout];
    
}
-(void)setSelectionIndex:(NSInteger)selectionIndex
{
    if (selectionIndex == _selectionIndex) {
        return ;
    }
    if (selectionIndex < 0) {
        selectionIndex = 0 ;
    }
    
    if (selectionIndex < self.contentView.subviews.count) {
        [self scrollingToIndex:selectionIndex];
        self.selectionBtn = self.contentView.subviews[selectionIndex] ;
        
        self.needMoveIndicator = YES ;
    }
    _selectionIndex = selectionIndex ;
    
    if (self.titleArray.count > 1) {
        self.startProgress = 1.0/(self.titleArray.count - 1) * selectionIndex ;
    }
    else{
        self.startProgress = 0 ;
    }
}
-(void)setSelectionBtn:(UIButton *)selectionBtn
{
    [_selectionBtn setTitleColor:self.titleColorNormal forState:UIControlStateNormal];
    [_selectionBtn setTitleColor:self.titleColorNormal forState:UIControlStateHighlighted];
    [_selectionBtn setTitleColor:self.titleColorSelection forState:UIControlStateSelected];
    _selectionBtn.selected = NO ;
    
    [selectionBtn setTitleColor:self.titleColorNormal forState:UIControlStateNormal];
    [selectionBtn setTitleColor:self.titleColorNormal forState:UIControlStateHighlighted];
    [selectionBtn setTitleColor:self.titleColorSelection forState:UIControlStateSelected];
    _selectionBtn = selectionBtn ;
    _selectionBtn.selected = YES ;
}
-(void)setMoveIndicatorProgress:(CGFloat)moveIndicatorProgress
{
    if (moveIndicatorProgress < 0 ) {
        moveIndicatorProgress = 0.0 ;
    }
    else if (moveIndicatorProgress > 1.0){
        moveIndicatorProgress = 1.0 ;
    }
    
    _moveIndicatorProgress = moveIndicatorProgress ;
    
    [self moveIndicatorWithProgress:moveIndicatorProgress];
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
-(void)setTitleColorNormal:(UIColor *)titleColorNormal
{
    _titleColorNormal = titleColorNormal ;
    
    [self setupTitleButtonsSomeProperty];
}
-(void)setTitleColorSelection:(UIColor *)titleColorSelection
{
    _titleColorSelection = titleColorSelection ;
    
    [self setupTitleButtonsSomeProperty];
}
-(void)setTitleItemWidth:(CGFloat)titleItemWidth
{
    _titleItemWidth = titleItemWidth ;
    
    self.setedTitleItemWidth = YES ;
    if (!self.isSetedSelectionIndicatorWidht) {
        _selectionIndicatorWidht = titleItemWidth ;
    }
    
    [self setNeedsLayout];
}
-(void)setTitleFontSize:(CGFloat)titleFontSize
{
    _titleFontSize = titleFontSize ;
    
    [self setupTitleButtonsSomeProperty];
}
-(void)setReservedAlwaysShowItemWidthMultiple:(CGFloat)reservedAlwaysShowItemWidthMultiple
{
    if (reservedAlwaysShowItemWidthMultiple < 0) {
        reservedAlwaysShowItemWidthMultiple = - reservedAlwaysShowItemWidthMultiple ;
    }
    _reservedAlwaysShowItemWidthMultiple = reservedAlwaysShowItemWidthMultiple ;
}
-(void)setUserDraggable:(BOOL)userDraggable
{
    _userDraggable = userDraggable ;
    self.scrollView.scrollEnabled = userDraggable ;
}
-(void)setContentSize:(CGSize)contentSize
{
    _contentSize = contentSize ;
    
    self.scrollView.contentSize = contentSize ;
}
-(void)setSelectionIndicatorHeight:(CGFloat)selectionIndicatorHeight
{
    _selectionIndicatorHeight = selectionIndicatorHeight ;
    
    [self setNeedsLayout];
}
-(void)setSelectionIndicatorWidht:(CGFloat)selectionIndicatorWidht
{
    _selectionIndicatorWidht = selectionIndicatorWidht ;
    self.setedSelectionIndicatorWidht = YES ;
    self.indicatorView.bounds = CGRectMake(0, 0, selectionIndicatorWidht, self.selectionIndicatorHeight);
}
-(void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor
{
    _selectionIndicatorColor = selectionIndicatorColor ;
    
    self.indicatorView.backgroundColor = selectionIndicatorColor ;
}
-(void)setTopLineColor:(UIColor *)topLineColor
{
    _topLineColor = topLineColor ;
    self.topLine.backgroundColor = topLineColor ;
}
-(void)setTopLineHeight:(CGFloat)topLineHeight
{
    _topLineHeight = topLineHeight ;
    
    [self setNeedsLayout];
}
-(void)setBottomLineColor:(UIColor *)bottomLineColor
{
    _bottomLineColor = bottomLineColor ;
    self.bottomLine.backgroundColor = bottomLineColor ;
}
-(void)setBottomLineHeight:(CGFloat)bottomLineHeight
{
    _bottomLineHeight = bottomLineHeight ;
    [self setNeedsLayout];
}

@end
