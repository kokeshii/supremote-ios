//
//  SPViewController.m
//  Supremote
//
//  Created by Lambda Omega on 1/16/15.
//  Copyright (c) 2015 Supremote. All rights reserved.
//

#import "SPViewController.h"


@interface SPViewController ()

@end

@implementation SPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"SETNEEDS!");
    [self setNeedsStatusBarAppearanceUpdate];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showAlertWithTitle:(NSString *)title message:(NSString *)message {
    
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    
}

- (void) showConnectionUnavailableAlert {
    [self showAlertWithTitle:@"Connection Unavailable" message:@"Please check your internet connection and try again."];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
