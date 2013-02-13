//
//  CCDateDay.h
//  DatePicker
//
//  Created by chase wasden on 2/12/13.
//  Copyright (c) 2013 chase wasden. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CCDateDay;
@protocol CCDateDayDelegate <NSObject>
-(void)dateDayTapped:(CCDateDay *)dateDay;
@end

@interface CCDateDay : UIView
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (strong, nonatomic) NSDate *date;
@property (weak, nonatomic) id<CCDateDayDelegate> delegate;
-(void)setLightText:(BOOL)light;
- (IBAction)dateButtonTapped:(id)sender;
-(void)setSelected:(BOOL)selected;
-(void)indicateDayHasItems:(BOOL)indicate;
@property (weak, nonatomic) IBOutlet UIImageView *hasItemsIndicator;

@end
