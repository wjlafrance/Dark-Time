//
//  DCFontSelectTableViewController.h
//  DarkTime
//
//  Created by Eric Knapp on 9/24/11.
//  Copyright 2011 Eric Knapp. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DCClockState;

@interface DCFontSelectTableViewController : UITableViewController

@property (nonatomic, strong) DCClockState *clockState;
@property (nonatomic, strong) UITableViewCell *currentCheckedCell;


@end
