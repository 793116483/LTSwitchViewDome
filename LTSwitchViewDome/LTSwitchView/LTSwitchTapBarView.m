//
//  LTSwitchTapBarView.m
//  LTSwitchViewDome-页面切换
//
//  Created by 瞿杰 on 2017/4/13.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "LTSwitchTapBarView.h"

@interface LTSwitchTapBarView ()

@property (nonatomic , strong) UIScrollView * scrollView ;
@property (nonatomic , strong) UIView * contentView ;

@property (nonatomic , strong) UIView * topLine ;
@property (nonatomic , strong) UIView * bottomLine ;

@property (nonatomic , strong) UIView * indicatorView ;

@property (nonatomic , weak) UIButton * selectionBtn ;

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
        
        
        _titleColorNormal = UIColorFromRGB(0x666666) ;
        _titleColorSelection = UIColorFromRGB(0x333333) ;
        _titleFontSize = 16.0 ;
        self.reservedAlwaysShowItemWidthMultiple = 2.0 ;
        self.userDraggable = YES ;
        _selectionIndicatorHeight = 2.0 ;
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
    
    self.topLine.frame = CGRectMake(0, 0, self.bounds.size.width, self.topLineHeight);
    
    self.scrollView.frame = CGRectMake(0, self.topLineHeight, self.bounds.size.width, self.bounds.size.height - self.topLineHeight - self.bottomLineHeight);
    self.contentSize = CGSizeMake(_titleItemWidth * self.titleArray.count, self.scrollView.frame.size.height);
    
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height - self.bottomLineHeight, self.bounds.size.width, self.bottomLineHeight);
    
    self.contentView.frame = CGRectMake(0, 0, self.contentSize.width, self.scrollView.frame.size.height - self.selectionIndicatorHeight);

    
    self.indicatorView.frame = CGRectMake(0, self.contentView.frame.size.height, self.selectionIndicatorWidht, self.selectionIndicatorHeight);
    
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

-(void)moveIndicatorWithLocation:(CGFloat)moveIndicatorToLocation
{
    if (!self.shouldAnimateUserSelection) {
        return ;
    }
    CGFloat minMoveToLocation = self.selectionIndicatorWidht / 2.0 ;
    CGFloat maxOffsetLocation = self.scrollView.contentSize.width - self.selectionIndicatorWidht ;
    CGFloat indicatorMoveTo = maxOffsetLocation * moveIndicatorToLocation + minMoveToLocation;
    self.indicatorView.center = CGPointMake(indicatorMoveTo, self.indicatorView.center.y);
    
    self.needMoveIndicator = NO ;
    
//    NSInteger index = indicatorMoveTo / self.titleItemWidth ;
//    self.selectionIndex = index ;
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
    CGFloat indicatorMoveTo = self.titleItemWidth * index + self.titleItemWidth / 2;
    
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
        return ;
    }
    
    if (_titleArray.count <= index) {
        index = _titleArray.count ;
    }
    
    CGFloat currentShowWidth = self.scrollView.contentOffset.x + self.scrollView.frame.size.width  ;
    CGFloat indicatorMoveTo = self.titleItemWidth * index + self.titleItemWidth / 2;
    CGFloat contentOffsetX = self.scrollView.contentOffset.x ;

    // 1左<-；2右->
    NSInteger direction = index < self.selectionIndex ? 1 : 2 ;
    CGFloat reservedAlwaysShowItemWidth = self.titleItemWidth * (self.reservedAlwaysShowItemWidthMultiple + 0.5 ) ;
    
    if (direction == 2) {
        if (currentShowWidth < indicatorMoveTo + reservedAlwaysShowItemWidth) {
            contentOffsetX += (indicatorMoveTo + reservedAlwaysShowItemWidth) - currentShowWidth;
        }
        
        if (contentOffsetX + self.scrollView.frame.size.width > self.contentSize.width) {
            contentOffsetX = self.contentSize.width - self.scrollView.frame.size.width ;
        }
    }
    else{
        if (contentOffsetX > indicatorMoveTo - reservedAlwaysShowItemWidth) {
            contentOffsetX = indicatorMoveTo - reservedAlwaysShowItemWidth ;
        }
        
        if (contentOffsetX < 0) {
            contentOffsetX = 0 ;
        }
    }
    
    if (self.scrollView.contentOffset.x != contentOffsetX) {
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentOffset = CGPointMake(contentOffsetX, 0);
            if (self.isNeedMoveIndicator) {
                [self moveIndicatorToIndex:index];
            }
        }];
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
    
    if (!self.isSetedTitleItemWidth && titleArray.count) {
        _titleItemWidth = self.frame.size.width / titleArray.count ;
        
        if (!self.isSetedSelectionIndicatorWidht) {
            _selectionIndicatorWidht = _titleItemWidth ;
        }
    }
    
    [self setNeedsLayout];
    
}
-(void)setSelectionIndex:(NSInteger)selectionIndex
{
    if (selectionIndex == _selectionIndex) {
        return ;
    }
    
    if (selectionIndex < self.contentView.subviews.count) {
        [self scrollingToIndex:selectionIndex];
        self.selectionBtn = self.contentView.subviews[selectionIndex] ;
      
        self.needMoveIndicator = YES ;
    }
    _selectionIndex = selectionIndex ;
}
-(void)setSelectionBtn:(UIButton *)selectionBtn
{
    _selectionBtn.selected = NO ;
    
    _selectionBtn = selectionBtn ;
    _selectionBtn.selected = YES ;
}
-(void)setMoveIndicatorToLocation:(CGFloat)moveIndicatorToLocation
{
    if (moveIndicatorToLocation < 0 ) {
        moveIndicatorToLocation = 0.0 ;
    }
    else if (moveIndicatorToLocation > 1.0){
        moveIndicatorToLocation = 1.0 ;
    }
    
    _moveIndicatorToLocation = moveIndicatorToLocation ;
    
    [self moveIndicatorWithLocation:moveIndicatorToLocation];
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
