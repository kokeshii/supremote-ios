//
//  SPRemoteTableViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/17/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteTableViewController.h"
#import "RMPickerViewController.h"
#import "SPRemoteLabelCell.h"
#import "SPRemoteSwitchCell.h"
#import "SPRemoteActionCell.h"
#import "SPRemoteTextInputCell.h"
#import <Classy/Classy.h>

#import "SPMultipleChoiceDelegate.h"
#import "SPNumberRangeDelegate.h"
#import "SPRemote.h"

@interface SPRemoteTableViewController () <RMPickerViewControllerDelegate, UITextFieldDelegate>
@property (nonatomic, strong) SPRemote *remote;
@property (nonatomic, strong) NSString *transitionKey;
@property (nonatomic, strong) SPPickerDelegate *pickerDelegate;
@property (nonatomic, weak) NSString *modifyingKey;
@end

@implementation SPRemoteTableViewController

#pragma mark - Loading Procedures

- (void) updateRemoteValues {
    
    [[self signalForUpdatingRemoteValues] subscribeNext:^(id x) {
        NSLog(@"RESPONSE: %@", x);
        
        if ([x objectForKey:@"error"]) {
            [self showAlertWithTitle:@"Oops!" message:x[@"error"]];
            [self loadRemote];
        } else {
            // If there's no error, commit the remote values
            [self.remote commit];
        }
        
    } error:^(NSError *error) {
        if (error) {
            [self showConnectionUnavailableAlert];
            [self.remote rollback];
            [self.tableView reloadData];
        }
    }];
    
}


- (void) loadRemote {
    NSLog(@"RELOADING REMOTE");
    
    @weakify(self)
    [[self signalForGettingRemote] subscribeNext:^(id x) {
        @strongify(self)
        self.remote = [SPRemote remoteFromDictionary:x];
        self.title = [self.remote name];
        [self.tableView reloadData];
    } error:^(NSError *error) {
        if (error) {
            [self showConnectionUnavailableAlert];
        }
    }];
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    // Get Remote
    [self loadRemote];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:SPHTTPClientLoggedOutNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        NSLog(@"NOTIFICATION RECEIVED");
        [self performSegueWithIdentifier:@"SPUnwindToLoginSegue" sender:nil];
    }];
    
    
}


- (void)refresh:(UIRefreshControl *)refreshControl {
    [self loadRemote];
    [refreshControl endRefreshing];
}

#pragma mark - RAC Web service signals

- (RACSignal *) signalForUpdatingRemoteValues {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SPHTTPClient sharedClient] saveRemoteValuesForRemoteWithId:[self.remote remoteId] values:[self.remote values] success:^(id responseArray) {
            [subscriber sendNext:responseArray];
            [subscriber sendCompleted];
        } error:^(NSError *errorInfo) {
            [subscriber sendError:errorInfo];
        }];
        
        return nil;
        
    }];
    
}

- (RACSignal *) signalForPerformingAction:(NSString *)actionName {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SPHTTPClient sharedClient] triggerAction:actionName forRemoteWithId:[self.remote remoteId] success:^(id responseArray) {
            [subscriber sendNext:responseArray];
            [subscriber sendCompleted];
        } error:^(NSError *errorInfo) {
            [subscriber sendError:errorInfo];
        }];
        
        return nil;
        
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

#pragma mark - RMPickerViewController Delegates
- (void)pickerViewController:(RMPickerViewController *)vc didSelectRows:(NSArray  *)selectedRows {
    //Do something

    NSLog(@"DID SELECT ROW: %@", selectedRows);
    
    NSString *optionValue = [self.pickerDelegate pickerView:vc.picker titleForRow:[selectedRows[0] integerValue] forComponent:0];
    [self.remote setCurrentValue:optionValue forKey:self.modifyingKey];
    self.modifyingKey = nil;
    [self.tableView reloadData];
    [self updateRemoteValues];
    
}

- (void)pickerViewControllerDidCancel:(RMPickerViewController *)vc {
    //Do something else
    
    NSLog(@"DID CANCEL");
}



