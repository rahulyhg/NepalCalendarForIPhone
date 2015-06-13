//
//  ScheduleTableViewCell.h
//  NepalCalendarForIPhone
//
//  Created by Yuichi Hirano on 6/13/15.
//
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@interface ScheduleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;

@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;

@property (weak, nonatomic) IBOutlet UIView *colorView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)setupEvent:(EKEvent*)event date:date;

@end
