//
//  ScheduleTableViewCell.m
//  NepalCalendarForIPhone
//
//  Created by Yuichi Hirano on 6/13/15.
//
//

#import "NSDate+Utilities.h"
#import "ScheduleTableViewCell.h"

@implementation ScheduleTableViewCell

- (void)setupEvent:(EKEvent*)event date:date
{
    static NSDateFormatter *formatter;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"HH:mm";
    }

    if ([event.startDate isSameDayWithDate:date]) {
        _startDateLabel.text = [formatter stringFromDate:event.startDate];
    } else {
        _startDateLabel.text = nil;
    }
    if ([event.endDate isSameDayWithDate:date]) {
        _endDateLabel.text = [formatter stringFromDate:event.endDate];
    } else {
        _endDateLabel.text = nil;
    }

    _colorView.backgroundColor = [UIColor colorWithCGColor:event.calendar.CGColor];

    _titleLabel.text = event.title;
}

@end
