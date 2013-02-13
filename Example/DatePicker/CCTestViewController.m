//
//  CCTestViewController.m
//  DatePicker
//
//  Created by chase wasden on 2/9/13.
//  Copyright (c) 2013 chase wasden. All rights reserved.
//

#import "CCTestViewController.h"


@interface CCTestViewController ()
@property (nonatomic, retain) NSDate * curDate;
@property (nonatomic, retain) NSDateFormatter * formatter;
@end

@implementation CCTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.curDate = [NSDate date];
    self.formatter = [[NSDateFormatter alloc] init];
    [_formatter setDateFormat:@"dd/MM/yyyy --- HH:mm"];
    [self refreshTitle];
}

-(void)refreshTitle{
    if(self.curDate) {
    [self.dateButton setTitle:[_formatter stringFromDate:_curDate] forState:UIControlStateNormal];
    }
    else {
        [self.dateButton setTitle:@"No date selected" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)touchedButton:(id)sender {
    if(!self.datePicker)
        self.datePicker = [CCDatePickerViewController datePicker];
    self.datePicker.date = self.curDate;
    self.datePicker.delegate = self;
    [self.datePicker setAllowClearDate:YES];
    [self.datePicker setDateHasItemsCallback:^BOOL(NSDate *date) {
        int tmp = (arc4random() % 30)+1;
        if(tmp % 5 == 0)
            return YES;
        return NO;
    }];
    [self.datePicker slideUpInView:self.navigationController.view withModalColor:[UIColor lightGrayColor]];
}

-(void)datePickerDonePressed:(CCDatePickerViewController *)datePicker{
    self.curDate = datePicker.date;
    [self refreshTitle];
    [self.datePicker slideDownAndOut];
}

-(void)datePickerCancelPressed:(CCDatePickerViewController *)datePicker{
    [self.datePicker slideDownAndOut];
}

@end
