//
//  AlbumView.h
//  循环复用
//
//  Created by 高小兰 on 14-6-16.
//  Copyright (c) 2014年. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlbumView;
typedef enum {
    kLeft,
    kRight,
    kStop
}ScrollDirection;

@protocol AlbumViewDelegate <NSObject>
@optional
-(void)albumViewDidSelectAtIndex:(NSInteger)index;
-(void)scrollViewDidScroll:(UIScrollView *)scrollView;
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@protocol AlbumViewDataSource <NSObject>
@required
-(NSInteger)numberOfPages;
-(UIView *)AlbumView:(AlbumView *)albumView AtIndex:(NSInteger)index;
@end

@interface AlbumView : UIView
@property(nonatomic,retain)Class reusedClass;
@property(nonatomic,retain)UIScrollView *scrollView;
@property(nonatomic,assign)int currentPage;
@property(nonatomic,assign)id<AlbumViewDataSource>dataSource;
@property(nonatomic,assign)id<AlbumViewDelegate>delegate;
-(void)registClass:(Class)reusedClss;
-(id)dequeView;
@end
