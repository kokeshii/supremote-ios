//
//  SPLoginViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/16/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPLoginViewController.h"

#import <BFKit/UIColor+BFKit.h>
#import <IQKeyboardManager/IQKeyboardReturnKeyHandler.h>


@interface SPLoginViewController () {
   
}



@end


@implementation SPLoginViewController {
    IQKeyboardReturnKeyHandler *returnKeyHandler;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    returnKeyHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    
    [self setupPlaceholders];
    [self prepopulateFields];

    [self setupLoginButton];
    [self setupSignupButton];
    
    
    // Get the Auth token
    NSString *authToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"SPAuthToken"];
    
    if (authToken) {
        [[SPHTTPClient sharedClient] setAccessToken:authToken];
        [[self profileSignal] subscribeNext:^(id x) {
            NSLog(@"LOGIN WITH SAVED TOKEN SUCCESFUL.");
            [self performSegueWithIdentifier:@"LoginSuccesfulSegue" sender:self];
        } error:^(NSError *error) {
            NSLog(@"AUTH TOKEN IS NOT CORRECT.");
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"SPAuthToken"];
            [[SPHTTPClient sharedClient] setAccessToken:nil];
        }];
        
    }
    
    
    
}


- (void) dealloc {
    returnKeyHandler = nil;
}


- (void) setupSignupButton {
    [[self.signupButton rac_signalForControlEvents:UIControlEventTouchUpInside]
     subscribeNext:^(id x) {
         [self openSignupURL];
     }];
}

- (void) setupLoginButton {
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
}

- (void) setupPlaceholders {
    NSAttributedString *usernamePlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{ NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    NSAttributedString *passwordPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{ NSForegroundColorAttributeName: [UIColor colorWithHexString:@"888888"]}];
    
    self.usernameField.attributedPlaceholder = usernamePlaceholder;
    self.passwordField.attributedPlaceholder = passwordPlaceholder;
}

- (void) prepopulateFields {
    NSString *username = [[NSUserDefaults standardUserDefaults] stringForKey:@"SPUsername"];
    
    self.usernameField.text = username;
}

- (IBAction)unwindToLogin:(UIStoryboardSegue *)unwindSegue {
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"SPAuthToken"];
}

- (void) openSignupURL {
    UIApplication *mySafari = [UIApplication sharedApplication];
    NSURL *myURL = [[NSURL alloc]initWithString:SIGNUP_URL];
    [mySafari openURL:myURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (RACSignal *) profileSignal {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SPHTTPClient sharedClient] getProfileInformationWithSuccess:^(id responseArray) {
            [subscriber sendNext:responseArray];
            [subscriber sendCompleted];
        } error:^(NSError *errorInfo) {
            [subscriber sendError:errorInfo];
        }];
        
        return nil;
        
    }];
    
}


- (RACSignal *) loginSignal {
    
    NSError *invalidLoginError = [NSError errorWithDomain:SPSupremoteDomain code:SPErrorLoginInvalid userInfo:nil];
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [[SPHTTPClient sharedClient] loginWithUsername:username password:password success:^(id responseArray) {
                [[NSUserDefaults standardUserDefaults] setObject:responseArray forKey:@"SPAuthToken"];
                [[NSUserDefaults standardUserDefaults] setObject:username forKey:@"SPUsername"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [subscriber sendNext:responseArray];
                [subscriber sendCompleted];
            } error:^(NSError *errorInfo) {
                [subscriber sendError:invalidLoginError];
            }];
        
        return nil;
        
    }];
    
}

@end
