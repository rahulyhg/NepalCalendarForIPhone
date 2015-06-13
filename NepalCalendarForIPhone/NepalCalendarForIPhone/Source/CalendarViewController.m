/*
 * Copyright (c) 2014 Yuichi Hirano
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <EventKitUI/EventKitUI.h>
#import <TimesSquare/TimesSquare.h>
#import "CalendarViewController.h"
#import "GoogleAdMobAds/GADBannerView.h"
#import "NepalTimeConfig.h"
#import "CalendarView.h"
#import "CalendarMonthHeaderCell.h"
#import "CalendarRowCell.h"
#import "ScheduleTableViewCell.h"

@interface CalendarViewController () <UITableViewDataSource, UITableViewDelegate, TSQCalendarViewDelegate>

@end

@implementation CalendarViewController
{
    __weak CalendarView *_calendarView;

    EKEventStore *_eventStore;
    BOOL _isAlreadyShowAlertForCalendarPermmision;
    NSDate *_firstDate;
    NSDate *_lastDate;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    {
        const CGFloat statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
        CGRect frame = _calendarPositionView.frame;
        // iOS7 or later
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
            frame.origin.y = statusBarHeight;
            frame.size.height -= statusBarHeight;
        }
        
        CalendarView *calendarView = [[CalendarView alloc] initWithFrame:frame];
        calendarView.delegate = self;
        calendarView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        calendarView.headerCellClass = [CalendarMonthHeaderCell class];
        calendarView.rowCellClass = [CalendarRowCell class];
        NSDate *nowDate = [NSDate date];
        _firstDate = [[self class] dateAfterYears:-2 from:nowDate]; // 2 years ago
        _lastDate = [[self class] dateAfterYears:2 from:nowDate]; // 2 years leter
        calendarView.firstDate = _firstDate;
        calendarView.lastDate = _lastDate;
        calendarView.backgroundColor = CALENDAR_BACKGROUND_COLOR;
        CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
        calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
        [_calendarPositionView addSubview:calendarView];
        _calendarView = calendarView;
        
        _calendarView.selectedDate = [NSDate date];
    }
    
    _scheduleTableView.dataSource = self;
    _scheduleTableView.delegate = self;

    _eventStore = [[EKEventStore alloc] init];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // Set the calendar view to show today date on start
    [_calendarView scrollToDate:[NSDate date] animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_isAlreadyShowAlertForCalendarPermmision) {
        [self showAlertForCalendarPermmision];
        _isAlreadyShowAlertForCalendarPermmision = YES;
    }
}

- (void)scrollCalendarToDate:(NSDate*)date animated:(BOOL)animated
{
    [_calendarView scrollToDate:date animated:animated];
}

#pragma mark - Private methods

- (void)showAlertForCalendarPermmision
{
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status) {
        case EKAuthorizationStatusNotDetermined:
        {
            // Show alert if user don't allow calender access permission.
            [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error)
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     if (granted) {
                         ;
                     } else {
                         UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                             message:NSLocalizedString(@"Unable to allow access to events in Calendar.  Please allow calendar access from [Settings] > [Privacy] > [Calendar].", nil)
                                                                            delegate:nil
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                                   otherButtonTitles:nil];
                         [alertView show];
                     }
                 });
             }];
            break;
        }
        case EKAuthorizationStatusAuthorized:
        {
            break;
        }
        case EKAuthorizationStatusRestricted:
        {
            // Not allowed.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedString(@"Denied access to events in Calendar. Please allow calendar access from [Settings] > [General] > [Restrictions].", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            break;
        }
        case EKAuthorizationStatusDenied:
        {
            // Not allowed.
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                message:NSLocalizedString(@"Unable to allow access to events in Calendar.  Please allow calendar access from [Settings] > [Privacy] > [Calendar].", nil)
                                                               delegate:nil
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:nil];
            [alertView show];
            break;
        }
        default:
            break;
    }
}

- (NSArray*)eventsWithDate:(NSDate*)date
{
    if (!date) {
        return @[];
    }

    NSDate *endDate = [NSDate dateWithTimeInterval:(24 * 60 * 60) sinceDate:date];
    
    NSArray *eventCalendars = [_eventStore calendarsForEntityType:EKEntityTypeEvent];
    NSPredicate *predicate = [_eventStore predicateForEventsWithStartDate:date
                                                                  endDate:endDate
                                                                calendars:eventCalendars];
    return [_eventStore eventsMatchingPredicate:predicate];
}

+ (NSDate*)dateAfterYears:(NSInteger)years from:(NSDate*)from
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *component = [[NSDateComponents alloc] init];
    [component setYear:years];
    
    return [calendar dateByAddingComponents:component toDate:from options:0];

}

#pragma mark - TSQCalendarViewDelegate method

- (void)calendarView:(TSQCalendarView *)calendarView didSelectDate:(NSDate *)date
{
    [_scheduleTableView reloadData];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *events = [self eventsWithDate:_calendarView.selectedDate];
    return events.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ScheduleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleTableViewCell" forIndexPath:indexPath];
    
    NSArray *events = [self eventsWithDate:_calendarView.selectedDate];
    EKEvent *event = events[indexPath.row];
    [cell setupEvent:event date:_calendarView.selectedDate];
    
    NSLog(@"%d", indexPath.row);
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

@end
