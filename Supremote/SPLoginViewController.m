//
//  SPLoginViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/16/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPLoginViewController.h"
#import "SPHTTPClient.h"

typedef NS_ENUM(NSInteger, RWTwitterInstantError) {
    SPErrorLoginInvalid
};

static NSString * const SPSupremoteDomain = @"Supremote";

@interface SPLoginViewController ()

@end

@implementation SPLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    @weakify(self)
//    [[[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside]
//     then:^RACSignal *{
//         @strongify(self)
//         return [self loginSignal:@"admin" password:@"admin"];
//     }]
//     subscribeNext:^(id x) {
//         NSLog(@"LOGIN SUCCESFUL");
//     } error:^(NSError *error) {
//        NSLog(@"LOGIN ERROR");
//     }];
   
    
    [[[self.loginButton
     rac_signalForControlEvents:UIControlEventTouchUpInside]
     flattenMap:^RACStream *(id value) {
         return [self loginSignal:@"admin" password:@"admin"];
     }] subscribeNext:^(id x) {
         NSLog(@"LOGIN SUCCESFUL");
     } error:^(NSError *error) {
         NSLog(@"LOGIN FAILED");
     }];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (RACSignal *) loginSignal:(NSString *)username password:(NSString *)password {
    
    NSError *invalidLoginError = [NSError errorWithDomain:SPSupremoteDomain code:SPErrorLoginInvalid userInfo:nil];
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [[SPHTTPClient sharedClient] loginWithUsername:username password:password success:^(id responseArray) {
            [subscriber sendNext:nil];
            [subscriber sendCompleted];
        } error:^(NSError *errorInfo) {
            [subscriber sendError:invalidLoginError];
        }];
        
        return nil;
        
    }];
    
}

@end
