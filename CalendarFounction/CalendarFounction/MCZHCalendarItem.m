//
//  FDCalendarItem.m
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import "MCZHCalendarItem.h"
#import "MCZHCalendarItemCell.h"
#define collectionViewHeadView_H 0
typedef NS_ENUM(NSUInteger, FDCalendarMonth) {
    FDCalendarMonthPrevious = 0,
    FDCalendarMonthCurrent = 1,
    FDCalendarMonthNext = 2,
};

@interface MCZHCalendarItem () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic,assign)NSInteger todayNumber;//今天的日
@end

@implementation MCZHCalendarItem

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupCollectionView];
        [self setFrame:CGRectMake(0, 0, kScreenWidth-viewEdge * 2, self.collectionView.frame.size.height)];
    }
    return self;
}

#pragma mark - Custom Accessors
- (void)setDate:(NSDate *)date {
    _date = date;
    [self.collectionView reloadData];
}
-(void)setRestDayArr:(NSMutableArray *)restDayArr
{
    _restDayArr = restDayArr;
    [self.collectionView reloadData];
}
#pragma mark - Public
// 获取date的下个月日期
- (NSDate *)nextMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = 1;
    //获取指定日期，下n个月的日期
    NSDate *nextMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    nextMonthDate = [NSDate dateWithTimeInterval:8*3600 sinceDate:nextMonthDate];
    //在非本月的情况下，选中的天为本月今天的天  如本月为6月20  滑动后 选中7月20
    NSDateComponents * comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    self.todayNumber = comp.day; 
    return nextMonthDate;
}

// 获取date的上个月日期
- (NSDate *)previousMonthDate {
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.month = -1;
    NSDate *previousMonthDate = [[NSCalendar currentCalendar] dateByAddingComponents:components toDate:self.date options:NSCalendarMatchStrictly];
    previousMonthDate = [NSDate dateWithTimeInterval:8*3600 sinceDate:previousMonthDate];
    NSDateComponents * comp = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:[NSDate date]];
    self.todayNumber = comp.day;
    return previousMonthDate;
}

#pragma mark - Private
// collectionView显示日期单元，设置其属性
- (void)setupCollectionView {
    CGFloat itemWidth = (kScreenWidth -viewEdge * 2) / 7;
    CGFloat itemHeight = item_height;
    UICollectionViewFlowLayout *flowLayot = [[UICollectionViewFlowLayout alloc] init];
    flowLayot.sectionInset = UIEdgeInsetsZero;
    flowLayot.itemSize = CGSizeMake(itemWidth, itemHeight);
    flowLayot.minimumLineSpacing = 0;
    flowLayot.minimumInteritemSpacing = 0;
    CGRect collectionViewFrame = CGRectMake(0, 0, kScreenWidth - viewEdge*2, itemHeight * 6 + collectionViewHeadView_H);
    self.collectionView = [[UICollectionView alloc] initWithFrame:collectionViewFrame collectionViewLayout:flowLayot];
    [self addSubview:self.collectionView];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"MCZHCalendarItemCell" bundle:nil] forCellWithReuseIdentifier:@"MCZHCalendarItemCell"];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
    //获取今天的时间
    NSDate * todayDate = [NSDate dateWithTimeIntervalSinceNow:0];
    NSDateComponents * components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay fromDate:todayDate];
    self.todayNumber = components.day;
}
// 获取date当前月的第一天是星期几
- (NSInteger)weekdayOfFirstDayInDate {
    //设置以星期几为一周的第一天，然后获取当月的第一天是星期几
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:1];//设置日历格式为星期的第一天是星期一  1表示设置为星期天     2表示设置为星期一
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];//创建一个可直接得到年月日的值的对象
    [components setDay:1];//再将这个对象的天设置为第一天，
    NSDate *firstDate = [calendar dateFromComponents:components];//获取到年月日第一天的日期对象
    NSDateComponents *firstComponents = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitDay | NSCalendarUnitMonth fromDate:firstDate];//根据日期对象得到一个有星期的值的对象
//    NSLog(@"星期%ld,天%ld,月份%ld",firstComponents.weekday,firstComponents.day,firstComponents.month);
    /*
     日历中，weekDay的数字1~7分别对应周日~周六，返回的时候做数字转换，1~7对应周一~周日
     */
    return firstComponents.weekday;
}

// 获取date当前月的总天数
- (NSInteger)totalDaysInMonthOfDate:(NSDate *)date {
    NSRange range = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date];
    return range.length;
}
//获取时间字符串---“2017-06-17”
- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter * dateFormattor = [[NSDateFormatter alloc] init];
    [dateFormattor setDateFormat:@"yyyy-MM-dd"];
    NSTimeZone * timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormattor setTimeZone:timeZone];
    NSString * string = [dateFormattor stringFromDate:date];
    return string;
}
#pragma mark - UICollectionDatasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 42;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MCZHCalendarItemCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"MCZHCalendarItemCell" forIndexPath:indexPath];
    NSInteger firstWeekday = [self weekdayOfFirstDayInDate];//获取当前月的第一天是星期几（1~7对应周一~周日）
    NSInteger totalDaysOfMonth = [self totalDaysInMonthOfDate:self.date];//获取当前月的总天数
    cell.titleLabel.backgroundColor = [UIColor whiteColor];
    cell.titleLabel.layer.cornerRadius = cell.frame.size.height/2;
    cell.titleLabel.layer.masksToBounds = YES;
    if (indexPath.row < firstWeekday-1) {//小于这个月的第一天
        cell.titleLabel.text = @"";
    } else if (indexPath.row >= totalDaysOfMonth + firstWeekday-1) {//大于这个月的最后一天
        cell.titleLabel.text = @"";
    } else {//属于这个月
        NSInteger day = indexPath.row - (firstWeekday-1)+1;
        cell.titleLabel.text= [NSString stringWithFormat:@"%ld", day];
        //今天在日历上标出来
        if(day == self.todayNumber){
            cell.titleLabel.backgroundColor = [UIColor redColor];
        }
    }
    return cell;
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(kScreenWidth, collectionViewHeadView_H);
}
-(UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView * headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"headView" forIndexPath:indexPath];
        headView.backgroundColor = [UIColor whiteColor];
        return headView;
    }else{
        return nil;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //获取到日期----根据下标、这个月有多少天及这个月的第一天是周几来计算出 点击cell的日期
    NSInteger weeksDay = [self weekdayOfFirstDayInDate];//这个月第一天对应周几，1~7对应周一~周日
    //获取点击的是哪一天
    NSInteger day = indexPath.row - (weeksDay - 1) + 1;
    //获取到日期
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self.date];
    components.day = day;
    NSDate * selectedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    selectedDate = [NSDate dateWithTimeInterval:8*3600 sinceDate:selectedDate];
    //调代理方法
    if (self.delegate&&[self.delegate respondsToSelector:@selector(calendarItem:didSelectedDate:indexPath:)]) {
        [self.delegate calendarItem:self didSelectedDate:selectedDate indexPath:indexPath];
    }
    //记录点击的天
    self.todayNumber = day;
    [self.collectionView reloadData];
}
@end
