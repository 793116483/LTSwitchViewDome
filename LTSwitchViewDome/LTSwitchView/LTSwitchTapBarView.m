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

@property (nonatomic , getter=isSetedContentSize) BOOL setedContentSize ;
@property (nonatomic , getter=isSetedTitleItemWidth) BOOL setedTitleItemWidth ;


@end

@implementation LTSwitchTapBarView

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
        self.userDraggable = YES ;
        _selectionIndicatorHeight = 2.0 ;
        self.selectionIndicatorWidht = 8.0 ;
        self.selectionIndicatorColor = UIColorFromRGB(0x333333) ;
//        self.shouldAnimateUserSelection = YES ;
        self.topLineColor = UIColorFromRGB(0xeeeeee) ;
        _topLineHeight = 0.5 ;
        self.bottomLineColor = UIColorFromRGB(0xeeeeee) ;
        _bottomLineHeight = 0.5 ;
        
    }
    return self ;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.topLine.frame = CGRectMake(0, 0, self.bounds.size.width, self.topLineHeight);
    
    self.scrollView.frame = CGRectMake(0, self.topLineHeight, self.bounds.size.width, self.bounds.size.height - self.topLineHeight - self.bottomLineHeight);
    self.scrollView.contentSize = self.contentSize ;
    
    self.contentView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height - self.selectionIndicatorHeight);
    
    self.indicatorView.frame = CGRectMake(0, self.scrollView.frame.size.height - self.selectionIndicatorHeight, self.selectionIndicatorWidht, self.selectionIndicatorHeight);
    
    [self setupTitleButtonsSomeProperty];
    
    self.bottomLine.frame = CGRectMake(0, 0, self.bounds.size.width, self.bottomLineHeight);
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
    CGFloat canMoveWidht = self.scrollView.frame.size.width - self.selectionIndicatorWidht ;
    CGFloat moveTo = canMoveWidht * moveIndicatorToLocation ;
    CGFloat currentShowWidth = self.scrollView.contentOffset.x + self.scrollView.frame.size.width  ;
    if (moveTo > currentShowWidth - self.titleItemWidth) {
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentOffset = CGPointMake(moveTo+self.titleItemWidth, 0);
            self.indicatorView.center = CGPointMake(moveTo, self.indicatorView.center.y);
        }];
    }
    else{
        [UIView animateWithDuration:0.25 animations:^{
            self.indicatorView.center = CGPointMake(moveTo, self.indicatorView.center.y);
        }];
    }
}

-(void)clickedBtn:(UIButton *)btn
{
    if (btn == self.selectionBtn) {
        return ;
    }
    
    self.selectionBtn.selected = NO ;
    
    if ([self.delegate respondsToSelector:@selector(switchTapBarView:selectionIndex:)]) {
        [self.delegate switchTapBarView:self selectionIndex:btn.tag];
    }
    
    self.selectionBtn = btn ;
    [self moveIndicatorTopIndex:btn.tag];
}

-(void)moveIndicatorTopIndex:(NSInteger)index
{
    if (_titleArray.count <= index) {
        index = _titleArray.count ;
    }
    
    
    NSInteger nextIndex = 1 ;
    if (self.titleItemWidth) {
        nextIndex = (self.scrollView.contentOffset.x + self.scrollView.frame.size.width - self.titleItemWidth ) / self.titleItemWidth ;
        nextIndex = nextIndex >0 ? nextIndex : 0 ;
    }
    if (nextIndex < index) {
        [UIView animateWithDuration:0.25 animations:^{
            self.scrollView.contentOffset = CGPointMake((index + 1)*self.titleItemWidth , 0);
        }];
    }
    
    CGFloat x = index * self.titleItemWidth - self.titleItemWidth / 2;
    [UIView animateWithDuration:0.25 animations:^{
        self.indicatorView.center = CGPointMake(x, self.indicatorView.center.y);
    }completion:^(BOOL finished) {
        self.selectionBtn.selected = YES ;
    }];
}

#pragma mark - view getter 方法
-(UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = [UIColor clearColor];
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
    }
    if (!self.isSetedContentSize && titleArray.count) {
        _contentSize = CGSizeMake(_titleItemWidth * titleArray.count, self.scrollView.frame.size.height);
    }
    
    [self setNeedsLayout];
    
    
}
-(void)setSelectionIndex:(NSInteger)selectionIndex
{
    if (selectionIndex == _selectionIndex) {
        return ;
    }
    
    self.selectionBtn.selected = NO ;
    _selectionIndex = selectionIndex ;

    if (selectionIndex < self.contentView.subviews.count) {
        self.selectionBtn = self.contentView.subviews[selectionIndex] ;
        [self moveIndicatorTopIndex:selectionIndex];
    }
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
    
    [self setNeedsLayout];
}
-(void)setTitleFontSize:(CGFloat)titleFontSize
{
    _titleFontSize = titleFontSize ;
    
    [self setupTitleButtonsSomeProperty];
}
-(void)setUserDraggable:(BOOL)userDraggable
{
    _userDraggable = userDraggable ;
    self.scrollView.scrollEnabled = userDraggable ;
}
-(void)setContentSize:(CGSize)contentSize
{
    _contentSize = contentSize ;
    self.setedContentSize = YES ;
    
    self.scrollView.contentSize = contentSize ;
}
-(void)setSelectionIndicatorHeight:(CGFloat)selectionIndicatorHeight
{
    _selectionIndicatorHeight = selectionIndicatorHeight ;
    
    [self setNeedsLayout];
}
-(void)setSelectionIndicatorWidht:(CGFloat)selectionIndicatorWidht
{
    _selectionIndicatorHeight = selectionIndicatorWidht ;
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
