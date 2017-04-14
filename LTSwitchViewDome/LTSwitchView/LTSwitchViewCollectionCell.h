//
//  LTSwitchViewCollectionCell.h
//  LawTea
//
//  Created by 瞿杰 on 2017/4/6.
//
//

#import <UIKit/UIKit.h>


@class LTSwitchViewCollectionCell ;

@protocol LTSwitchViewCollectionCellDelegate <NSObject>

-(void)switchViewCollectionCell:(LTSwitchViewCollectionCell *)cell subScrollViewDidScroll:(UIScrollView *)scrollView ;

@end


@interface LTSwitchViewCollectionCell : UICollectionViewCell

@property (nonatomic , strong)id viewOrVc ;

@property (nonatomic , weak) id<LTSwitchViewCollectionCellDelegate> delegate ;

@end
