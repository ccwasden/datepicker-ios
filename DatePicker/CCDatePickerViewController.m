//
//  CCDatePickerViewController.m
//  DatePicker
//
//  Created by chase wasden on 2/10/13.
//  Copyright (c) 2013 chase wasden. All rights reserved.
//

#import "CCDatePickerViewController.h"


@interface CCDatePickerViewController () {
    int _weeksOnCalendar;
    int _bufferDaysBeginning;
    int _daysInMonth;
    NSDate * _dateNoTime;
    NSCalendar * _calendar;
    BOOL _allowClearDate;
    BOOL (^_dateHasItemsCallback)(NSDate *);
}
@property (nonatomic, strong) UIView * shade;
@property (nonatomic, strong) NSDate * firstOfCurrentMonth;
@property (nonatomic, strong) CCDateDay * currentDay;
@property (nonatomic, strong) NSDate * internalDate;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIButton *prevBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UIButton *clearBtn;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (strong, nonatomic) IBOutlet UIView *calendarDaysView;
@property (weak, nonatomic) IBOutlet UIView *weekdaysView;

- (IBAction)nextMonthPressed:(id)sender;
- (IBAction)prevMonthPressed:(id)sender;
- (IBAction)okPressed:(id)sender;
- (IBAction)clearPressed:(id)sender;
- (IBAction)closePressed:(id)sender;

-(void)redraw;

@end

@implementation CCDatePickerViewController
@synthesize date = _date;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        _allowClearDate = NO;
    }
    return self;
}

+(CCDatePickerViewController *)datePicker{
    return [[CCDatePickerViewController alloc] initWithNibName:@"CCDatePickerViewController" bundle:nil];
}

-(void)setAllowClearDate:(BOOL)allow{
    _allowClearDate = allow;
}

- (void)viewDidLoad
{
    [self configureButtonAppearances];
    if(_allowClearDate) [self showClearButton];
    else [self hideClearButton];
    [self addSwipeGestures];
    
    self.okBtn.enabled = [self shouldOkBeEnabled];
}


-(void)addSwipeGestures{
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionUp;
    [self.calendarDaysView addGestureRecognizer:swipeGesture];
    
    UISwipeGestureRecognizer *swipeGesture2 = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    swipeGesture2.direction = UISwipeGestureRecognizerDirectionDown;
    [self.calendarDaysView addGestureRecognizer:swipeGesture2];
}

-(void)handleSwipeGesture:(UISwipeGestureRecognizer *)sender{
    //Gesture detect - swipe up/down , can be recognized direction
    if(sender.direction == UISwipeGestureRecognizerDirectionUp){
        [self incrementMonth:1];
        [self slideTransitionViewInDirection:1];
    }
    else if(sender.direction == UISwipeGestureRecognizerDirectionDown){
        [self incrementMonth:-1];
        [self slideTransitionViewInDirection:-1];
    }
}

