//
//  UIViewController+scrollMeau.m
//  CoreNavVC
//
//  Created by 冯成林 on 15/12/23.
//  Copyright © 2015年 冯成林. All rights reserved.
//

#import "UIViewController+scrollNavbar.h"
#import "UINavigationController+Plus.h"
#import "CoreNavVC.h"
#import "CategoryProperty+CoreNavVC.h"

@interface UIViewController (scrollNavbar)

@property (nonatomic,copy) NSNumber *topViewOriginHeight, *autoToggleNavbarHeight;

@end


static NSString const *ScrollViewKeyPath_CoreNavVC = @"contentOffset";

@implementation UIViewController (scrollNavbar)


ADD_DYNAMIC_PROPERTY(NSNumber *, topViewOriginHeight, setTopViewOriginHeight)
ADD_DYNAMIC_PROPERTY(NSNumber *, autoToggleNavbarHeight, setAutoToggleNavbarHeight)

static const char CoreNavTopViewKey = '\0';
-(void)setTopView:(UIView *)topView {

    if(topView != self.topView){
        
        [self willChangeValueForKey:@"CoreNavTopViewKey"]; // KVO
        
        objc_setAssociatedObject(self, &CoreNavTopViewKey,
                                 topView, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"CoreNavTopViewKey"]; // KVO
    }
}

-(UIView *)topView{
    return objc_getAssociatedObject(self, &CoreNavTopViewKey);
}



static const char PopViewKey = '\0';

-(void)setPopView:(UIView *)popView{

    if(popView != self.popView){

        [self willChangeValueForKey:@"PopViewKey"]; // KVO
        
        objc_setAssociatedObject(self, &PopViewKey,
                                 popView, OBJC_ASSOCIATION_ASSIGN);
        [self didChangeValueForKey:@"PopViewKey"]; // KVO
    }
}

-(UIView *)popView{
    return objc_getAssociatedObject(self, &PopViewKey);
}


/** 展示一个PopView */
-(void)showPopView:(UIView *)view{
    
    if(self.popView != nil) return;
    
    //创建一个PopView
    VCPopView *popView = [VCPopView popView];
    
    CGFloat wh = 35;
    CGFloat x = 4.5;
    CGFloat y = 23.8;
    if([UIScreen mainScreen].bounds.size.width > 375) {x = 8; y = 24.5;};
    popView.frame = CGRectMake(x, y, wh, wh);
    
    popView.layer.cornerRadius = wh / 2;
    popView.layer.masksToBounds = YES;
    
    [view addSubview:popView];
    
    __weak typeof(self) weakSelf=self;
    
    popView.PopActioinBlock = ^{
        
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    self.popView = popView;
    
}


/** 添加滚动效果: 创建的topview不需要指定frame，内部算 */
-(void)addScrollNavbarWithScrollView:(UIScrollView *)scrollView autoToggleNavbarHeight:(CGFloat)autoToggleNavbarHeight topView:(UIView *)topView originHeight:(CGFloat)originHeight{
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.autoToggleNavbarHeight = @(autoToggleNavbarHeight);
    self.topViewOriginHeight = @(originHeight);
    [self showPopView:self.view];
    
    //初始化frame
    topView.frame = CGRectMake(0, -originHeight, [UIScreen mainScreen].bounds.size.width, originHeight);
    scrollView.contentInset = UIEdgeInsetsMake(originHeight, 0, 0, 0);
    [scrollView addSubview:topView];
    [scrollView addObserver:self forKeyPath:ScrollViewKeyPath_CoreNavVC options:NSKeyValueObservingOptionNew context:nil];
}


/** 移除滚动效果 */
-(void)removeScrollNavbarWithScrollView:(UIScrollView *)scrollView{
    CoreNavVC *navVC = (CoreNavVC *)self.navigationController;
    navVC.navBgView.alpha = 1;
    [scrollView removeObserver:self forKeyPath:ScrollViewKeyPath_CoreNavVC];
    [scrollView removeFromSuperview];
    scrollView = nil;
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{

    if (self.topView == nil) {return;}
    
    UIScrollView *scrollView = (UIScrollView *)object;
    
    CGFloat offsetY = scrollView.contentOffset.y;
    
    CGFloat maxOffsetY = 250;
    
    CoreNavVC *navVC = (CoreNavVC *)self.navigationController;
    
    CGFloat realOffset = offsetY + self.topViewOriginHeight.floatValue;
    
    if (realOffset > self.autoToggleNavbarHeight.floatValue){
    
        CGFloat p = realOffset / maxOffsetY;
    
        [self.navigationController showNavBarWithAnim:NO];
        
        navVC.navBgView.alpha = p;
        
        self.popView.hidden = p > 0.5;
        
    }else{
        
        [self.navigationController hideNavBarWithAnim:NO];
        navVC.navBgView.alpha = 0;
    }
    
    if(offsetY >= -self.topViewOriginHeight.floatValue) {
        
    }else {
        
        CGRect frame = self.topView.frame;
        CGFloat height = - offsetY;
        frame.size.height = height;
        frame.origin.y = -height;
        self.topView.frame = frame;
    }
    
}




@end