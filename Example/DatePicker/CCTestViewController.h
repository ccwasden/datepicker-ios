//
//  CCTestViewController.h
//  DatePicker
//
//  Created by chase wasden on 2/9/13.
//  Copyright (c) 2013 chase wasden. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCDatePickerViewController.h"

@interface CCTestViewController : UIViewController <CCDatePickerDelegate>
- (IBAction)touchedButton:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (nonatomic, strong) CCDatePickerViewController * datePicker;

@end
