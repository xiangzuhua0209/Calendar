//
//  FDCalendarItem.h
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define viewEdge 0
#define item_height 40

@protocol MCZHCalendarItemDelegate;

@interface MCZHCalendarItem : UIView

@property (strong, nonatomic) NSDate *date;//日期
@property(nonatomic,strong)NSMutableArray * restDayArr;
@property (strong, nonatomic) UICollectionView *collectionView;

@property (weak, nonatomic) id<MCZHCalendarItemDelegate> delegate;

- (NSDate *)nextMonthDate;
- (NSDate *)previousMonthDate;

@end

@protocol MCZHCalendarItemDelegate <NSObject>

- (void)calendarItem:(MCZHCalendarItem *)item didSelectedDate:(NSDate *)date;
- (void)calendarItem:(MCZHCalendarItem *)item didSelectedDate:(NSDate *)date indexPath:(NSIndexPath*)indexPath;
@end
