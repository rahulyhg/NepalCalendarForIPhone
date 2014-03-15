//
//  BaseViewController.m
//  NepalCalendarForIPhone
//
//  Created by Yuichi Hirano on 3/15/14.
//
//

#import "BaseViewController.h"
#import "CalendarViewController.h"

@interface BaseViewController () <UITabBarControllerDelegate>

@end

@implementation BaseViewController

- (void)dealloc
{
    self.delegate = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.delegate = self;
}

-   (BOOL)tabBarController:(UITabBarController *)tabBarController
shouldSelectViewController:(UIViewController *)viewController
{
    // Scroll to today of calendar if tap the calendar tab while the calendar tab has already been selected.
    if ([self.selectedViewController isKindOfClass:[CalendarViewController class]] &&
        [viewController isKindOfClass:[CalendarViewController class]]) {
        CalendarViewController *calendarViewController = (CalendarViewController*)viewController;
        [calendarViewController scrollCalendarToDate:[NSDate date] animated:YES];
    }
    
    return YES;
}

@end
