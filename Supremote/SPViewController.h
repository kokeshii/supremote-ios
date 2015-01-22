//
//  SPViewController.h
//  Supremote
//
//  Created by Lambda Omega on 1/16/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "RACEXTScope.h"
#import "SPHTTPClient.h"

typedef NS_ENUM(NSInteger, RWTwitterInstantError) {
    SPErrorLoginInvalid,
    SPErrorUnauthorized
};

static NSString * const SPSupremoteDomain = @"Supremote";


@interface SPViewController : UIViewController

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message;

- (void) showConnectionUnavailableAlert;

@end
