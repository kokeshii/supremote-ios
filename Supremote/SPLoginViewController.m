//
//  SPLoginViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/16/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPLoginViewController.h"


@interface SPLoginViewController ()

@end

@implementation SPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    

    // LoginSuccesfulSegue
   
    
    
    [[[[self.loginButton
     rac_signalForControlEvents:UIControlEventTouchUpInside]
     flattenMap:^RACStream *(id value) {
         return [[self loginSignal] catch:^RACSignal *(NSError *error) {
             [self showAlertWithTitle:@"Error"
                              message:@"This username/password combination is not correct. Please try again."];
             return [RACSignal return:nil];
         }];
     }] filter:^BOOL(id value) {
         return value != nil;
     }] subscribeNext:^(id x) {
         [self performSegueWithIdentifier:@"LoginSuccesfulSegue" sender:self];
     }];
    
    
   //  [self performSegueWithIdentifier:@"LoginSuccesfulSegue" sender:self];
    
    [[self.signupButton rac_signalForControlEvents:UIControlEventTouchUpInside]
    subscribeNext:^(id x) {
        [self openSignupURL];
    }];
   
}

- (void) openSignupURL {
    UIApplication *mySafari = [UIApplication sharedApplication];
    NSURL *myURL = [[NSURL alloc]initWithString:@"http://localhost:8111/signup/"];
    [mySafari openURL:myURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (RACSignal *) loginSignal {
    
    NSError *invalidLoginError = [NSError errorWithDomain:SPSupremoteDomain code:SPErrorLoginInvalid userInfo:nil];
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        NSString *token = [[NSUserDefaults standardUserDefaults] stringForKey:@"SPAuthToken"];
       // NSString *token = nil;
        if (!token) {
            [[SPHTTPClient sharedClient] loginWithUsername:username password:password success:^(id responseArray) {
                [[NSUserDefaults standardUserDefaults] setObject:responseArray forKey:@"SPAuthToken"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [subscriber sendNext:responseArray];
                [subscriber sendCompleted];
            } error:^(NSError *errorInfo) {
                [subscriber sendError:invalidLoginError];
            }];
        } else {
            [[SPHTTPClient sharedClient] setAccessToken:token];
            [subscriber sendNext:token];
            [subscriber sendCompleted];
        }
        return nil;
        
    }];
    
}

@end
