//
//  SPRemoteTableViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/17/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteTableViewController.h"
#import "SPRemoteLabelCell.h"
#import "SPRemoteSwitchCell.h"
#import "SPRemoteActionCell.h"

@interface SPRemoteTableViewController ()
@property (nonatomic, strong) NSDictionary *remote;
@end

@implementation SPRemoteTableViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Get Remote
    
    @weakify(self)
    [[self signalForGettingRemote] subscribeNext:^(id x) {
        @strongify(self)
        self.remote = x;
        self.title = self.remote[@"name"];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        NSLog(@"BYE BYE!!!");
    }];
    
    
}

- (RACSignal *) signalForGettingRemote {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SPHTTPClient sharedClient] getRemoteWithId:self.remoteId success:^(id responseArray) {
            [subscriber sendNext:responseArray];
            [subscriber sendCompleted];
        } error:^(NSError *errorInfo) {
            [subscriber sendError:errorInfo];
        }];
        return nil;
    }];
    
}


- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *fieldKey = [self fieldKeyForIndex:indexPath.row];
    NSDictionary *fieldDict = [self fields][fieldKey];
    
    NSString *cellId = [self cellIdentifierForRemoteField:fieldDict];
    
    SPRemoteCell *remoteCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    remoteCell.titleLabel.text = fieldDict[@"title"];
    remoteCell.descriptionLabel.text = fieldDict[@"description"];

    [self setValueForRemoteCell:remoteCell fieldDictionary:fieldDict key:fieldKey];
    
    return remoteCell;
}


- (void) setValueForRemoteCell:(SPRemoteCell *)cell fieldDictionary:(NSDictionary *)fieldDictionary key:(NSString *)key {
    
    NSString *fieldType = (NSString *)fieldDictionary[@"type"];
    
    if ([fieldType isEqualToString:@"text"] ||
        [fieldType isEqualToString:@"multiple"] ||
        [fieldType isEqualToString:@"number"]) {
        
        SPRemoteLabelCell *labelCell = (SPRemoteLabelCell *)cell;
        
        id fieldValue = [self currentValues][key];
        
        labelCell.valueLabel.text = [NSString stringWithFormat:@"%@", fieldValue];
       
        
    } else if([fieldType isEqualToString:@"boolean"]) {
        SPRemoteSwitchCell *switchCell = (SPRemoteSwitchCell *)cell;
        
        BOOL fieldValue = [[self currentValues][key] boolValue];
        [switchCell.valueSwitch setOn:fieldValue animated:YES];
    }
    
}

- (NSString *) cellIdentifierForRemoteField:(NSDictionary *)remote {
    
    
    NSString *fieldType = (NSString *)remote[@"type"];
    
    if ([fieldType isEqualToString:@"text"]) {
        return @"SPRemoteLabelCell";
    } else if ([fieldType isEqualToString:@"multiple"]) {
        return @"SPRemoteLabelCell";
    } else if([fieldType isEqualToString:@"number"]) {
        return @"SPRemoteLabelCell";
    } else if([fieldType isEqualToString:@"boolean"]) {
        return @"SPRemoteSwitchCell";
    } else if([fieldType isEqualToString:@"action"]) {
        return @"SPRemoteActionCell";
    }
    
    return nil;
    
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSDictionary *) configuration {
    if (self.remote) {
        return self.remote[@"configuration"];
    }
    return nil;
}

- (NSDictionary *) fields {
    NSDictionary *conf = [self configuration];
    if (conf) {
        return conf[@"fields"];
    }
    return nil;
}

- (NSArray *) orderedKeys {
    if (self.remote) {
        return self.remote[@"ordered_keys"];
    }
    return nil;
}

- (NSDictionary *) currentValues {
    if (self.remote) {
        return self.remote[@"current_values"];
    }
    return nil;
}

- (NSString *) fieldKeyForIndex:(NSInteger)index {
    return [self orderedKeys][index];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self fields].count;
}

@end