#pragma mark - Remote-Table utilities

- (void) setValueForRemoteCell:(SPRemoteCell *)cell fieldDictionary:(NSDictionary *)fieldDictionary key:(NSString *)key {
    
    NSString *fieldType = (NSString *)fieldDictionary[@"type"];
    
    
    if ([fieldType isEqualToString:@"text"]) {
        
        SPRemoteTextInputCell *textCell = (SPRemoteTextInputCell *)cell;
        textCell.textField.text = [self.remote getCurrentValueForKey:key];
        
    } else if ([fieldType isEqualToString:@"multiple"] ||
        [fieldType isEqualToString:@"number"]) {
        
        SPRemoteLabelCell *labelCell = (SPRemoteLabelCell *)cell;
        
        id fieldValue = [self.remote getCurrentValueForKey:key];
        
        labelCell.valueLabel.text = [NSString stringWithFormat:@"%@", fieldValue];
       
        
    } else if([fieldType isEqualToString:@"boolean"]) {
        SPRemoteSwitchCell *switchCell = (SPRemoteSwitchCell *)cell;
        
        BOOL fieldValue = [[self.remote getCurrentValueForKey:key] boolValue];
        [switchCell.valueSwitch setOn:fieldValue animated:YES];
    } else if ([fieldType isEqualToString:@"action"]) {
        
        SPRemoteActionCell *actionCell = (SPRemoteActionCell *)cell;
        
        actionCell.contentView.cas_styleClass = fieldDictionary[@"class"];
        
    }
    
}


#pragma mark - Individual Cell Type select handlers

- (void) didSelectTextInputCell:(SPRemoteTextInputCell *) textInputCell fieldDictionary:(NSDictionary *)fieldDict fieldKey:(NSString *)fieldKey {
    
    /*
        Textfield is deactivated by default. The act of touching the cell is
     what ends up activating the textfield.
     
     */
    
    textInputCell.textField.userInteractionEnabled = YES;
    textInputCell.textField.delegate = self;
    [textInputCell.textField becomeFirstResponder];
}


- (void) didSelectLabelCell:(SPRemoteLabelCell *) labelCell fieldDictionary:(NSDictionary *)fieldDict fieldKey:(NSString *) fieldKey {
    
    RMPickerViewController *pickerVC = [RMPickerViewController pickerController];
    pickerVC.delegate = self;
    
    SPRemoteFieldType fieldType = [self.remote typeOfFieldWithKey:fieldKey];
    
    NSInteger selectedValueIndex = -1;
    id currentValue = [self.remote getCurrentValueForKey:fieldKey];
    
    if (fieldType == SPRemoteFieldTypeNumber) {
        NSArray *numberRange = fieldDict[@"range"];
        
        NSInteger integralValue = [currentValue integerValue];
        
        if (integralValue >= [numberRange[0] integerValue] && integralValue <= [numberRange[1] integerValue]) {
            selectedValueIndex = integralValue - [numberRange[0] integerValue];
        }
        
        self.pickerDelegate = [SPNumberRangeDelegate delegateWithLowerLimit:[numberRange[0]integerValue] upperLimit:[numberRange[1] integerValue]];
    } else {
        NSArray *choices = fieldDict[@"choices"];

        selectedValueIndex = [choices indexOfObject:currentValue];
        
        self.pickerDelegate = [SPMultipleChoiceDelegate delegateWithOptions:choices];
    }
    
    pickerVC.picker.delegate = self.pickerDelegate;
    pickerVC.picker.dataSource = self.pickerDelegate;
    [pickerVC show];
    
    
    if (selectedValueIndex == NSNotFound) {
        selectedValueIndex = 0;
    }
    
    [pickerVC.picker selectRow:selectedValueIndex inComponent:0 animated:YES];
    
}


- (void) didSelectSwitchCell:(SPRemoteSwitchCell *)switchCell fieldDictionary:(NSDictionary *)fieldDict fieldKey:(NSString *)fieldKey {
    
    [switchCell.valueSwitch setOn:!switchCell.valueSwitch.on animated:YES];
    
    [self.remote setCurrentValue:@(switchCell.valueSwitch.on) forKey:fieldKey];
    [self updateRemoteValues];
    
}