-(void)configureButtonAppearances {
    [super viewDidLoad];
    [[self.nextBtn imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[self.prevBtn imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[self.clearBtn imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[self.closeBtn imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[self.okBtn imageView] setContentMode: UIViewContentModeScaleAspectFit];
    
    UIImage * img = [self imageOfColor:[UIColor colorWithWhite:.8 alpha:1]];
    [self.clearBtn setBackgroundImage:img forState:UIControlStateHighlighted];
    [self.closeBtn setBackgroundImage:img forState:UIControlStateHighlighted];
    [self.okBtn setBackgroundImage:img forState:UIControlStateHighlighted];
    
    img = [self imageOfColor:[UIColor colorWithWhite:.94 alpha:1]];
    [self.nextBtn setBackgroundImage:img forState:UIControlStateHighlighted];
    [self.prevBtn setBackgroundImage:img forState:UIControlStateHighlighted];
}

-(UIImage *) imageOfColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,[color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

-(void)setDateHasItemsCallback:(BOOL (^)(NSDate * date))callback {
    _dateHasItemsCallback = callback;
}



// ------------------------------------------------------- //
// -------------------- Redraw Dates ---------------------- //

-(void)redraw{
    if(!self.firstOfCurrentMonth) [self setDisplayedMonthFromDate:[NSDate date]];
    for(UIView * view in self.calendarDaysView.subviews){ // clean view
        [view removeFromSuperview];
    }
    [self redrawDays];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM yyyy"];
    NSString *monthName = [formatter stringFromDate:self.firstOfCurrentMonth];
    self.monthLabel.text = monthName;
}

-(void)redrawDays {
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setDay:-_bufferDaysBeginning];
    NSDate * date = [_calendar dateByAddingComponents:offsetComponents toDate:self.firstOfCurrentMonth options:0];
    [offsetComponents setDay:1];
    UIView * container = self.calendarDaysView;
    CGRect containerFrame = container.frame;
    int areaWidth = containerFrame.size.width;
    int areaHeight = containerFrame.size.height;
    int cellWidth = areaWidth/7;
    int cellHeight = areaHeight/_weeksOnCalendar;
    int days = _weeksOnCalendar*7;
    int curY = (areaHeight - cellHeight*_weeksOnCalendar)/2;
    int origX = (areaWidth - cellWidth*7)/2;
    int curX = origX;
    [self redrawWeekdays:cellWidth];
    for(int i = 0; i < days; i++){
        // @beginning
        if(i && !(i%7)) {
            curX = origX;
            curY += cellHeight;
        }
        
        CCDateDay * day = [[[NSBundle mainBundle] loadNibNamed:@"CCDateDay" owner:self options:nil] objectAtIndex:0];
        [day setLightText:![self dateInCurrentMonth:date]];
        day.frame = CGRectMake(curX, curY, cellWidth, cellHeight);
        day.delegate = self;
        day.date = [date dateByAddingTimeInterval:0];
        [day indicateDayHasItems:(_dateHasItemsCallback && _dateHasItemsCallback(date))];
        
        if(_internalDate && ![date timeIntervalSinceDate:_internalDate]) {
            [day setSelected:YES];
            self.currentDay = day;
        }
        
        NSDateComponents *comps = [_calendar components:NSDayCalendarUnit fromDate:date];
        [day.dateButton setTitle:[NSString stringWithFormat:@"%d",[comps day]]
                        forState:UIControlStateNormal];
        [self.calendarDaysView addSubview:day];
        
        // @end
        date = [_calendar dateByAddingComponents:offsetComponents toDate:date options:0];
        curX += cellWidth;
    }
}

-(void)redrawWeekdays:(int)dayWidth{
    if(!self.weekdaysView.subviews.count) {
        CGSize fullSize = self.weekdaysView.frame.size;
        int curX = (fullSize.width - 7*dayWidth)/2;
        NSDateComponents * comps = [_calendar components:NSDayCalendarUnit fromDate:[NSDate date]];
        [comps setDay:0];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:1];
        [df setDateFormat:@"EE"];
        NSDate * date = [_calendar dateFromComponents:comps];
        for(int i = 0; i < 7; i++){
            UILabel * dayLabel = [[UILabel alloc] initWithFrame:CGRectMake(curX, 0, dayWidth, fullSize.height)];
            dayLabel.textAlignment = NSTextAlignmentCenter;
            dayLabel.font = [UIFont systemFontOfSize:12];
            [self.weekdaysView addSubview:dayLabel];
            dayLabel.text = [df stringFromDate:date];
            dayLabel.textColor = [UIColor grayColor];
            date = [_calendar dateByAddingComponents:offsetComponents toDate:date options:0];
            curX+=dayWidth;
        }
    }
}




// ------------------------------------------------------- //
// -------------------- Date Set, etc. ------------------- //

-(void)setDate:(NSDate *)date{
    _date = date;
    _dateNoTime = !date ? nil : [self dateWithOutTime:date];
    self.internalDate = [_dateNoTime dateByAddingTimeInterval:0];
}

-(NSDate *)date{
    if(!self.internalDate) return nil;
    else if(!_date) return self.internalDate;
    else {
        int ymd = NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit;
        NSDateComponents* internalComps = [_calendar components:ymd fromDate:self.internalDate];
        int time = NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSTimeZoneCalendarUnit;
        NSDateComponents* origComps = [_calendar components:time fromDate:_date];
        [origComps setDay:[internalComps day]];
        [origComps setMonth:[internalComps month]];
        [origComps setYear:[internalComps year]];
        return [_calendar dateFromComponents:origComps];
    }
}

-(BOOL)shouldOkBeEnabled{
    float diff = [self.internalDate timeIntervalSinceDate:_dateNoTime];
    return (self.internalDate && _dateNoTime && diff != 0)
        || (self.internalDate && !_dateNoTime)
        || (!self.internalDate && _dateNoTime);
}

-(void)setInternalDate:(NSDate *)internalDate{
    _internalDate = internalDate;
    self.clearBtn.enabled = !!internalDate;
    self.okBtn.enabled = [self shouldOkBeEnabled];
    if(internalDate){
        [self setDisplayedMonthFromDate:internalDate];
    }
    else {
        [self.currentDay setSelected:NO];
        self.currentDay =  nil;
    }
}

-(void)setDisplayedMonth:(int)month year:(int)year{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM"];
    self.firstOfCurrentMonth = [df dateFromString: [NSString stringWithFormat:@"%d-%@%d", year, (month<10?@"0":@""), month]];
    //    NSLog(@"first of month: %@", self.firstOfCurrentMonth);
    [self storeDateInformation];
}

-(void)setDisplayedMonthFromDate:(NSDate *)date{
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit fromDate:date];
    [self setDisplayedMonth:[comps month] year:[comps year]];
}

-(void)storeDateInformation{
    NSDateComponents *comps = [_calendar components:NSWeekdayCalendarUnit | NSDayCalendarUnit fromDate:self.firstOfCurrentMonth];
    NSCalendar *c = [NSCalendar currentCalendar];
    NSRange days = [c rangeOfUnit:NSDayCalendarUnit
                           inUnit:NSMonthCalendarUnit
                          forDate:self.firstOfCurrentMonth];
    
    int bufferDaysBeginning = [comps weekday]-1;
    int daysInMonthWithBuffer = days.length + bufferDaysBeginning;
    int numberOfWeeks = daysInMonthWithBuffer / 7;
    if(daysInMonthWithBuffer % 7) numberOfWeeks++;
    
    //    _weeksOnCalendar = numberOfWeeks;
    _weeksOnCalendar = 6;
    _bufferDaysBeginning = bufferDaysBeginning;
    _daysInMonth = days.length;
}

-(void)incrementMonth:(int)incrValue{
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setMonth:incrValue];
    NSDate * incrementedMonth = [_calendar dateByAddingComponents:offsetComponents toDate:self.firstOfCurrentMonth options:0];
    [self setDisplayedMonthFromDate:incrementedMonth];
}




// ------------------------------------------------------- //
// -------------------- User Events ---------------------- //

-(void)dateDayTapped:(CCDateDay *)dateDay{
    if(![self dateInCurrentMonth:dateDay.date]){
        double direction = [dateDay.date timeIntervalSinceDate:self.firstOfCurrentMonth];
        self.internalDate = dateDay.date;
        [self slideTransitionViewInDirection:direction];
    }
    else if(!_internalDate || [_internalDate timeIntervalSinceDate:dateDay.date]){ // new date selected
        [self.currentDay setSelected:NO];
        [dateDay setSelected:YES];
        self.internalDate = dateDay.date;
        self.currentDay = dateDay;
    }
}

-(void)slideTransitionViewInDirection:(int)dir{
    dir = dir < 1 ? -1 : 1;
    CGRect origFrame = self.calendarDaysView.frame;
    CGRect outDestFrame = origFrame;
    outDestFrame.origin.y -= 20*dir;
    CGRect inStartFrame = origFrame;
    inStartFrame.origin.y += 20*dir;
    UIView *oldView = self.calendarDaysView;
    UIView *newView = self.calendarDaysView = [[UIView alloc] initWithFrame:inStartFrame];
    [self.view addSubview:newView];
    [self addSwipeGestures];
    newView.alpha = 0;
    [self redraw];
    [UIView animateWithDuration:.1 animations:^{
        newView.frame = origFrame;
        newView.alpha = 1;
        oldView.frame = outDestFrame;
        oldView.alpha = 0;
    } completion:^(BOOL finished) {
        [oldView removeFromSuperview];
    }];
}

- (IBAction)nextMonthPressed:(id)sender {
    [self incrementMonth:1];
    [self slideTransitionViewInDirection:1];
}

- (IBAction)prevMonthPressed:(id)sender {
    [self incrementMonth:-1];
    [self slideTransitionViewInDirection:-1];
}

- (IBAction)okPressed:(id)sender {
    if(self.okBtn.enabled)
        [self.delegate datePickerDonePressed:self];
}

- (IBAction)clearPressed:(id)sender {
    if(self.clearBtn.enabled){
        self.internalDate = nil;
        [self.currentDay setSelected:NO];
        self.currentDay = nil;
    }
}

- (IBAction)closePressed:(id)sender {
    [self.delegate datePickerCancelPressed:self];
}



// ------------------------------------------------------- //
// -------------------- Slide In/Out --------------------- //

-(void)slideUpInView:(UIView *)view {
    [self slideUpInView:view withModalColor:[UIColor blackColor]];
}

-(void)slideUpInView:(UIView *)view withModalColor:(UIColor *)color{
    UIView * selfView = self.view;
    CGRect frame = selfView.frame;
    frame.origin.y = view.frame.size.height;
    selfView.frame = frame;
    [self redraw];
    
    UIView * shade = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.height, view.frame.size.width)];
    shade.backgroundColor = color;
    shade.alpha = 0;
    self.shade = shade;
    
    [view addSubview:shade];
    [view addSubview:selfView];
    
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = selfView.frame;
        frame.origin.y = view.frame.size.height-selfView.frame.size.height;
        selfView.frame = frame;
        shade.alpha = .5;
    }];
}

