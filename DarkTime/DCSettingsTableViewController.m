//
//  DCSettingsTableViewController.m
//  DarkTime
//
//  Created by Eric Knapp on 9/23/11.
//  Copyright 2011 Eric Knapp. All rights reserved.
//

#import "DCSettingsTableViewController.h"
#import "DCClockState.h"
#import "DCClockConstants.h"
#import "DCSettingsViewController.h"
#import "DCFontSelectTableViewController.h"
#import "DCInfoViewController.h"
#import "DCHelpViewController.h"

@interface DCSettingsTableViewController()

@property (nonatomic, retain) NSArray *settingsArray;
@property (nonatomic, retain) UITableViewCell *fontCell;
@property (nonatomic, retain) UITableViewCell *helpCell;


- (void)createAmPmCell:(NSIndexPath *)indexPath 
                  cell:(UITableViewCell *)cell;

- (void)createSecondsCell:(NSIndexPath *)indexPath 
                     cell:(UITableViewCell *)cell;

- (void)createBrightnessCell:(NSIndexPath *)indexPath 
                     cell:(UITableViewCell *)cell;

- (void)createFontSelectionCell:(UITableViewCell *)cell;

- (void)createSuspendSleepCell:(NSIndexPath *)indexPath 
                          cell:(UITableViewCell *)cell;

- (void)createHelpSelectionCell:(UITableViewCell *)cell 
                      indexPath:(NSIndexPath *)indexPath;
@end

@implementation DCSettingsTableViewController

@synthesize clockState = _clockState;
@synthesize settingsArray = _settingsArray;
@synthesize fontCell = _fontCell;
@synthesize helpCell = _helpCell;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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

    self.title = @"Clock Settings";
    
    
    NSDictionary *ampmSection = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"AM/PM", DCSettingsTableViewHeader,
                                 @"Display AM/PM", DCSettingsTableViewCellText,
                                 @"", DCSettingsTableViewFooter,
                                 @"switch", DCSettingsTableViewCellIdentifier,
                                 nil];

    NSDictionary *secondsSection = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Seconds", DCSettingsTableViewHeader,
                                 @"Display Seconds", DCSettingsTableViewCellText,
                                 @"", DCSettingsTableViewFooter,
                                 @"switch", DCSettingsTableViewCellIdentifier,
                                 nil];

    NSDictionary *brightnessSection = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"Brightness", DCSettingsTableViewHeader,
                                    @"Adjust Brightness", DCSettingsTableViewCellText,
                                    @"You can also swipe left and right on the clock screen to adjust brightness.", DCSettingsTableViewFooter,
                                    @"slider", DCSettingsTableViewCellIdentifier,
                                    nil];

    NSDictionary *fontSection = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    @"Select Font", DCSettingsTableViewHeader,
                                    @"", DCSettingsTableViewCellText,
                                    @"", DCSettingsTableViewFooter,
                                    @"disclosure", DCSettingsTableViewCellIdentifier,
                                    nil];

    NSDictionary *sleepSection = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 @"Sleep", DCSettingsTableViewHeader,
                                 @"Suspend Sleep", DCSettingsTableViewCellText,
                                 @"Caution: this may affect battery life if not using power source.", DCSettingsTableViewFooter,
                                 @"switch", DCSettingsTableViewCellIdentifier,
                                 nil];

    NSDictionary *helpSection = [[NSDictionary alloc] initWithObjectsAndKeys:
                                  @"Help", DCSettingsTableViewHeader,
                                  @"Dark Time Help", DCSettingsTableViewCellText,
                                  @"", DCSettingsTableViewFooter,
                                  @"disclosure", DCSettingsTableViewCellIdentifier,
                                  nil];

    NSArray *sections = [[NSArray alloc] initWithObjects:
                         ampmSection, 
                         secondsSection, 
                         brightnessSection,
                         fontSection,
                         sleepSection,
                         helpSection,
                         nil];

    self.settingsArray = sections;
    
    
    [ampmSection release];
    [secondsSection release];
    [brightnessSection release];
    [fontSection release];
    [sleepSection release];
    [helpSection release];
    [sections release];
}


-(void)updateFontCellDisplay
{

    if (self.fontCell) {
        self.fontCell.textLabel.text = self.clockState.currentFontName;
        self.fontCell.textLabel.font = [self.clockState.currentFont fontWithSize:18];
    }

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    self.settingsArray = nil;
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = [self.settingsArray objectAtIndex:section];
    
    return [sectionDictionary objectForKey:DCSettingsTableViewHeader];

}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSDictionary *sectionDictionary = [self.settingsArray objectAtIndex:section];
    
    return [sectionDictionary objectForKey:DCSettingsTableViewFooter];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [self.settingsArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return 1;
}

#pragma mark - Cell Configuration

- (void)createAmPmCell:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    UISwitch *cellSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
    cell.textLabel.text = [[self.settingsArray objectAtIndex:indexPath.section] 
                           objectForKey:DCSettingsTableViewCellText];
    
    [cellSwitch addTarget:self 
                   action:@selector(toggleAmPm:) 
         forControlEvents:UIControlEventValueChanged];
    
    cellSwitch.on = self.clockState.displayAmPm;
    cell.accessoryView = cellSwitch;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)createSecondsCell:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    UISwitch *cellSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
    cell.textLabel.text = [[self.settingsArray objectAtIndex:indexPath.section] 
                           objectForKey:DCSettingsTableViewCellText];
    
    [cellSwitch addTarget:self 
                   action:@selector(toggleSeconds:) 
         forControlEvents:UIControlEventValueChanged];
    
    cellSwitch.on = self.clockState.displaySeconds;
    cell.accessoryView = cellSwitch;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    

}

