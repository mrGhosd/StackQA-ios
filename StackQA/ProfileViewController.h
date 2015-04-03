//
//  ProfileViewController.h
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"

@interface ProfileViewController : ViewController

@property (strong, nonatomic) IBOutlet UILabel *userEmail;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
- (IBAction)logOut:(id)sender;
@end
