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

#import "DialyViewController.h"
#import "GoogleAdMobAds/GADBannerView.h"
#import "NepalDate/NepalDate.h"
#import "NepalDate/NepaliStringUtility.h"
#import "NepalTimeConfig.h"

@interface DialyViewController () <GADBannerViewDelegate>

@end

@implementation DialyViewController
{
    __weak GADBannerView *_adMobView;
    
    NSTimer *_timeUpdateTimer;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateDate)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [self updateDate];

    _nepalTimeTitleLabel.text = @"नेपाल समय"; // Nepal time
    _localTimeTitleLabel.text = @"स्थानीय समय"; // Local time

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
//    // Remove ad.
//    else {
//        CGRect frame = _calendarPositionView.frame;
//        frame.size.height += _adPositionView.frame.size.height;
//        _calendarPositionView.frame = frame;
//        [_adPositionView removeFromSuperview];
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    _timeUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                        target:self
                                                      selector:@selector(updateDate)
                                                      userInfo:nil
                                                       repeats:YES];
    [_timeUpdateTimer fire];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [_timeUpdateTimer invalidate];
    _timeUpdateTimer = nil;
}

#pragma mark - Private method

- (void)updateDate
{
    // Year, Month, Day
    {
        NepalDate *nepalDate = [[NepalDate alloc] init];

        _yearLabel.text = [NepaliStringUtility stringToNelaliFromNumber:nepalDate.nepalYear];
        _monthLabel.text = [NepaliStringUtility stringToNepaliMonth:nepalDate.nepalMonth];
        _dayLabel.text = [NepaliStringUtility stringToNelaliFromNumber:nepalDate.nepalDay];
    }

    NSDate* nowDate = [NSDate date];

    // Nepal time
    {
        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
        [outputDateFormatter setDateStyle:NSDateFormatterNoStyle];
        [outputDateFormatter setTimeStyle:NSDateFormatterMediumStyle];
        [outputDateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Katmandu"]];
        [outputDateFormatter setLocale:[NSLocale currentLocale]];
        _nepalTimeLabel.text = [outputDateFormatter stringFromDate:nowDate];
    }

    // Local time
    {
        NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
        [outputDateFormatter setDateStyle:NSDateFormatterMediumStyle];
        [outputDateFormatter setTimeStyle:NSDateFormatterShortStyle];
        [outputDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
        [outputDateFormatter setLocale:[NSLocale currentLocale]];
        _localTimeLabel.text = [outputDateFormatter stringFromDate:nowDate];
    }
}

@end
