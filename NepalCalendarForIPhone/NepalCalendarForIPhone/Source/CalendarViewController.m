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

#import <TimesSquare/TimesSquare.h>
#import "CalendarViewController.h"
#import "GoogleAdMobAds/GADBannerView.h"
#import "NepalTimeConfig.h"
#import "CalendarView.h"
#import "CalendarMonthHeaderCell.h"
#import "CalendarRowCell.h"

@interface CalendarViewController () <GADBannerViewDelegate>

@end

@implementation CalendarViewController
{
    __weak CalendarView *_calendarView;
    __weak GADBannerView *_adMobView;
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
        calendarView.autoresizesSubviews = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        calendarView.headerCellClass = [CalendarMonthHeaderCell class];
        calendarView.rowCellClass = [CalendarRowCell class];
        NSDate *nowDate = [NSDate date];
        calendarView.firstDate = [[self class] dateAfterYears:-2 from:nowDate]; // 2 years ago
        calendarView.lastDate = [[self class] dateAfterYears:2 from:nowDate]; // 2 years leter
        calendarView.backgroundColor = CALENDAR_BACKGROUND_COLOR;
        CGFloat onePixel = 1.0f / [UIScreen mainScreen].scale;
        calendarView.contentInset = UIEdgeInsetsMake(0.0f, onePixel, 0.0f, onePixel);
        [_calendarPositionView addSubview:calendarView];
        _calendarView = calendarView;
    }

    _adPositionView.backgroundColor = CALENDAR_BACKGROUND_COLOR;

    // Create ad.
    if (ADMOB_UNIT_ID) {
        GADBannerView *adMobView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        adMobView.adUnitID = ADMOB_UNIT_ID;
        adMobView.delegate = self;
        adMobView.rootViewController = self;
        [_adPositionView addSubview:adMobView];
        _adMobView = adMobView;
        
        [_adMobView loadRequest:[GADRequest request]];
    }
    // Remove ad.
    else {
        CGRect frame = _calendarPositionView.frame;
        frame.size.height += _adPositionView.frame.size.height;
        _calendarPositionView.frame = frame;

        frame = _calendarView.frame;
        frame.size.height += _adPositionView.frame.size.height;
        _calendarView.frame = frame;

        [_adPositionView removeFromSuperview];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    // Set the calendar view to show today date on start
    [_calendarView scrollToDate:[NSDate date] animated:NO];
}

- (void)scrollCalendarToDate:(NSDate*)date animated:(BOOL)animated
{
    [_calendarView scrollToDate:date animated:animated];
}

#pragma mark - Private methods

+ (NSDate*)dateAfterYears:(NSInteger)years from:(NSDate*)from
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *component = [[NSDateComponents alloc] init];
    [component setYear:years];
    
    return [calendar dateByAddingComponents:component toDate:from options:0];

}

@end