-(void)slideDownAndOut{
    UIView * selfView = self.view;
    UIView * shade = self.shade;
    
    [UIView animateWithDuration:.2 animations:^{
        CGRect frame = selfView.frame;
        frame.origin.y = selfView.superview.frame.size.height;
        selfView.frame = frame;
        shade.alpha = 0;
    } completion:^(BOOL finished) {
        [shade removeFromSuperview];
        [selfView removeFromSuperview];
    }];
}




// ------------------------------------------------------- //
// -------------- Hide/Show Clear Button ----------------- //

-(void) showClearButton {
    int width = self.view.frame.size.width;
    int buttonHeight = 37;
    int buttonWidth = (width-20)/3;
    int curX = (width - buttonWidth*3 - 10)/2;
    self.closeBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
    curX+=buttonWidth+5;
    self.clearBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
    curX+=buttonWidth+5;
    self.okBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
}

-(void) hideClearButton {
    int width = self.view.frame.size.width;
    int buttonHeight = 37;
    self.clearBtn.hidden = YES;
    int buttonWidth = (width-15)/2;
    int curX = (width - buttonWidth*2 - 5)/2;
    self.closeBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
    curX+=buttonWidth+5;
    self.okBtn.frame = CGRectMake(curX, 5, buttonWidth, buttonHeight);
}





// ------------------------------------------------------- //
// --------------------- Date Utils ---------------------- //

-(BOOL)dateInCurrentMonth:(NSDate *)date{
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [_calendar components:unitFlags fromDate:self.firstOfCurrentMonth];
    NSDateComponents* comp2 = [_calendar components:unitFlags fromDate:date];
    return [comp1 year]  == [comp2 year] && [comp1 month] == [comp2 month];
}

-(NSDate *)dateWithOutTime:(NSDate *)datDate {
    if( datDate == nil ) {
        datDate = [NSDate date];
    }
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:datDate];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
