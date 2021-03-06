//
//  DCDarkClockViewController.m
//  DarkTimePhone
//
//  Created by Eric Knapp on 6/1/11.
//  Copyright 2011 Dovetail Computing, Inc. All rights reserved.
//

@import CoreText;
#import "DCDarkClockViewController.h"
#import "DCClockState.h"
#import "DCSettingsViewController.h"
#import "DCInfoViewController.h"
#import "DCClockConstants.h"
#import "DCSettingsTableViewController.h"
#import "DCIFontManager.h"
#import "DCIDashedDividerView.h"


@interface DCDarkClockViewController ()

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *ampmLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondsLabel;
@property (nonatomic, weak) IBOutlet UIButton *clockSettingsButton;

@property (nonatomic, weak) IBOutlet UILabel *ampmLabelPortrait;
@property (nonatomic, weak) IBOutlet UILabel *secondsLabelPortrait;
@property (nonatomic, weak) IBOutlet UIButton *clockSettingsButtonPortrait;

@property (strong, nonatomic) UINavigationController *settingsNavController;
@property (assign, nonatomic) CGFloat buttonAlphaLandscape;
@property (assign, nonatomic) CGFloat dottedLineAlpha;

-(IBAction)settingsButtonTapped:(id)sender;
-(void)updateDisplayFont;
- (void)createLeftSwipeRecognizer;
- (void)createRightSwipeRecognizer;
- (void)createUpSwipeRecognizer;
- (void)createDownSwipeRecognizer;

-(void)handleBrightnessSwipeRight:(UISwipeGestureRecognizer *)recognizer;
-(void)handleBrightnessSwipeLeft:(UISwipeGestureRecognizer *)recognizer;
-(void)updateClockOnLaunch;

@end


@implementation DCDarkClockViewController


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen]applicationFrame];
    self.landscapeView.frame = [[UIScreen mainScreen]applicationFrame];
    self.portraitView.frame = [[UIScreen mainScreen]applicationFrame];

    [self.view addSubview:self.landscapeView];
    [self.view addSubview:self.portraitView];
    
    [self adjustHourMinuteLabelsForScreenHeight];
    [self adjustDashedLiveViewForScreenHeight];

    
    self.timeLabel.alpha = 0.0;
    self.ampmLabel.alpha = 0.0;
    self.secondsLabel.alpha = 0.0;
    self.clockSettingsButton.alpha = 0.0;
    self.timeLabelHoursPortrait.alpha = 0.0;
    self.timeLabelMinutesPortrait.alpha = 0.0;
    self.ampmLabelPortrait.alpha = 0.0;
    self.secondsLabelPortrait.alpha = 0.0;
    self.clockSettingsButtonPortrait.alpha = 0.0;
    self.dottedLine.alpha = 0.0;
    
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];

    
    self.appTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                     target:self
                                                   selector:@selector(updateClock)
                                                   userInfo:nil
                                                    repeats:YES];
    
    [self createRightSwipeRecognizer];
    [self createLeftSwipeRecognizer];
    [self createUpSwipeRecognizer];
    [self createDownSwipeRecognizer];
   
    [self.clockState.fontManager addObserver:self 
                                  forKeyPath:@"currentFont" 
                                     options:NSKeyValueObservingOptionNew
                                     context:NULL];
        
    [self.clockState changeFontWithFontIndex:self.clockState.fontManager.currentFontIndex];
    [self updateDisplayFont];
    self.clockState.timeLabelPortraitFrame = self.timeLabelMinutesPortrait.frame;
    self.clockState.timeHourLabelPortraitFrame = self.timeLabelHoursPortrait.frame;
    
    [self updateClockOnLaunch];
    
    self.clockState.currentOrientation = self.interfaceOrientation;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        self.timeLabel.alpha = 1.0;
        self.ampmLabel.alpha = 1.0;
        self.secondsLabel.alpha = 1.0;
        self.clockSettingsButton.alpha = 1.0;
        [self.view bringSubviewToFront:self.landscapeView];
    } else {
        self.timeLabelHoursPortrait.alpha = 1.0;
        self.timeLabelMinutesPortrait.alpha = 1.0;
        self.ampmLabelPortrait.alpha = 1.0;
        self.secondsLabelPortrait.alpha = 1.0;
        self.clockSettingsButtonPortrait.alpha = 1.0;
        self.dottedLine.alpha = 1.0;
        [self.view bringSubviewToFront:self.portraitView];
    }

    [self.view layoutIfNeeded];