- (void)createBrightnessCell:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    CGRect sliderRect = CGRectMake(170, 0, 280, 45);
    UISlider *slider = [[[UISlider alloc] initWithFrame:sliderRect] autorelease];
    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;
    
    NSString *path = [[NSBundle mainBundle] 
                      pathForResource:@"brightness-dim" 
                      ofType:@"png"];

    UIImage *dim = [[UIImage alloc] initWithContentsOfFile:path];
    
    slider.minimumValueImage = dim;
    
    [dim release];
    
    path = [[NSBundle mainBundle] 
            pathForResource:@"brightness-bright" 
            ofType:@"png"];
    
    UIImage *bright = [[UIImage alloc] initWithContentsOfFile:path];
    
    slider.maximumValueImage = bright;
    [bright release];
    

    cell.textLabel.text = [[self.settingsArray objectAtIndex:indexPath.section] 
                           objectForKey:DCSettingsTableViewCellText];
    
    
    [slider addTarget:self 
                   action:@selector(adjustBrightness:) 
         forControlEvents:UIControlEventValueChanged];
    
    slider.value = self.clockState.clockBrightnessLevel;
    
    [cell.contentView addSubview:slider];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
}

- (void)createFontSelectionCell:(UITableViewCell *)cell
{
//    NSLog(@"in createFontSelectionCell: %@", self.clockState.currentFontName);
    cell.textLabel.text = self.clockState.currentFontName;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.textLabel.font = [self.clockState.currentFont fontWithSize:18];
    self.fontCell = cell;

}

- (void)createSuspendSleepCell:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell
{
    UISwitch *cellSwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
    cell.textLabel.text = [[self.settingsArray objectAtIndex:indexPath.section] 
                           objectForKey:DCSettingsTableViewCellText];
    
    [cellSwitch addTarget:self 
                   action:@selector(toggleSuspendSleep:) 
         forControlEvents:UIControlEventValueChanged];
    
    cellSwitch.on = self.clockState.suspendSleep;
    cell.accessoryView = cellSwitch;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    

}

- (void)createHelpSelectionCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    //    NSLog(@"in createFontSelectionCell: %@", self.clockState.currentFontName);
    cell.textLabel.text = [[self.settingsArray objectAtIndex:indexPath.section] 
                           objectForKey:DCSettingsTableViewCellText];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    self.helpCell = cell;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView 
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [[self.settingsArray objectAtIndex:indexPath.section] 
                                objectForKey:DCSettingsTableViewCellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                       reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if (indexPath.section == DCDarkTimeSettingsRowDisplayAmPm) {
        [self createAmPmCell:indexPath cell:cell];
    } else if (indexPath.section == DCDarkTimeSettingsRowDisplaySeconds) {
        [self createSecondsCell:indexPath cell:cell];
    } else if (indexPath.section == DCDarkTimeSettingsRowAdjustBrightness) {
        [self createBrightnessCell:indexPath cell:cell];
    } else if (indexPath.section == DCDarkTimeSettingsRowFontSelector) {
        [self createFontSelectionCell:cell];
    } else if (indexPath.section == DCDarkTimeSettingsRowSuspendSleep) {
        [self createSuspendSleepCell:indexPath cell:cell];
    } else if (indexPath.section == DCDarkTimeSettingsRowHelp) {
        [self createHelpSelectionCell:cell indexPath:indexPath];
    }
        
    return cell;
}

-(void)toggleAmPm:(id)sender
{
    UISwitch *ampmSwitch = (UISwitch *)sender;

    self.clockState.displayAmPm = ampmSwitch.on;
}

-(void)toggleSeconds:(id)sender
{
    UISwitch *secondsSwitch = (UISwitch *)sender;
    self.clockState.displaySeconds = secondsSwitch.on;
}

-(void)adjustBrightness:(id)sender
{
    UISlider *brightnessSlider = (UISlider *)sender;
    
    CGFloat newBrightness;
    
    if (brightnessSlider.value < DCMinimumScreenBrightness) {
        newBrightness = DCMinimumScreenBrightness;
    } else {
        newBrightness = brightnessSlider.value;
    }
    
    self.clockState.clockBrightnessLevel = newBrightness;
}

-(void)toggleSuspendSleep:(id)sender
{
    UISwitch *sleepSwitch = (UISwitch *)sender;
    self.clockState.suspendSleep = sleepSwitch.on;
}

#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == DCDarkTimeSettingsRowFontSelector) {
        
        DCFontSelectTableViewController *controller = [[DCFontSelectTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        controller.clockState = self.clockState;
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.section == DCDarkTimeSettingsRowHelp) {
        DCInfoViewController *controller = [[DCInfoViewController alloc] initWithNibName:nil bundle:nil];
//        DCHelpViewController *controller = [[DCHelpViewController alloc] initWithNibName:nil bundle:nil];
        
        [self.navigationController pushViewController:controller animated:YES];
        [controller release];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
         
}

-(void)dealloc
{
    [_fontCell release];
    [_helpCell release];
    [_clockState release];
    [_settingsArray release];
    
    [super dealloc];
}

@end
