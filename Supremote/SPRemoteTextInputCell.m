//
//  SPRemoteTextInputCell.m
//  Supremote
//
//  Created by Lambda Omega on 1/19/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteTextInputCell.h"

@implementation SPRemoteTextInputCell


- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textField.delegate = self;
    }
    
    return self;
    
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent crashing undo bug – see note below.
    if(range.length + range.location > textField.text.length)
    {
        return NO;
    }
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    return (newLength > self.maxLength) ? NO : YES;
}

@end