- (void) didSelectActionCell:(SPRemoteActionCell *)actionCell fieldDictionary:(NSDictionary *)fieldDict fieldKey:(NSString *)fieldKey {
    
    [[self signalForPerformingAction:fieldKey] subscribeNext:^(id x) {
        
        if ([x objectForKey:@"error"]) {
            [self showAlertWithTitle:@"Oops!" message:x[@"error"]];
            [self loadRemote];
        }
        
    } error:^(NSError *error) {
        if (error) {
            [self showConnectionUnavailableAlert];
        }
    }];
    
    
}



#pragma mark - UITableViewController Delegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    
    NSString *fieldKey = [self.remote keyForFieldWithIndex:indexPath.row];
    NSDictionary *fieldDict = [self.remote fieldForKey:fieldKey];

    self.modifyingKey = fieldKey;
    
    if ([cell isKindOfClass:[SPRemoteTextInputCell class]]) {
    
        [self didSelectTextInputCell:(SPRemoteTextInputCell *)cell fieldDictionary:fieldDict fieldKey:fieldKey];
        
    } else if ([cell isKindOfClass:[SPRemoteLabelCell class]]) {
        
        [self didSelectLabelCell:(SPRemoteLabelCell *)cell fieldDictionary:fieldDict fieldKey:fieldKey];
        
    } else if ([cell isKindOfClass:[SPRemoteSwitchCell class]]) {
        
        [self didSelectSwitchCell:(SPRemoteSwitchCell *)cell fieldDictionary:fieldDict fieldKey:fieldKey];
        
    } else if ([cell isKindOfClass:[SPRemoteActionCell class]]) {
        
        [self didSelectActionCell:(SPRemoteActionCell *)cell fieldDictionary:fieldDict fieldKey:fieldKey];
        
    }
    
}

#pragma mark - UITableViewController DataSource

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 54.0f;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.remote fieldCount];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *fieldKey = [self.remote keyForFieldWithIndex:indexPath.row];
    NSDictionary *fieldDict = [self.remote fieldForKey:fieldKey];
    
    NSString *cellId = [self cellIdentifierForFieldWithKey:fieldKey];
    
    SPRemoteCell *remoteCell = [tableView dequeueReusableCellWithIdentifier:cellId];
    
    remoteCell.titleLabel.text = fieldDict[@"title"];
    remoteCell.descriptionLabel.text = fieldDict[@"description"];
    
    [self setValueForRemoteCell:remoteCell fieldDictionary:fieldDict key:fieldKey];
    
    return remoteCell;
}



#pragma mark - Remote Navigation Utilities

- (NSString *) cellIdentifierForFieldWithKey:(NSString *)key {
    
    SPRemoteFieldType type = [self.remote typeOfFieldWithKey:key];
    
    switch (type) {
        case SPRemoteFieldTypeText:
             return @"SPRemoteTextInputCell";
            break;
            
        case SPRemoteFieldTypeMultiple:
            return @"SPRemoteLabelCell";
            break;
            
        case SPRemoteFieldTypeNumber:
             return @"SPRemoteLabelCell";
            break;
            
        case SPRemoteFieldTypeBoolean:
            return @"SPRemoteSwitchCell";
            break;
            
        case SPRemoteFieldTypeAction:
            return @"SPRemoteActionCell";
            break;
            
        case SPRemoteFieldTypeUnknown:
            return nil;
            break;
            
    }
    
    return nil;
    
}

#pragma mark - UITextFieldDelegate

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    
    [self.remote setCurrentValue:textField.text forKey:self.modifyingKey];
    self.modifyingKey = nil;
    textField.delegate = nil;
    textField.userInteractionEnabled = NO;
    [self.tableView reloadData];
    [self updateRemoteValues];
}


- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSInteger maxLength = [[self.remote fieldForKey:self.modifyingKey][@"maxLength"] integerValue];
    
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > maxLength) ? NO : YES;
    
}


@end
