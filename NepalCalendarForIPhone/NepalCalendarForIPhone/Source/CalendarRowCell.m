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

#import "CalendarRowCell.h"
#import "NepalDate/NepalDate.h"
#import "NepalDate/NepaliStringUtility.h"

@implementation CalendarRowCell
{
    NSDateFormatter *_gregorianDateFormatter;
    NSDateFormatter *_accessibilityFormatter;
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect
{
    // Move down for the row at the top
    rect.origin.y += self.columnSpacing;
    rect.size.height -= (self.bottomRow ? 2.0f : 1.0f) * self.columnSpacing;
    [super layoutViewsForColumnAtIndex:index inRect:rect];
}

- (UIImage *)todayBackgroundImage
{
    return [[UIImage imageNamed:@"CalendarTodaysDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

- (UIImage *)selectedBackgroundImage
{
    return [[UIImage imageNamed:@"CalendarSelectedDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
}

- (UIImage *)notThisMonthBackgroundImage
{
    return [[UIImage imageNamed:@"CalendarPreviousMonth.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
}

- (UIImage *)backgroundImage
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"CalendarRow%@.png", self.bottomRow ? @"Bottom" : @""]];
}

+ (CGFloat)cellHeight
{
    return 58.0f;
}

- (void)configureButton:(UIButton *)button
{
    button.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
    button.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleLabel.shadowOffset = self.shadowOffset;
    button.adjustsImageWhenDisabled = NO;
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (UIButton*)dayButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self configureButton:button];
    [button setTitleColor:[self.textColor colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    return button;
}

- (UIButton*)notThisMonthButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self configureButton:button];
    UIColor *backgroundPattern = [UIColor colorWithPatternImage:[self notThisMonthBackgroundImage]];
    button.backgroundColor = backgroundPattern;
    button.titleLabel.backgroundColor = backgroundPattern;
    return button;
}

- (UIButton*)todayButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self configureButton:button];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[self todayBackgroundImage] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];
    
    button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    
    return button;
}

- (UIButton*)selectedButton
{
    UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self configureButton:button];
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];
    
    button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    
    return button;
}

- (void)setTitleToDayButton:(UIButton*)button date:(NSDate*)date
{
    NSString *title = [NSString stringWithFormat:@"%@\n%@", [self stringOfGregorianDay:date],
                                                            [self stringOfNepaliDay:date]];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateDisabled];
}

- (void)setAccessibilityLabelToDayButton:(UIButton*)button date:(NSDate*)date
{
    [button setAccessibilityLabel:[self stringOfAccessibilityLabel:date]];
}

- (void)setTitleToNotThisMonthButton:(UIButton*)button date:(NSDate*)date
{
    [self setTitleToDayButton:button date:date];
}

- (void)setAccessibilityLabelToNotThisMonthButton:(UIButton*)button date:(NSDate*)date
{
    [self setAccessibilityLabelToDayButton:button date:date];
}

- (void)setTitleToTodayButton:(UIButton*)button date:(NSDate*)date
{
    [self setTitleToDayButton:button date:date];
}

- (void)setAccessibilityLabelToTodayButton:(UIButton*)button date:(NSDate*)date
{
    [self setAccessibilityLabelToDayButton:button date:date];
}

#pragma mark - Private methods

- (NSString*)stringOfGregorianDay:(NSDate*)date
{
    if (!_gregorianDateFormatter) {
        _gregorianDateFormatter = [[NSDateFormatter alloc] init];
        _gregorianDateFormatter.calendar = self.calendar;
        _gregorianDateFormatter.dateFormat = @"d";
    }
    return [_gregorianDateFormatter stringFromDate:date];
}

- (NSString*)stringOfNepaliDay:(NSDate*)date
{
    NSMutableString *result = [NSMutableString string];

    NepalDate *nepalDate = [[NepalDate alloc] initWithDate:date nepalTimeZone:NO];
    if (nepalDate.nepalDay == 1) {
        [result appendString:[NepaliStringUtility stringToNepaliMonth:nepalDate.nepalMonth]];
    }
    [result appendFormat:@"\n%@", [NepaliStringUtility stringToNelaliFromNumber:nepalDate.nepalDay]];

    return [NSString stringWithString:result];
}

-(NSString*)stringOfAccessibilityLabel:(NSDate*)date
{
    NSMutableString *result = [NSMutableString string];

    if (!_accessibilityFormatter) {
        _accessibilityFormatter = [NSDateFormatter new];
        _accessibilityFormatter.calendar = self.calendar;
        _accessibilityFormatter.dateStyle = NSDateFormatterLongStyle;
    }
    [result appendString:[_accessibilityFormatter stringFromDate:date]];

    NepalDate *nepalDate = [[NepalDate alloc] initWithDate:date nepalTimeZone:NO];
    [result appendFormat:@" %@", [NepaliStringUtility stringToNepaliMonth:nepalDate.nepalMonth]];
    [result appendFormat:@" %@", [NepaliStringUtility stringToNelaliFromNumber:nepalDate.nepalDay]];

    return [NSString stringWithString:result];
}

@end
