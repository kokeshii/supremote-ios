//
//  SPRemoteListTableViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/17/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteListTableViewController.h"
#import "SPRemoteTableViewController.h"
#import "SPRemoteEntryCell.h"

typedef NS_ENUM(NSInteger, SPRemoteListSection) {
    SPRemoteListRemoteSection,
    SPRemoteListActionsSection,
    SPRemoteListSectionCount
};

@interface SPRemoteListTableViewController ()

@property (nonatomic, strong) NSArray *remoteList;
@property (nonatomic, strong) NSNumber *remoteId;

@end

@implementation SPRemoteListTableViewController


#pragma mark - View Lifecycle

- (void) viewDidLoad {
    [super viewDidLoad];

    
    [self loadRemoteList];
    
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"supremote-logo-small.png"]];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SPHTTPClientLoggedOutNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"NOTIFICATION RECEIVED");
        [self performSegueWithIdentifier:@"SPUnwindToLoginSegue" sender:nil];
    }];
    
}

- (void) refresh:(UIRefreshControl *)refreshControl {
    [refreshControl endRefreshing];
    [self loadRemoteList];
}


#pragma mark - Connection procedures

- (void) loadRemoteList {
    
    [[self signalForRemoteList] subscribeNext:^(id x) {
        self.remoteList = x;
        [self.tableView reloadData];
    } error:^(NSError *error) {
        if (error) {
            NSLog(@"ERROR!!!!");
            [self showConnectionUnavailableAlert];
        }
    }];
    
}




#pragma mark - Web Service Signals

- (RACSignal *) signalForRemoteList {
    
    NSError *unauthorizedError = [NSError errorWithDomain:SPSupremoteDomain code:SPErrorUnauthorized userInfo:nil];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SPHTTPClient sharedClient] getRemoteListWithSuccess:^(id responseArray) {
            [subscriber sendNext:responseArray];
            [subscriber sendCompleted];
        } error:^(NSError *errorInfo) {
            [subscriber sendError:errorInfo];
        }];
        
        return nil;
    }];
    
    
}




#pragma mark - Segue

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SPRemoteSegue"]) {
        SPRemoteTableViewController *vc = (SPRemoteTableViewController *) segue.destinationViewController;
        vc.remoteId = self.remoteId;
    }
    
}

#pragma mark - UITableViewDataSource and Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == SPRemoteListRemoteSection) {
        NSDictionary *remote = self.remoteList[indexPath.row];
        self.remoteId = remote[@"id"];
        [self performSegueWithIdentifier:@"SPRemoteSegue" sender:nil];
    } else {
        // Logout button pressed
        [self performSegueWithIdentifier:@"SPUnwindToLoginSegue" sender:nil];
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.section == SPRemoteListRemoteSection) {
        
        SPRemoteEntryCell *cell = (SPRemoteEntryCell *)[tableView dequeueReusableCellWithIdentifier:@"SPRemoteEntryCell"];
        
        NSDictionary *remote = self.remoteList[indexPath.row];
        NSDictionary *developer = remote[@"developer"];
        NSDictionary *authUser = developer[@"auth_user"];
        
        cell.remoteNameLabel.text = remote[@"name"];
        cell.developerNameLabel.text = [NSString stringWithFormat:@"@%@", authUser[@"username"]];
        
        return cell;
        
    } else if(indexPath.section == SPRemoteListActionsSection) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SPLogoutCell"];
        
        return cell;
        
    }
    
    return nil;
    
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == SPRemoteListRemoteSection) {
        return self.remoteList.count;
    } else if(section == SPRemoteListActionsSection) {
        return 1;
    }
    
    return 0;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == SPRemoteListRemoteSection) {
        return 63.0f;
    } else  {
        return 48.0f;
    }
    
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == SPRemoteListRemoteSection) {
        return @"REMOTES";
    }
    
    return nil;
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return SPRemoteListSectionCount;
}


@end
