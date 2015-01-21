//
//  SPNumberRangeDelegate.h
//  Supremote
//
//  Created by Lambda Omega on 1/19/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPickerDelegate.h" 

@interface SPNumberRangeDelegate : SPPickerDelegate

@property (nonatomic, assign) NSInteger lowerLimit, upperLimit;

+ (instancetype) delegateWithLowerLimit:(NSInteger)lowerLimit upperLimit:(NSInteger)upperLimit;

@end
