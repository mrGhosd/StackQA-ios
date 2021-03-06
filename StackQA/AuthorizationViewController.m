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
#import "ServerError.h"
#import <QuartzCore/QuartzCore.h>
#import <UICKeyChainStore.h>
#import "ProfileViewController.h"

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
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"system-message-title", nil) message:NSLocalizedString(@"empty-user", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void) handleAuthorizationErrors:(ServerError *)error{
    NSString *fullMessage = @"";
    if(error.message[@"email"]){
        [self markFieldAsError:self.emailField];
        NSString *message = [NSString stringWithFormat:@"email %@", error.message[@"email"][0]];
        fullMessage = [NSString stringWithFormat:@"%@", message];
    }
    if(error.message[@"password"]){
        [self markFieldAsError:self.passwordField];
        NSString *message = [NSString stringWithFormat:@"password %@", error.message[@"password"][0]];
        fullMessage = [NSString stringWithFormat:@"%@ \n %@", fullMessage, message];
    }
    if(error.message[@"error"]){
        fullMessage = NSLocalizedString(@"empty-user", nil);
    }
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"system-message-title", nil) message:fullMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}

- (void) handleRegistrationError:(ServerError *) error{
    NSString *fullMessage = @"";
    if(error.message[@"email"]){
        [self markFieldAsError:self.regEmailField];
        NSString *message = [NSString stringWithFormat:@"email %@", error.message[@"email"][0]];
        fullMessage = [NSString stringWithFormat:@"%@", message];
    }
    if(error.message[@"password"]){
        [self markFieldAsError:self.regPasswordField];
        NSString *message = [NSString stringWithFormat:@"password %@", error.message[@"password"][0]];
        fullMessage = [NSString stringWithFormat:@"%@ \n %@", fullMessage, message];
    }
    if(error.message[@"password_confirmation"]){
        [self markFieldAsError:self.regPasswordConfirmationField];
        NSString *message = [NSString stringWithFormat:@"password_confirmation %@", error.message[@"password confirmation"][0]];
        fullMessage = [NSString stringWithFormat:@"%@ \n %@", fullMessage, message];
    }
    if([error.status isEqual:@400]){
        fullMessage = NSLocalizedString(@"server-connection-disabled", nil);
    }
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"system-message-title", nil) message:fullMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [av show];
}
- (void) markFieldAsError:(UITextView *) field{
    field.layer.cornerRadius=4.0f;
    field.layer.masksToBounds=YES;
    field.layer.borderColor=[[UIColor redColor]CGColor];
    field.layer.borderWidth= 1.0f;
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
- (IBAction)registrationButton:(id)sender {
    self.regEmailField.layer.borderColor = [[UIColor clearColor]CGColor];
    self.regPasswordField.layer.borderColor = [[UIColor clearColor]CGColor];
    self.regPasswordConfirmationField.layer.borderColor = [[UIColor clearColor]CGColor];
    NSMutableDictionary *users = @{@"email": self.regEmailField.text,
                                   @"password": self.regPasswordField.text,
                                   @"password_confirmation": self.regPasswordConfirmationField.text};
    
    [[AuthorizationManager sharedInstance] signUpWithParams:@{@"user": users} andComplition:^(id data, BOOL success){
        if(success){
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"system-message-title", nil) message: NSLocalizedString(@"thank-for-reg", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [av show];
        } else {
            ServerError *error = [[ServerError alloc] initWithData:data];
            [self handleRegistrationError:error];
        }
    }];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"profile_view"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        ProfileViewController *controller = (ProfileViewController *)navController.topViewController;
        controller.user = [[AuthorizationManager sharedInstance] currentUser];
    }
}
@end
