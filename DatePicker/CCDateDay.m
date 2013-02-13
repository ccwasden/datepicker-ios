//
//  CCDateDay.m
//  DatePicker
//
//  Created by chase wasden on 2/12/13.
//  Copyright (c) 2013 chase wasden. All rights reserved.
//

#import "CCDateDay.h"

@implementation CCDateDay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setLightText:(BOOL)light {
    if(light) {
        UIColor * color = [UIColor colorWithWhite:.84 alpha:1];
        [self.dateButton setTitleColor:color forState:UIControlStateNormal];
        self.hasItemsIndicator.image = [UIImage imageNamed:@"ccdate_littledot-disabled.png"];
    }
    else {
        UIColor * color = [UIColor colorWithWhite:.3 alpha:1];
        [self.dateButton setTitleColor:color forState:UIControlStateNormal];
        self.hasItemsIndicator.image = [UIImage imageNamed:@"ccdate_littledot.png"];
    }
}

- (IBAction)dateButtonTapped:(id)sender {
    [self.delegate dateDayTapped:self];
}

-(void)setSelected:(BOOL)selected{
    if(selected) {
        [self setBackgroundColor:[UIColor colorWithRed:89/255.0 green:118/255.0 blue:169/255.0 alpha:1]];
        [self.dateButton setSelected:YES];
        [self.dateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self.dateButton setSelected:NO];
        [self.dateButton setTitleColor:[UIColor colorWithWhite:.3 alpha:1] forState:UIControlStateNormal];
    }
}

-(void)indicateDayHasItems:(BOOL)indicate {
    self.hasItemsIndicator.hidden = !indicate;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
