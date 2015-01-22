//
//  SPRemoteListTableViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/17/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteListTableViewController.h"
#import "SPRemoteTableViewController.h"

@interface SPRemoteListTableViewController ()

@property (nonatomic, strong) NSArray *remoteList;
@property (nonatomic, strong) NSNumber *remoteId;

@end

@implementation SPRemoteListTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];

    
   [[self signalForRemoteList] subscribeNext:^(id x) {
       self.remoteList = x;
       [self.tableView reloadData];
   } error:^(NSError *error) {
       [self showAlertWithTitle:@"ERROR" message:@"ERROR"];
   }];
    
    
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"supremote-logo-small.png"]];
    
}

- (RACSignal *) signalForRemoteList {
    
    NSError *unauthorizedError = [NSError errorWithDomain:SPSupremoteDomain code:SPErrorUnauthorized userInfo:nil];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SPHTTPClient sharedClient] getRemoteListWithSuccess:^(id responseArray) {
            [subscriber sendNext:responseArray];
            [subscriber sendCompleted];
        } error:^(NSError *errorInfo) {
            [subscriber sendError:unauthorizedError];
        }];
        
        return nil;
    }];
    
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.remoteList.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SPRemoteCell"];
    
    NSDictionary *remote = self.remoteList[indexPath.row];
    NSDictionary *developer = remote[@"developer"];
    NSDictionary *authUser = developer[@"auth_user"];
    
    cell.textLabel.text = remote[@"name"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", authUser[@"first_name"], authUser[@"last_name"]];
    
    return cell;
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"SPRemoteSegue"]) {
        SPRemoteTableViewController *vc = (SPRemoteTableViewController *) segue.destinationViewController;
        vc.remoteId = self.remoteId;
    }
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *remote = self.remoteList[indexPath.row];
    
    
    self.remoteId = remote[@"id"];
    NSLog(@"REMOTE ID IS: %@", remote[@"id"]);
    [self performSegueWithIdentifier:@"SPRemoteSegue" sender:nil];
    
}

@end