//    [UIViewController attemptRotationToDeviceOrientation];
    
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    
    [self.settingsEditor dismissModalViewControllerAnimated:YES];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    self.settingsEditor = nil;
    
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    NSLog(@"orientation will %d, to %d", (int) self.interfaceOrientation, (int) toInterfaceOrientation);
    self.clockState.currentOrientation = toInterfaceOrientation;
    
    [self.clockState changeFontWithFontIndex:self.clockState.fontManager.currentFontIndex];

    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        self.timeLabel.alpha = 0.0;
        self.ampmLabel.alpha = 0.0;
        self.secondsLabel.alpha = 0.0;
        self.clockSettingsButton.alpha = 0.0;
        [self.view bringSubviewToFront:self.portraitView];
    } else {
        self.timeLabelHoursPortrait.alpha = 0.0;
        self.timeLabelMinutesPortrait.alpha = 0.0;
        self.ampmLabelPortrait.alpha = 0.0;
        self.secondsLabelPortrait.alpha = 0.0;
        self.clockSettingsButtonPortrait.alpha = 0.0;
        self.dottedLine.alpha = 0.0;
        [self.view bringSubviewToFront:self.landscapeView];
    }

}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    
    NSLog(@"orientation did %d, from %d", (int) self.interfaceOrientation, (int) fromInterfaceOrientation);
    
    [self adjustHourMinuteLabelsForScreenHeight];
    
    self.clockState.currentOrientation = self.interfaceOrientation;
    if (UIInterfaceOrientationIsLandscape(fromInterfaceOrientation)) {
        [UIView animateWithDuration:0.3 animations:^{
            self.timeLabelHoursPortrait.alpha = 1.0;
            self.timeLabelMinutesPortrait.alpha = 1.0;
            self.ampmLabelPortrait.alpha = 1.0;
            self.secondsLabelPortrait.alpha = 1.0;
            self.clockSettingsButtonPortrait.alpha = self.buttonAlphaLandscape;
            self.dottedLine.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.timeLabel.alpha = 1.0;
            self.ampmLabel.alpha = 1.0;
            self.secondsLabel.alpha = 1.0;
            self.clockSettingsButton.alpha = self.buttonAlphaLandscape;
        }];
    }
    
//    UIFont *font = self.timeLabelHoursPortrait.font;
//    CGFloat width = self.timeLabelHoursPortrait.frame.size.width;
//    CGFloat actualSize;
//    CGSize size = [@"20" sizeWithFont:font
//                             minFontSize:10
//                          actualFontSize:&actualSize
//                                forWidth:width
//                           lineBreakMode:UILineBreakModeHeadTruncation];
//    
//    NSLog(@"actual font size hours portrait %f", actualSize);
    
//    width = self.timeLabel.frame.size.width;
//    font = self.timeLabel.font;
//    size = [@"20" sizeWithFont:font
//                   minFontSize:10
//                actualFontSize:&actualSize
//                      forWidth:width
//                 lineBreakMode:UILineBreakModeHeadTruncation];
//    
//    NSLog(@"actual font size time label %f", actualSize);
//    NSLog(@"==========================================");
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object 
                        change:(NSDictionary *)change 
                       context:(void *)context
{
    
    if ([keyPath isEqualToString:@"currentFont"]) {

        [self updateDisplayFont];
        
        if (self.settingsEditor) {
            [self.settingsEditor updateFontCellDisplay];
        }
    } 
    
}

#pragma mark - Create Recognizer methods

- (void)createLeftSwipeRecognizer
{
    self.brightnessSwipeLeft = 
    [[UISwipeGestureRecognizer alloc] 
     initWithTarget:self 
     action:@selector(handleBrightnessSwipeLeft:)];
    
    self.brightnessSwipeLeft.numberOfTouchesRequired = 1;
    self.brightnessSwipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.view addGestureRecognizer:self.brightnessSwipeLeft];
}

- (void)createRightSwipeRecognizer
{
    self.brightnessSwipeRight = 
            [[UISwipeGestureRecognizer alloc] 
             initWithTarget:self 
             action:@selector(handleBrightnessSwipeRight:)];
    
    self.brightnessSwipeRight.numberOfTouchesRequired = 1;
    self.brightnessSwipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:self.brightnessSwipeRight];
}

- (void)createUpSwipeRecognizer
{
    self.brightnessSwipeUp = 
            [[UISwipeGestureRecognizer alloc] 
             initWithTarget:self 
             action:@selector(handleBrightnessSwipeRight:)];
    
    self.brightnessSwipeUp.numberOfTouchesRequired = 1;
    self.brightnessSwipeUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.view addGestureRecognizer:self.brightnessSwipeUp];
}

- (void)createDownSwipeRecognizer
{
    self.brightnessSwipeDown = 
    [[UISwipeGestureRecognizer alloc] 
     initWithTarget:self 
     action:@selector(handleBrightnessSwipeLeft:)];
    
    self.brightnessSwipeDown.numberOfTouchesRequired = 1;
    self.brightnessSwipeDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:self.brightnessSwipeDown];
}



