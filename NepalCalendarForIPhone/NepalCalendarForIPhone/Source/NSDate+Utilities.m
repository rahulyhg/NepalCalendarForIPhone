//
//  NSDate+Utilities.m
//  NepalCalendarForIPhone
//
//  Created by Yuichi Hirano on 6/13/15.
//
//

#import "NSDate+Utilities.h"

@implementation NSDate (Utilities)

- (BOOL)isSameDayWithDate:(NSDate*)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date];
    
    return [comp1 day]   == [comp2 day] && [comp1 month] == [comp2 month] && [comp1 year]  == [comp2 year];
}

@end
