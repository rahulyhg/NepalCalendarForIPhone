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

#import "CalendarMonthHeaderCell.h"
#import "NepalDate/NepalDate.h"
#import "NepalDate/NepaliStringUtility.h"

@implementation CalendarMonthHeaderCell
{
    NSDateFormatter *_gregorianMonthDateFormatter;
}

- (void)setFirstOfMonth:(NSDate *)firstOfMonth
{
    [super setFirstOfMonth:firstOfMonth];
    if (self.firstOfMonth && self.lastOfMonth) {
        [self createMonthHeader];
    }
}

- (void)setLastOfMonth:(NSDate *)lastOfMonth
{
    [super setLastOfMonth:lastOfMonth];
    if (self.firstOfMonth && self.lastOfMonth) {
        [self createMonthHeader];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];

    self.firstOfMonth = nil;
    self.lastOfMonth = nil;
}

#pragma mark - Private method

- (void)createMonthHeader
{
    NSMutableString *monthStr = [NSMutableString string];

    if (!_gregorianMonthDateFormatter) {
        _gregorianMonthDateFormatter = [NSDateFormatter new];
        _gregorianMonthDateFormatter.calendar = self.calendar;
        
        NSString *dateComponents = @"yyyyLLLL";
        _gregorianMonthDateFormatter.dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale currentLocale]];
    }
    [monthStr appendString:[_gregorianMonthDateFormatter stringFromDate:self.firstOfMonth]];

    NepalDate *nepalFirstDate = [[NepalDate alloc] initWithDate:self.firstOfMonth nepalTimeZone:NO];
    NepalDate *nepalLastDate = [[NepalDate alloc] initWithDate:self.lastOfMonth nepalTimeZone:NO];

    NSString *nepalMonthStr;
    if (nepalFirstDate.nepalYear == nepalLastDate.nepalYear) {
        if (nepalFirstDate.nepalMonth == nepalLastDate.nepalMonth) {
            nepalMonthStr = [NSString stringWithFormat:@"%@ %@",
                            [NepaliStringUtility stringToNepaliMonth:nepalFirstDate.nepalMonth],
                             [NepaliStringUtility stringToNelaliFromNumber:nepalFirstDate.nepalYear]];
        } else {
            nepalMonthStr = [NSString stringWithFormat:@"%@-%@ %@",
                             [NepaliStringUtility stringToNepaliMonth:nepalFirstDate.nepalMonth],
                             [NepaliStringUtility stringToNepaliMonth:nepalLastDate.nepalMonth],
                             [NepaliStringUtility stringToNelaliFromNumber:nepalFirstDate.nepalYear]];
        }
    } else {
        nepalMonthStr = [NSString stringWithFormat:@"%@ %@-%@ %@",
                         [NepaliStringUtility stringToNepaliMonth:nepalFirstDate.nepalMonth],
                         [NepaliStringUtility stringToNelaliFromNumber:nepalFirstDate.nepalYear],
                         [NepaliStringUtility stringToNepaliMonth:nepalLastDate.nepalMonth],
                         [NepaliStringUtility stringToNelaliFromNumber:nepalLastDate.nepalYear]];
    }
    [monthStr appendFormat:@" / %@", nepalMonthStr];

    
    self.textLabel.text = [NSString stringWithString:monthStr];
    self.accessibilityLabel = self.textLabel.text;

}

@end
