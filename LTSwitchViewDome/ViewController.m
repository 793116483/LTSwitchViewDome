//
//  ViewController.m
//  LTSwitchViewDome-页面切换
//
//  Created by 瞿杰 on 2017/4/12.
//  Copyright © 2017年 yiniu. All rights reserved.
//

#import "ViewController.h"
#import "LTSwitchView.h"
#import "LTSwitchTapBarView.h"

@interface ViewController ()<LTSwitchViewDelegate , UITableViewDelegate,UITableViewDataSource ,LTSwitchTapBarViewDelegate>

@property (nonatomic, strong) LTSwitchTapBarView * switchTapBarView ;
@property (nonatomic, strong) LTSwitchView *switchView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.switchTapBarView];
    
    [self.view addSubview:self.switchView];
    self.switchView.frame = CGRectMake(0, CGRectGetMaxY(self.switchTapBarView.frame)+10, self.view.bounds.size.width, self.view.bounds.size.height);
    
    UITableView * tableView = [[UITableView alloc] init];
    tableView.delegate = self;
    tableView.dataSource = self ;
    [self.switchView addViewOrVcIfNeed:tableView needRefreshData:NO];
    
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = [UIColor redColor];
    [self.switchView addViewOrVcIfNeed:view needRefreshData:NO];
    
    UIView * view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor blueColor];
    [self.switchView addViewOrVcIfNeed:view2 needRefreshData:NO];
    
    UIView * view3 = [[UIView alloc] init];
    view3.backgroundColor = [UIColor redColor];
    [self.switchView addViewOrVcIfNeed:view3 needRefreshData:NO];
    
    UIView * view4 = [[UIView alloc] init];
    view4.backgroundColor = [UIColor blueColor];
    [self.switchView addViewOrVcIfNeed:view4 needRefreshData:NO];
    
    UIView * view5 = [[UIView alloc] init];
    view5.backgroundColor = [UIColor redColor];
    [self.switchView addViewOrVcIfNeed:view5 needRefreshData:NO];
    
    UIView * view6 = [[UIView alloc] init];
    view6.backgroundColor = [UIColor blueColor];
    [self.switchView addViewOrVcIfNeed:view6 needRefreshData:NO];
    
    UIView * view7 = [[UIView alloc] init];
    view7.backgroundColor = [UIColor redColor];
    [self.switchView addViewOrVcIfNeed:view7 needRefreshData:NO];
    
    UIView * view8 = [[UIView alloc] init];
    view8.backgroundColor = [UIColor blueColor];
    [self.switchView addViewOrVcIfNeed:view8 needRefreshData:NO];
    
    UIView * view9 = [[UIView alloc] init];
    view9.backgroundColor = [UIColor redColor];
    [self.switchView addViewOrVcIfNeed:view9 needRefreshData:NO];
    
    
    
    UITableViewController * vc = [[UITableViewController alloc] init];
    vc.view.backgroundColor = [UIColor brownColor];
    [self.switchView addViewOrVcIfNeed:vc needRefreshData:YES];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2 ;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    if (!cell) {
        cell =     [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableViewCell"];
    }
    
    if (indexPath.row % 2) {
        cell.backgroundColor = [UIColor grayColor];
    }
    else{
        cell.backgroundColor = [UIColor redColor];
    }
    
    return cell ;
}


#pragma mark - LTSwitchTapBarViewDelegate
-(void)switchTapBarView:(LTSwitchTapBarView *)tapBarView selectionIndex:(NSInteger)index
{
    self.switchView.currentPageIndex = index ;
}

#pragma mark - LTViewColloerSwitchViewDelegate
-(void)switchView:(LTSwitchView *)switchView pageIndexChanged:(NSInteger)currentPageIndex
{
    NSLog(@"=============== 选中了 %@ 对象 , 下标 = %ld",NSStringFromClass([switchView.currentSubViewOrVc class]),currentPageIndex);
    
    self.switchTapBarView.selectionIndex = currentPageIndex ;
}
-(void)switchView:(LTSwitchView *)switchView subViewOrVcLoadingDataIfNeed:(id)subViewOrVc
{
    NSLog(@"===============加载数据: 没有使用过 %@ 对象,需要加载数据",NSStringFromClass([subViewOrVc class]));
}
-(void)switchView:(LTSwitchView *)switchView pageIndexChanging:(CGFloat)floatPageIndex
{
    NSLog(@"===============移动位置: 移动到的位置占总的可以移动的距离为 %f%%",floatPageIndex*100);
    self.switchTapBarView.moveIndicatorProgress = floatPageIndex ;
}
-(void)switchView:(LTSwitchView *)switchView willAppearSubViewOrVc:(id)subViewOrVc
{
    NSLog(@"===============将要出现: %@ 对象，将要出现",NSStringFromClass([subViewOrVc class]));
}
-(void)switchView:(LTSwitchView *)switchView willDisAppearSubViewOrVc:(id)subViewOrVc
{
    NSLog(@"===============将要消失: %@ 对象，将要消失",NSStringFromClass([subViewOrVc class]));
}
-(void)switchView:(LTSwitchView *)switchView didDisAppearSubViewOrVc:(id)subViewOrVc
{
    NSLog(@"===============已经消失: %@ 对象，已经消失",NSStringFromClass([subViewOrVc class]));
}

-(LTSwitchTapBarView *)switchTapBarView
{
    if (!_switchTapBarView) {
        _switchTapBarView = [[LTSwitchTapBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _switchTapBarView.center = CGPointMake(self.view.center.x, 80);
        _switchTapBarView.titleArray = @[@"页面1",@"页面2",@"页面3",@"页面4",@"页面5",@"页面6",@"页面7",@"页面8",@"页面9",@"页面10",@"页面11"];
        _switchTapBarView.titleItemWidth = 80 ;
        _switchTapBarView.selectionIndicatorWidht = 40 ;
        _switchTapBarView.delegate = self ;
        _switchTapBarView.selectionIndicatorColor = [UIColor redColor];
        _switchTapBarView.titleColorSelection = [UIColor redColor];
//        _switchTapBarView.shouldAnimateUserSelection = NO ;
//        _switchTapBarView.reservedAlwaysShowItemWidthMultiple = 1 ;
//        _switchTapBarView.userDraggable = NO ;
//        _switchTapBarView.bottomLineHeight = 10.0 ;
    }
    
    return _switchTapBarView ;
}

-(LTSwitchView *)switchView
{
    if (!_switchView) {
        _switchView = [[LTSwitchView alloc] init];
        _switchView.delegate = self ;
        _switchView.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height) ;
        
        // 内容滑动的方向
        //        _switchView.slideDirection = LTSwitchViewSlideDirectionVertical ;
        
        // 每个页面切换周期比例
//        _switchView.percentPageSlidCycle = 1.0 ;
        
        // 头部设置
        _switchView.headerView = [[UIView alloc] initWithFrame:CGRectMake(100, 100, self.view.bounds.size.width, 200)];
        _switchView.headerView.backgroundColor = [UIColor blackColor];
        //        _switchView.headerViewSlideEnabled = NO ;
        //        _switchView.headerViewAlwayShowSettingEffective = NO ;
        _switchView.headerViewAlwayShowHeightWhenMoveUp = 60 ;
        //        _switchView.headerViewAlwayShowLocationWhenMoveDown = -60;
        //        _switchView.itemSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height - _switchView.headerViewAlwayShowHeightWhenMoveUp) ;
    }
    return _switchView ;
}

@end
