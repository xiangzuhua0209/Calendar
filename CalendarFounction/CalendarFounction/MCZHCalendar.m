//
//  FDCalendar.m
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import "MCZHCalendar.h"
#define Weekdays @[@"日",@"一", @"二", @"三", @"四", @"五", @"六"]
#define titleView_height 64
#define weekView_height 30
static NSDateFormatter *dateFormattor;

@interface MCZHCalendar () <UIScrollViewDelegate,MCZHCalendarItemDelegate>
//记录日期的对象
@property (strong, nonatomic) NSDate *date;
//用于放置3个MCZHCalendarItem，分别对应本月、上一个月、下一个月
@property (strong, nonatomic) UIScrollView *scrollView;
//添加一个背景视图，用于控件整体做倒角
@property(nonatomic,strong)UIView * ChamferView;
//蒙版视图
@property(nonatomic,strong)UIView * maskingView;//
@end

@implementation MCZHCalendar
#pragma mark -- 初始化方法
- (instancetype)initWithCurrentDate:(NSDate *)date fram:(CGRect)fram{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setFrame:fram];
        self.date = date;
        [self setMaskingView];
        [self setChamferView];
        [self setupTitleBar];
        [self setupWeekHeader];
        [self setupScrollView];
        [self setupCalendarItemsWithFrame:fram];
        [self setCurrentDate:self.date];
    }
    return self;
}

