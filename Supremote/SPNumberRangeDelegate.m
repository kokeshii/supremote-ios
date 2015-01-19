//
//  SPNumberRangeDelegate.m
//  Supremote
//
//  Created by Lambda Omega on 1/19/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPNumberRangeDelegate.h"

@implementation SPNumberRangeDelegate


+ (instancetype) delegateWithLowerLimit:(NSInteger)lowerLimit upperLimit:(NSInteger)upperLimit {
    
    SPNumberRangeDelegate *ret = [[SPNumberRangeDelegate alloc] init];
    
    ret.lowerLimit = lowerLimit;
    ret.upperLimit = upperLimit;
    
    return ret;
    
}

#pragma mark - UIPickerViewDatasource

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.upperLimit - self.lowerLimit + 1;
}


#pragma mark - UIPickerViewDelegate

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%d", self.lowerLimit + row];
}


@end
