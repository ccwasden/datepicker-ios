//
//  CCDatePickerViewController.h
//  DatePicker
//
//  Created by chase wasden on 2/10/13.
//  Copyright (c) 2013 chase wasden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDateDay.h"

@class CCDatePickerViewController;
@protocol CCDatePickerDelegate <NSObject>
-(void)datePickerDonePressed:(CCDatePickerViewController *)datePicker;
-(void)datePickerCancelPressed:(CCDatePickerViewController *)datePicker;
@end

@interface CCDatePickerViewController : UIViewController <CCDateDayDelegate>

+(CCDatePickerViewController *)datePicker;

@property (strong, nonatomic) NSDate * date;
@property (weak, nonatomic) id<CCDatePickerDelegate> delegate;

-(void)setDateHasItemsCallback:(BOOL (^)(NSDate * date))callback;
-(void)slideUpInView:(UIView *)view;
-(void)slideUpInView:(UIView *)view withModalColor:(UIColor *)color;
-(void)slideDownAndOut;
-(void)setAllowClearDate:(BOOL)allow;

@end