-(void)setCenterCalendarItem:(MCZHCalendarItem *)centerCalendarItem{
    _centerCalendarItem = centerCalendarItem;
    [centerCalendarItem.collectionView reloadData];
}
//蒙版
-(void)setMaskingView{
    self.maskingView = [[UIView alloc] initWithFrame:self.frame];
    self.maskingView.backgroundColor = [UIColor blackColor];
    self.maskingView.alpha = 0.3;
    [self addSubview:self.maskingView];
    //添加一个手势
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self.maskingView addGestureRecognizer:tap];
}
//整体倒角底图
-(void)setChamferView{
    self.ChamferView = [[UIView alloc] initWithFrame:CGRectMake(viewEdge, 0, self.frame.size.width - viewEdge*2, titleView_height + weekView_height+item_height*6)];
    self.ChamferView.backgroundColor = [UIColor colorWithRed:223/255.0 green:231/255.0 blue:254/255.0 alpha:1];
    [self addSubview:self.ChamferView];
}
//初始化最上面的日期显示及左右切换按钮视图
- (void)setupTitleBar {
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width-viewEdge*2, titleView_height)];
    self.titleView.backgroundColor = [UIColor colorWithRed:96/255 green:139/255.0 blue:252/255.0 alpha:1];
    [self.ChamferView addSubview:self.titleView];
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, (self.frame.size.width-viewEdge*2)/4, 44)];
    [self.leftButton setImage:[UIImage imageNamed:@"calendar_left"] forState:UIControlStateNormal];
    [self.leftButton addTarget:self action:@selector(setPreviousMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.leftButton];
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width-viewEdge*2)*3/4, 20, (self.frame.size.width-viewEdge*2)/4, 44)];
    [self.rightButton setImage:[UIImage imageNamed:@"calendar_right"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(setNextMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:self.rightButton];
    self.titleButton = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width-viewEdge*2 - 100)/2, 20, 100, 44)];
    [self.titleButton setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    self.titleButton.backgroundColor = [UIColor clearColor];
    self.titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.titleButton setTitle:@"2017年11月" forState:(UIControlStateNormal)];
    [self.titleButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    [self.titleButton addTarget:self action:@selector(titleButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [self.titleView addSubview:self.titleButton];
}
// 设置星期文字的显示
- (void)setupWeekHeader {
    NSInteger count = [Weekdays count];
    CGFloat offsetX = 0;
    for (int i = 0; i < count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, titleView_height, (self.frame.size.width-viewEdge*2)/count, weekView_height)];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.text = Weekdays[i];
        weekdayLabel.textColor = [UIColor blackColor];
        weekdayLabel.backgroundColor = [UIColor colorWithRed:223/255.0 green:231/255.0 blue:254/255.0 alpha:1];
        weekdayLabel.font = [UIFont systemFontOfSize:12];
        [self.ChamferView addSubview:weekdayLabel];
        offsetX += weekdayLabel.frame.size.width;
    }
}
// 设置包含日历的item的scrollView
- (void)setupScrollView {
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView setFrame:CGRectMake(0, titleView_height + weekView_height, self.frame.size.width-viewEdge*2, self.ChamferView.frame.size.height-(titleView_height+weekView_height))];
    self.scrollView.contentSize = CGSizeMake(3 * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    [self.ChamferView addSubview:self.scrollView];
}
// 设置3个日历的item
- (void)setupCalendarItemsWithFrame:(CGRect)frame {
    self.leftCalendarItem = [[MCZHCalendarItem alloc] init];
    [self.scrollView addSubview:self.leftCalendarItem];
    CGRect itemFrame = self.leftCalendarItem.frame;
    itemFrame.origin.x = self.ChamferView.frame.size.width;
    self.centerCalendarItem = [[MCZHCalendarItem alloc] init];
    self.centerCalendarItem.frame = itemFrame;
    [self.scrollView addSubview:self.centerCalendarItem];
    self.rightCalendarItem = [[MCZHCalendarItem alloc] init];
    itemFrame.origin.x = self.ChamferView.frame.size.width * 2;
    self.rightCalendarItem.frame = itemFrame;
    [self.scrollView addSubview:self.rightCalendarItem];
    self.leftCalendarItem.delegate = self;
    self.centerCalendarItem.delegate =self;
    self.rightCalendarItem.delegate = self;
}
#pragma mark -- 代理方法
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reloadCalendarItems];
}
#pragma mark -- FDCalendarItemDelegate
- (void)calendarItem:(MCZHCalendarItem *)item didSelectedDate:(NSDate *)date{
    
}
//点击了某一天
-(void)calendarItem:(MCZHCalendarItem *)item didSelectedDate:(NSDate *)date indexPath:(NSIndexPath *)indexPath{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(calendatDidSelectedWithDate:indexPath:)]) {
        [self.delegate calendatDidSelectedWithDate:date indexPath:indexPath];
    }
    //清除掉日历
    [self removeCalendar];
    
}
#pragma mark - 私有方法
- (NSString *)stringFromDate:(NSDate *)date {
    if (!dateFormattor) {
        dateFormattor = [[NSDateFormatter alloc] init];
        [dateFormattor setDateFormat:@"yyyy-MM"];
    }
    return [dateFormattor stringFromDate:date];
}
// 设置当前日期，初始化
- (void)setCurrentDate:(NSDate *)date {
    //当中间的月份改变的时候，重新设置左，中，右的日期
    self.centerCalendarItem.date = date;
    self.leftCalendarItem.date = [self.centerCalendarItem previousMonthDate];
    self.rightCalendarItem.date = [self.centerCalendarItem nextMonthDate];
    //然后设置标题的值
    [self.titleButton setTitle:[self stringFromDate:self.centerCalendarItem.date] forState:UIControlStateNormal];
    
}
// 重新加载日历items的数据
- (void)reloadCalendarItems {
    CGPoint offset = self.scrollView.contentOffset;
    if (offset.x == self.scrollView.frame.size.width ) { //防止滑动一点点并不切换scrollview的视图
        return;
    }
    if (offset.x > self.scrollView.frame.size.width) {//向左滑到下一个月
        [self setNextMonthDate];
    } else {//向右滑到上一个月
        [self setPreviousMonthDate];
    }
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);//保持scrollView的偏移在中间，只是改变数据
}
-(void)removeCalendar{
    self.leftCalendarItem.delegate = nil;
    self.centerCalendarItem.delegate =nil;
    self.rightCalendarItem.delegate = nil;
    self.scrollView.delegate = nil;
    self.leftCalendarItem = nil;
    self.centerCalendarItem =nil;
    self.rightCalendarItem = nil;
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    [self.maskingView removeFromSuperview];
    self.maskingView = nil;
    [self.ChamferView removeFromSuperview];
    self.ChamferView = nil;
    [self removeFromSuperview];

}
#pragma mark - 点击事件
// 跳到上一个月,则设置中间显示的月份为上一个月
- (void)setPreviousMonthDate {
    [self setCurrentDate:[self.centerCalendarItem previousMonthDate]];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(calendarChangeMonthWithDirection:)]) {
        [self.delegate calendarChangeMonthWithDirection:-1];
    }
}
// 跳到下一个月,则设置中间显示的月份为下一个月
- (void)setNextMonthDate {
    [self setCurrentDate:[self.centerCalendarItem nextMonthDate]];
    if (self.delegate&&[self.delegate respondsToSelector:@selector(calendarChangeMonthWithDirection:)]) {
        [self.delegate calendarChangeMonthWithDirection:1];
    }
}
//点击最上面的日期视图消失
-(void)titleButtonAction{
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarDidClickMaskingViewOrTitleButton)]) {
        [self.delegate calendarDidClickMaskingViewOrTitleButton];
    }
    [self removeCalendar];
}
//蒙版上的点击事件-日期视图消失
-(void)tapAction{
    [self removeCalendar];
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarDidClickMaskingViewOrTitleButton)]) {
        [self.delegate calendarDidClickMaskingViewOrTitleButton];
    }
}
@end
