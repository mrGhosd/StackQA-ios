//
//  AuthorizationViewController.m
//  StackQA
//
//  Created by vsokoltsov on 26.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "SWRevealViewController.h"
#import "AuthorizationManager.h"

@interface AuthorizationViewController (){
    AuthorizationManager *auth;
}

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defineNavigationPanel];
    [self setSegmentValue];
    [self setCurrentView:self.firstView];
    // Do any additional setup after loading the view.
}

-(void) defineNavigationPanel{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        revealViewController.rightViewController = nil;
        
    }
}

- (void) setCurrentView:(NSInteger *)index{
    if(index == 0){
        [self.loginView setHidden:NO];
        [self.registrationView setHidden:YES];
    } else if(index == 1){
        [self.loginView setHidden:YES];
        [self.registrationView setHidden:NO];
    }
}

-(void) setSegmentValue{
    [self.actionSegment setSelectedSegmentIndex:self.firstView];
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

- (IBAction)switchViews:(id)sender {
    NSInteger selectedSegment = self.actionSegment.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        [self setCurrentView:0];
    } else if(selectedSegment == 1){
        [self setCurrentView:1];
    }
}
- (IBAction)registrationButton:(id)sender {
}

- (IBAction)loginButton:(id)sender {
    [[AuthorizationManager sharedInstance] signInUserWithEmail:self.emailField.text andPassword:self.passwordField.text];
    [self performSegueWithIdentifier:@"profile_view" sender:self ];
}
@end
