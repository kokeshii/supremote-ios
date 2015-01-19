//
//  SPTableViewController.h
//  Supremote
//
//  Created by Lambda Omega on 1/17/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPViewController.h"

@interface SPTableViewController : SPViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end
