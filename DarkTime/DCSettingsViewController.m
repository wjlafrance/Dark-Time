//
//  DCSettingsViewController.m
//  DarkTime
//
//  Created by Eric Knapp on 9/23/11.
//  Copyright 2011 Madison Area Technical College. All rights reserved.
//

#import "DCSettingsViewController.h"
#import "DCSettingsTableViewController.h"
#import "DCClockState.h"
#import "DCInfoViewController.h"


@implementation DCSettingsViewController

@synthesize navigationController = _navigationController;
@synthesize clockState = _clockState;
@synthesize settingsTableViewController = _settingsTableViewController;
@synthesize infoController = _infoController;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
    
}

-(void)doneButtonTapped:(id)sender
{

    NSLog(@"in doneButtonTapped for settings");
    [self dismissModalViewControllerAnimated:YES];
    
    self.settingsTableViewController = nil;
    [self.infoController.infoWebView loadHTMLString:@"" baseURL:nil];
    self.infoController = nil;
    
}


-(void)displayInfoPage
{

    DCInfoViewController *controller = [[DCInfoViewController alloc] initWithNibName:nil bundle:nil];
    self.infoController = controller;
    [controller release];
    
    [self.navigationController pushViewController:self.infoController animated:YES];
    
}


-(void)updateFontCellDisplay
{
    [self.settingsTableViewController updateFontCellDisplay];
}

#pragma mark - View lifecycle

-(DCSettingsTableViewController *)createTableViewController
{
    DCSettingsTableViewController *tableViewController = [[[DCSettingsTableViewController alloc] 
                                                          initWithStyle:UITableViewStyleGrouped] autorelease];    
    
    tableViewController.clockState = self.clockState;

    return tableViewController;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    DCSettingsTableViewController *tableViewController = [self createTableViewController];

    self.settingsTableViewController = tableViewController;
        
    UINavigationController *navController = [[UINavigationController alloc] 
                                             initWithRootViewController:tableViewController];


    navController.navigationBar.barStyle = UIBarStyleBlack;
        
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" 
                                                             style:UIBarButtonItemStylePlain 
                                                            target:self 
                                                            action:@selector(doneButtonTapped:)];
    
    tableViewController.navigationItem.rightBarButtonItem = done;

    [done release];
   
    self.navigationController = navController;
    [navController release];
    
  
    [self.view addSubview:self.navigationController.view];
}

- (void)viewDidUnload
{

    [super viewDidUnload];

    self.navigationController = nil;
    self.clockState = nil;
    self.settingsTableViewController = nil;
    self.infoController = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft 
            || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (void)dealloc {
    [_navigationController release];
    [_clockState release];
    [_settingsTableViewController release];
    [_infoController release];
    
    [super dealloc];
}
@end
