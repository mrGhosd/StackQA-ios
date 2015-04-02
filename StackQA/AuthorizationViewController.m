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
#import <UICKeyChainStore.h>

@interface AuthorizationViewController (){
    AuthorizationManager *auth;
    UICKeyChainStore *store;
}

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserValue) name:@"getCurrentUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(errorUserProfileDownload) name:@"errorUserProfileDownloadMessage" object:nil];
    store = [UICKeyChainStore keyChainStore];
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
-(void) currentUserValue{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self performSegueWithIdentifier:@"profile_view" sender:self ];
}
- (void) errorUserProfileDownload{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Такой пользователь не найден" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)registrationButton:(id)sender {
    NSMutableDictionary *users = @{@"email": self.regEmailField.text,
                             @"password": self.regPasswordField.text,
                             @"password_confirmation": self.regPasswordConfirmationField.text};
    
    [[AuthorizationManager sharedInstance] signUpWithParams:@{@"user": users} andComplition:^(id data, BOOL success){
        if(success){
        
        } else {
        
        }
    }];
}

- (IBAction)loginButton:(id)sender {
    [store removeItemForKey:@"access_token"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [store setString:self.emailField.text forKey:@"email"];
        [store setString:self.passwordField.text forKey:@"password"];
        [store synchronize];
        [[AuthorizationManager sharedInstance] signInUserWithEmail:self.emailField.text andPassword:self.passwordField.text];
    });
}
@end
