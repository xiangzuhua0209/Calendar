//
//  FDCalendar.h
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCZHCalendarItem.h"
//滑动日历或者点击日期中的某一天调用代理方法
@protocol MCZHCalendarDelegate <NSObject>
/**
 * 点击蒙版或者最上面的日期标题，日历控件会清除掉，并且走这个代理方法
 */
-(void)calendarDidClickMaskingViewOrTitleButton;//点击蒙版和最上面的日期标题
/**
 * 左右滑动日历或者点击左右按钮切换日历，会走这个代理
 * direction 向左滑跳到下一个月，为1 ；向右滑跳到上一个月，为-1。
 */
-(void)calendarChangeMonthWithDirection:(NSInteger)direction;
/**
 * 点击日历上的某天，会触发这个代理方法，同时日历也会被清除掉
 * date 点击的日期对象
 * indexPath 点击的日期在列表中位置
 */
-(void)calendatDidSelectedWithDate:(NSDate*)date indexPath:(NSIndexPath*)indexPath;//点击了对应的日期
@end
@interface MCZHCalendar : UIView
@property(nonatomic,strong)UIView * titleView;
@property (nonatomic,strong) UIButton * leftButton;
@property (nonatomic,strong) UIButton * rightButton;
@property(nonatomic,strong)UIButton * titleButton;
@property (strong, nonatomic) MCZHCalendarItem *leftCalendarItem;
@property (strong, nonatomic) MCZHCalendarItem *centerCalendarItem;
@property (strong, nonatomic) MCZHCalendarItem *rightCalendarItem;
@property(nonatomic,weak)id<MCZHCalendarDelegate>delegate;
//初始化方法
-(instancetype)initWithCurrentDate:(NSDate *)date fram:(CGRect)fram;
@end
