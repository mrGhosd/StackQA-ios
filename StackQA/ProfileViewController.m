//
//  ProfileViewController.m
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ProfileViewController.h"
#import "AuthorizationManager.h"
#import <UICKeyChainStore.h>
#import "SWRevealViewController.h"

@interface ProfileViewController (){
    AuthorizationManager *auth;
    UICKeyChainStore *store;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    auth = [AuthorizationManager sharedInstance];
    self.userEmail.text = auth.currentUser.email;
    store = [UICKeyChainStore keyChainStore];
    [self defineNavigationPanel];
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

- (IBAction)logOut:(id)sender {
    auth.currentUser = nil;
    [store removeItemForKey:@"email"];
    [store removeItemForKey:@"password"];
    [store removeItemForKey:@"access_token"];
    [self performSegueWithIdentifier:@"logOut" sender:self];
}
@end
