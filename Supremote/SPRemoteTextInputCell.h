//
//  SPRemoteTextInputCell.h
//  Supremote
//
//  Created by Lambda Omega on 1/19/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPRemoteCell.h"

@interface SPRemoteTextInputCell : SPRemoteCell <UITextFieldDelegate>

@property (nonatomic, weak) IBOutlet UITextField *textField;

@end
