//
//  AlbumView.m
//  循环复用
//
//  Created by 高小兰 on 14-6-16.
//  Copyright (c) 2014年. All rights reserved.
//

#import "AlbumView.h"

@interface AlbumView()<UIScrollViewDelegate>

{
    int _leftViewPage;
    int _rightViewPage;
    int _middleViewPage;
}
@property(nonatomic,assign)int numberOfPages;
@property(nonatomic,assign)ScrollDirection direction;
@property(nonatomic,retain)NSMutableSet *dequeSet;
@end

@implementation AlbumView
-(void)registClass:(Class)reusedClss
{
    _reusedClass = reusedClss;
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        [self addSubview:_scrollView];
        
        // 可复用集合
        _dequeSet = [[NSMutableSet alloc]init];
        
    }
    return self;
}


// 当指定数据源时,执行set方法,在这里计算scrollView的contentSize
-(void)setDataSource:(id<AlbumViewDataSource>)dataSource
{
    _dataSource = dataSource;
    _numberOfPages = [dataSource numberOfPages];
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width * _numberOfPages, 0);
    
    // 加载前两页(如果只有一页那就之加载一页)
    float scrollViewX = _scrollView.contentOffset.x;
    _currentPage = scrollViewX / 320; // 计算当前页
    _middleViewPage = _currentPage; // 中间页
    _leftViewPage = _middleViewPage - 1; // 左边页
    _rightViewPage = _middleViewPage + 1;// 右边页
    
    for (int i = _leftViewPage; i <= _rightViewPage; i++) {// 只加载可见的三页
        if (i >= 0 && i <= _numberOfPages - 1) {// 页码必须在显示范围内
            UIView *view = [self.dataSource AlbumView:self AtIndex:i];
            view.frame = CGRectMake(320 * i, 0, 320, self.bounds.size.height);
           // view.center = CGPointMake(view.frame.origin.x  + 160, self.bounds.size.height / 2 - 20);
            [_scrollView addSubview:view];
            view.tag = i;
            
        }
    }
}

-(void)upLoadPages
{
    // 重新计算当前页,左边页,和右边页
    _leftViewPage = _currentPage - 1;
    _rightViewPage = _currentPage + 1;
    _middleViewPage = _currentPage;
    
    // 通过_scrollView的子视图数组找到复用的视图
    NSArray *visiableViewArray = [_scrollView subviews];
    for (UIView *view in visiableViewArray) {
        if ([view isKindOfClass:[_reusedClass class]]) {
            
            if (view.tag < _leftViewPage || view.tag > _rightViewPage) {// 如果视图超出范围,就移除
                [_dequeSet addObject:view];
                [view removeFromSuperview];
            }
        }
    }
    
    // 判断滑动方向,如果向右滑动,需要在leftViewPage上加一张
    if (_direction == kRight) {
        if (_leftViewPage < 0) { // 如果左边页超出范围,就不在添加
            return;
        }
        
        // 视图从dataSource的方法中获取
        UIView *view = [self.dataSource AlbumView:self AtIndex:_leftViewPage];
        view.frame = CGRectMake(320 * _leftViewPage, 0, 320, view.bounds.size.height); // 调整视图位置
       // view.center = CGPointMake(view.frame.origin.x  + 160, self.bounds.size.height / 2 - 20);
        [_scrollView addSubview:view]; // 添加到视图之后从复用集合中移除
        [_dequeSet removeObject:view];
        
        view.tag = _leftViewPage; // 设定视图的页码

    }else if (_direction == kLeft){
        if (_rightViewPage >= _numberOfPages) {
            return;
        }
        UIView *view = [self.dataSource AlbumView:self AtIndex:_rightViewPage];
        view.frame = CGRectMake(320 * _rightViewPage, 0, 320, self.bounds.size.height);
      //  view.center = CGPointMake(view.frame.origin.x  + 160, self.bounds.size.height / 2 - 20);
        [_scrollView addSubview:view];
        [_dequeSet removeObject:view];
        view.tag = _rightViewPage;
        
    }
}

-(void)tap:(UITapGestureRecognizer *)tap
{
    if ([self.delegate respondsToSelector:@selector(albumViewDidSelectAtIndex:)]) {
         [self.delegate albumViewDidSelectAtIndex:tap.view.tag];
    }
}

-(id)dequeView
{
    UIView *view= [_dequeSet anyObject];// 从复用集合中取出任意一个元素
    if (view == nil) {// 如果该元素为空,则新建一个
        view = [[_reusedClass alloc]init];
    }
    return view;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // 滑动时执行,
    _currentPage = _scrollView.contentOffset.x / 320;// (currentPage随时变动)
    
    // 当前页大于中间页,则是向左滑
    if (_currentPage > _middleViewPage) {
        _direction = kLeft;
        [self upLoadPages];
    }else if(_currentPage < _middleViewPage){
        // 当前页小于中间页,则是向右滑
        _direction = kRight;
        [self upLoadPages];
    }
    
    if ([self.delegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.delegate scrollViewDidScroll:scrollView];
    }
    
}

// 重新加载
-(void)reloadData
{
    NSArray *subViewArray = [_scrollView subviews];
    for (UIView *view in subViewArray) {
        if ([view isKindOfClass:[UIView class]]) {
            [view removeFromSuperview]; // 先移除所有视图,然后重新加载
        }
    }
    
    _numberOfPages = [self.dataSource numberOfPages];// 重新计算总页数
    _scrollView.contentSize = CGSizeMake(self.bounds.size.width * _numberOfPages, 0);
    
    float scrollViewX = _scrollView.contentOffset.x;// 当前现实位置不变
    _currentPage = scrollViewX / 320;
    _leftViewPage = _currentPage - 1;
    _rightViewPage = _currentPage + 1;
    for (int i = _leftViewPage; i <= _rightViewPage; i++) {
        if (i >= 0 && i <= 1) {
            UIView *view = [self.dataSource AlbumView:self AtIndex:i];
            view.frame = CGRectMake(320 * i, 0, 320, 480);
            [_scrollView addSubview:view];
            view.tag = i;
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.delegate scrollViewDidEndDecelerating:scrollView];
    }
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
