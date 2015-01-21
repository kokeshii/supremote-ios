//
//  SPMultipleChoiceDelegate.h
//  Supremote
//
//  Created by Lambda Omega on 1/19/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPPickerDelegate.h"


@interface SPMultipleChoiceDelegate : SPPickerDelegate

@property (nonatomic, assign) NSArray *options;

+ (instancetype) delegateWithOptions:(NSArray *)options;

@end
