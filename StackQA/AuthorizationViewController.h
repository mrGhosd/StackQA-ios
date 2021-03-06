//
//  AuthorizationViewController.h
//  StackQA
//
//  Created by vsokoltsov on 26.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerErrorDelegate.h"

@interface AuthorizationViewController : UIViewController <ServerErrorDelegate>
@property (nonatomic) NSInteger *firstView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *actionSegment;
- (IBAction)switchViews:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *registrationView;
@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UITextField *regEmailField;
@property (strong, nonatomic) IBOutlet UITextField *regPasswordField;
@property (strong, nonatomic) IBOutlet UITextField *regPasswordConfirmationField;
- (IBAction)registrationButton:(id)sender;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)loginButton:(id)sender;
@end
