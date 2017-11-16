//
//  ViewController.m
//  CalendarFounction
//
//  Created by 向祖华 on 2017/11/15.
//  Copyright © 2017年 向祖华. All rights reserved.
//

#import "ViewController.h"
#import "MCZHCalendar.h"

@interface ViewController ()<MCZHCalendarDelegate>
@property(nonatomic,strong)MCZHCalendar * calendar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
}
#pragma mark -- 代理方法

-(void)calendarDidClickMaskingViewOrTitleButton{
    NSLog(@"隐藏日历控件");
    self.calendar = nil;
}
-(void)calendarChangeMonthWithDirection:(NSInteger)direction{
    NSLog(@"进行了左右滑动");
}
-(void)calendatDidSelectedWithDate:(NSDate *)date indexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了细胞%@,---%@",date,indexPath);
    self.dateLabel.text = [NSString stringWithFormat:@"%@",date];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark -- 点击事件
- (IBAction)showCalendarAction:(UIButton *)sender {
    self.calendar = [[MCZHCalendar alloc] initWithCurrentDate:[NSDate date] fram:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.calendar.delegate = self;
    [self.view addSubview:self.calendar];
}

@end