#pragma mark - UI methods

-(void)handleBrightnessSwipeRight:(UISwipeGestureRecognizer *)recognizer
{
    
    if (self.clockState.fontEditorDisplayed) {
        return;
    }

    CGFloat currentBrightness = self.clockState.clockBrightnessLevel;
    
    CGFloat brightness = currentBrightness + 0.05;
    
    [self adjustScreenBrightness:brightness];

}

-(void)handleBrightnessSwipeLeft:(UISwipeGestureRecognizer *)recognizer
{

    if (self.clockState.fontEditorDisplayed) {
        return;
    }
    
    CGFloat currentBrightness = self.clockState.clockBrightnessLevel;
    
    CGFloat brightness = currentBrightness - 0.05;
    [self adjustScreenBrightness:brightness];

}

- (void)adjustScreenBrightness:(CGFloat)brightness
{
    if (brightness > 1.0) {
        brightness = 1.0;
    } else if (brightness <= DCMinimumScreenBrightness) {
        brightness = DCMinimumScreenBrightness;
    }
    
    [UIScreen mainScreen].brightness = brightness;
    
    self.clockState.clockBrightnessLevel = brightness;
    [self updateClockDisplayColorWithBrightness:brightness];
    [[NSUserDefaults standardUserDefaults] setFloat:brightness forKey:@"clockBrightnessLevel"];
}


- (IBAction)settingsButtonTapped:(id)sender 
{
    self.settingsEditor = [[DCSettingsTableViewController alloc]
                                        initWithNibName:@"DCSettingsTableViewController"
                                        bundle:nil];
    self.settingsEditor.clockViewController = self;
//    self.settingsEditor.modalPresentationStyle = self.modalStyle;
    self.settingsEditor.clockState = self.clockState;
    
    self.settingsNavController = [[UINavigationController alloc] 
                                  initWithRootViewController:self.settingsEditor];
    self.settingsNavController.navigationBar.barStyle = UIBarStyleBlack;
    self.settingsNavController.modalPresentationStyle = self.modalStyle;

    [self presentViewController:self.settingsNavController animated:YES 
                     completion:^{ }];
    
}


-(void)updateDisplayFontWithFontSize:(NSInteger)fontSize
{

    self.timeLabel.font = self.clockState.fontManager.currentFont;
    self.timeLabelHoursPortrait.font = self.clockState.fontManager.currentFont;
    self.timeLabelMinutesPortrait.font = self.clockState.fontManager.currentFont;
    
    self.ampmLabel.font = [self.clockState.fontManager.currentFont fontWithSize:fontSize];
    self.ampmLabelPortrait.font = [self.clockState.fontManager.currentFont fontWithSize:fontSize];
    
    self.secondsLabel.font = [self.clockState.fontManager.currentFont fontWithSize:fontSize];
    self.secondsLabelPortrait.font = [self.clockState.fontManager.currentFont fontWithSize:fontSize];
    
    if (UIInterfaceOrientationIsPortrait(self.clockState.currentOrientation)) {

        self.timeLabelMinutesPortrait.frame = self.clockState.timeLabelPortraitFrame;
        CGRect adjustedFrame = [self.clockState.fontManager adjustMinuteFrame:self.timeLabelMinutesPortrait.frame 
                                                                     withFont:self.clockState.fontManager.currentFont];
        self.timeLabelMinutesPortrait.frame = adjustedFrame;
        
        self.timeLabelHoursPortrait.frame = self.clockState.timeHourLabelPortraitFrame;
        
        CGRect adjustedHourFrame = [self.clockState.fontManager adjustHourFrame:self.timeLabelHoursPortrait.frame 
                                                                         withFont:self.clockState.fontManager.currentFont];
        self.timeLabelHoursPortrait.frame = adjustedHourFrame;
        
    }
    
    
        
}

-(void)updateDisplayFont
{
    
}

-(void)updateClockDisplayColorWithBrightness:(CGFloat)brightness
{
    CGFloat redFactor;
    UIColor *color;
    
    if (brightness <= 0.6) {
        redFactor = brightness + 0.2;
    } else {
        redFactor = 1.0;
    }

    color = [UIColor colorWithRed:redFactor green:0.0 blue:0.0 alpha:1.0];
    self.timeLabel.textColor = color;
    self.timeLabelHoursPortrait.textColor = color;
    self.timeLabelMinutesPortrait.textColor = color;
    self.ampmLabel.textColor = color;
    self.ampmLabelPortrait.textColor = color;
    self.secondsLabel.textColor = color;
    self.secondsLabelPortrait.textColor = color;
    self.clockSettingsButton.alpha = redFactor + 0.1;
    self.clockSettingsButtonPortrait.alpha = redFactor + 0.1;
    self.dottedLine.dashedLineColor = color;
    [self.dottedLine setNeedsDisplay];
    
    self.buttonAlphaLandscape = self.clockSettingsButton.alpha;
        
}



