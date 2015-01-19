//
//  SPTableViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/17/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPTableViewController.h"

@implementation SPTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
}


@end
