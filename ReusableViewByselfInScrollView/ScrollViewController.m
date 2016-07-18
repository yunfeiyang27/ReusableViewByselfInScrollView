//
//  ScrollViewController.m
//  headerofcollectionView
//
//  Created by leihuan on 16/7/15.
//  Copyright © 2016年 leihuan. All rights reserved.
//

#import "ScrollViewController.h"

@interface ScrollViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

// 集合：用来存储可以重用的view
@property (nonatomic, strong) NSMutableSet *set;

// 记录scrollView的内容偏移的距离
@property (nonatomic) CGFloat xIndex;

@end

@implementation ScrollViewController

// 懒加载集合
-(NSMutableSet *)set  {
    
    if (!_set) {
        
        // 创建指定元素个数的一个集合对象，用来存储可以被重用的view
        self.set = [NSMutableSet setWithCapacity:1];
        
    }
    
    return _set;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, [UIScreen mainScreen].bounds.size.width, 300)];
    
    // scrollView里的contentView可以滚动的区域范围
    self.scrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width * 3, 300);
    
    // 当scrollView里的内容contentView在滚动时，相对于scrollView左上角顶点的偏移
    // 这里设置contentView刚开始滚动到哪个位置
    self.scrollView.contentOffset = CGPointMake([UIScreen mainScreen].bounds.size.width, 0);
    
    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.delegate = self;
    
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.scrollView];
    
    [self createViews];
    
}

- (void)createViews {
    
    NSArray *colorArr = @[[UIColor redColor], [UIColor blueColor], [UIColor greenColor]];
    
    for (int i = 0; i < 3; i++) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(i * [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        
        view.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 150, 50)];
        
        label.backgroundColor = colorArr[i];
        
        label.text = [NSString stringWithFormat:@"这是第%d个视图",i + 1];
        
        label.textColor = [UIColor whiteColor];
        
        [view addSubview:label];
        
        
        //三个view的tag值从左至右分别为100, 101, 102
        
        view.tag = 100 + i;
        
        
        [self.scrollView addSubview:view];
    }
    
}

//当手指滚动scrollView离开屏幕后的动画减速停下时将会调用scrollViewDidEndDecelerating方法
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    // 已经偏移了多少距离
    self.xIndex = scrollView.contentOffset.x;
    
}

//滚动视图减速完成，滚动将停止时，调用该方法（减速动画结束时被调用），一次有效滑动，只执行一次
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    // 向左滚动时
    //         即： 当前实时的偏移量 大于  已经偏移了的距离
    if (scrollView.contentOffset.x > self.xIndex) {
        
        //将最左边的视图从父视图上移除并放入重用集合里,并从重用集合里取view,放置到当前视图右边视图的位置
        
        // 通过tag获取左起第一个view
        UIView *fView = [self.scrollView viewWithTag:100];
        
        // 给集合添加单个元素
        [self.set addObject:fView];
        
        // 移除左起第一个view
        [fView removeFromSuperview];
        
        // 通过tag获取左起第二个view
        UIView *sView = [self.scrollView viewWithTag:101];
        // 将这个view的tag设置成100
        sView.tag = 100;
        
        // 通过tag获取左起第三个view
        UIView *tView = [self.scrollView viewWithTag:102];
        // 将这个view的tag设置成101
        tView.tag = 101;
        
        // 从集合中取出可以重用的view，并且设置成左起第三个view，同时设置frame
        UIView *view = [self getViewsWithReuseIdentifier];
        [view setFrame:CGRectMake(tView.frame.origin.x + [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        // 将这个view的tag设置成102
        view.tag = 102;
        
        [self.scrollView addSubview:view];
        
        NSLog(@"向左滚动:%p", view);

        
        // 向右滚动时
        //         即： 当前实时的偏移量   小于  已经偏移了的距离
    } else if(scrollView.contentOffset.x < self.xIndex){
        
        //将最右边的视图从父视图上移除并放入重用集合里,并从重用集合里取view,放置到当前视图左边视图的位置
        
        UIView *tView = [self.scrollView viewWithTag:102];
        
        [self.set addObject:tView];
        
        [tView removeFromSuperview];
        
        UIView *sView = [self.scrollView viewWithTag:101];
        sView.tag = 102;
        
        UIView *fView = [self.scrollView viewWithTag:100];
        fView.tag = 101;
        
        UIView *view = [self getViewsWithReuseIdentifier];
        [view setFrame:CGRectMake(fView.frame.origin.x - [UIScreen mainScreen].bounds.size.width, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        view.tag = 100;
        
        [self.scrollView addSubview:view];
        
        NSLog(@"向右滚动:%p", fView);
        
    }
    
}

// 从集合中取出可以重用的view，如果没有可重用的view，就自己创建一个view返回
- (UIView *)getViewsWithReuseIdentifier {
    
    // [self.set anyObject] 从集合中获取对象
    if ([self.set anyObject] == nil) {
        
        return [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        
    }else {
        
        UIView *returnView = [self.set anyObject];
        
        // removeObject 移除集合中的一个元素
        [self.set removeObject:returnView];
        
        return returnView;
        
    }
}




@end