- (void)switchToOrientationView:(UIInterfaceOrientation)interfaceOrientation
{
    [self.clockState changeFontWithFontIndex:self.clockState.fontManager.currentFontIndex];
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
//         [self.view bringSubviewToFront:self.portraitView];
         [UIView animateWithDuration:0.8 animations:^{
             self.timeLabelHoursPortrait.alpha = 1.0;
             self.timeLabelMinutesPortrait.alpha = 1.0;
             self.ampmLabelPortrait.alpha = 1.0;
             self.secondsLabelPortrait.alpha = 1.0;
             self.clockSettingsButtonPortrait.alpha = self.buttonAlphaLandscape;
             self.dottedLine.alpha = 1.0;
             [self.dottedLine setNeedsDisplay];
         }];
    } else {
//        [self.view bringSubviewToFront:self.landscapeView];
        [UIView animateWithDuration:0.8 animations:^{
            self.timeLabel.alpha = 1.0;
            self.ampmLabel.alpha = 1.0;
            self.secondsLabel.alpha = 1.0;
            self.clockSettingsButton.alpha = self.buttonAlphaLandscape;
        }];
    }
    
}


#pragma mark - View Gesture methods

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer 
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}


-(void)changeDisplayBrightnessWithBrightness:(CGFloat)brightness
{

}

#pragma mark - Clock Methods

- (void)adjustHourMinuteLabelsForScreenHeight
{
    NSLog(@"\n\tFunction\t=>\t%s\n\tLine\t\t=>\t%d", __func__, __LINE__);
    CGFloat halfHeight = [[UIScreen mainScreen]applicationFrame].size.height / 2;
    CGFloat width = [[UIScreen mainScreen]applicationFrame].size.width;
    
    CGFloat adjustFactor = 20.0;
    
    CGRect hourFrame = CGRectMake(0,
                                  adjustFactor,
                                  width,
                                  halfHeight - adjustFactor);
    CGRect minuteFrame = CGRectMake(0,
                                    halfHeight - (adjustFactor / 2),
                                    width,
                                    halfHeight - adjustFactor);
    
    
    self.timeLabelHoursPortrait.frame = hourFrame;
    self.timeLabelMinutesPortrait.frame = minuteFrame;
}

-(void)adjustDashedLiveViewForScreenHeight
{
    CGFloat halfHeight = [[UIScreen mainScreen]applicationFrame].size.height / 2;
    CGFloat width = [[UIScreen mainScreen]applicationFrame].size.width;
    
    CGFloat dashedViewY = halfHeight - 17;
    
    CGRect dashedViewFrame = CGRectMake(9,
                                        dashedViewY,
                                        width,
                                        self.clockState.dashedlineHeight);
    
    self.dottedLine.frame = dashedViewFrame;
}

-(void)updateClockOnLaunch
{

    NSDate* now = [NSDate date];
    NSInteger second = [[self.calendar components:NSCalendarUnitSecond fromDate:now] second];
    self.savedSeconds = second;
    self.timeLabel.text = [self.clockState currentTimeString];
    self.secondsLabel.text = [self.clockState currentSecondsString];
    self.ampmLabel.text = [self.clockState currentAmPmString];    
    self.timeLabelHoursPortrait.text = [self.clockState currentHourString];
    self.timeLabelMinutesPortrait.text = [self.clockState currentMinutesString];
    self.secondsLabelPortrait.text = [self.clockState currentSecondsString];
    self.ampmLabelPortrait.text = [self.clockState currentAmPmString];
}


- (void)updateClock
{

    NSDate* now = [NSDate date];
    NSInteger second = [[self.calendar components:NSCalendarUnitSecond fromDate:now] second];
    
    if (second == self.savedSeconds) {
        return;
    }
    
    self.savedSeconds = second;
    
    if (self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || self.clockState.currentOrientation == UIInterfaceOrientationLandscapeRight) {
        self.timeLabel.text = [self.clockState currentTimeString];
        self.secondsLabel.text = [self.clockState currentSecondsString];
        self.ampmLabel.text = [self.clockState currentAmPmString];
    } else {
        self.timeLabelHoursPortrait.text = [self.clockState currentHourString];
        self.timeLabelMinutesPortrait.text = [self.clockState currentMinutesString];
        self.secondsLabelPortrait.text = [self.clockState currentSecondsString];
        self.ampmLabelPortrait.text = [self.clockState currentAmPmString];
    }
        
}






@end
