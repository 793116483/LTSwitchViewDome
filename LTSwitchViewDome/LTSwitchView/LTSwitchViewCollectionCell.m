//
//  LTSwitchViewCollectionCell.m
//  LawTea
//
//  Created by 瞿杰 on 2017/4/6.
//
//

#import "LTSwitchViewCollectionCell.h"

@interface LTSwitchViewCollectionCell ()

@property (nonatomic , weak) UIScrollView * scrollView ;

@end

@implementation LTSwitchViewCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

-(void)dealloc
{
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

-(void)setViewOrVc:(id)viewOrVc
{
    if (_viewOrVc == viewOrVc) {
        return ;
    }
    
    
    if (self.scrollView) {
        [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
        self.scrollView = nil ;
    }
    
    if ([_viewOrVc isKindOfClass:[UIViewController class]]) {
        UIViewController * controller = (UIViewController *)_viewOrVc ;
        [controller beginAppearanceTransition:NO animated:NO];
        [controller.view removeFromSuperview];
        [controller endAppearanceTransition];
    }
    else{
        UIView * view = (UIView *)_viewOrVc ;
        [view removeFromSuperview];
    }
    
    
    
    if ([viewOrVc isKindOfClass:[UIViewController class]]) {
        UIViewController * controller = (UIViewController *)viewOrVc ;
        [controller beginAppearanceTransition:YES animated:NO];
        [self.contentView addSubview:controller.view];
        [controller endAppearanceTransition];
        
        if ([viewOrVc isKindOfClass:[UITableViewController class]]) {
            self.scrollView = ((UITableViewController *)viewOrVc).tableView ;
        }
        else if ([viewOrVc isKindOfClass:[UICollectionViewController class]]){
            self.scrollView = ((UICollectionViewController *)viewOrVc).collectionView ;
        }
        else{
            for (NSInteger index = controller.view.subviews.count -1; index >= 0 ; index--) {
                id subView = controller.view.subviews[index];
                if ([subView isKindOfClass:[UIScrollView class]]) {
                    self.scrollView = (UIScrollView *)subView ;
                    break ;
                }
            }
        }
    }
    else{
        UIView * view = (UIView *)viewOrVc ;
        [self.contentView addSubview:view];
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            self.scrollView = (UIScrollView *)view ;
        }
    }
    
    _viewOrVc = viewOrVc ;
    if (self.scrollView) {
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    [self setNeedsLayout];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([self.delegate respondsToSelector:@selector(switchViewCollectionCell:subScrollViewDidScroll:)]) {
        [self.delegate switchViewCollectionCell:self subScrollViewDidScroll:self.scrollView];
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    UIView * view = nil ;
    if ([self.viewOrVc isKindOfClass:[UIViewController class]]) {
        UIViewController * vc = (UIViewController *)self.viewOrVc;
        view = vc.view ;
    }
    else{
        view = (UIView *)self.viewOrVc ;
    }
    view.frame = self.bounds ;
    
//    NSLog(@"layoutSubviews ==== %f , height = %f",self.scrollView.contentSize.height,self.scrollView.frame.size.height);
}



@end
