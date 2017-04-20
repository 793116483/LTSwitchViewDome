//
//  LTSwitchViewCollectionCell.m
//  LawTea
//
//  Created by 瞿杰 on 2017/4/6.
//
//

#import "LTSwitchViewCollectionCell.h"

@interface LTSwitchViewCollectionCell ()

@end

@implementation LTSwitchViewCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

-(void)setViewOrVc:(id)viewOrVc
{
    if (_viewOrVc == viewOrVc) {
        return ;
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
    }
    else{
        UIView * view = (UIView *)viewOrVc ;
        [self.contentView addSubview:view];
    }
    
    _viewOrVc = viewOrVc ;
    
    [self setNeedsLayout];
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
