//
//  SPMultipleChoiceDelegate.m
//  Supremote
//
//  Created by Lambda Omega on 1/19/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPMultipleChoiceDelegate.h"

@implementation SPMultipleChoiceDelegate


- (instancetype) delegateWithOptions:(NSArray *)options {
    SPMultipleChoiceDelegate *ret = [[SPMultipleChoiceDelegate alloc] init];
    
    ret.options = options;
    
    return ret;
}

#pragma mark - UIPickerViewDatasource

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.options.count;
}


#pragma mark - UIPickerViewDelegate

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.options[row];
}



@end
