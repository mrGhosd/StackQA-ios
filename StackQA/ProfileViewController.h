//
//  ProfileViewController.h
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"
#import <CoreData+MagicalRecord.h>
#import "User.h"
#import "ServerErrorDelegate.h"

@interface ProfileViewController : ViewController <UITableViewDataSource, UITableViewDelegate, ServerErrorDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIImageView *userAvatar;
@property (strong) User *user;
@property (strong, nonatomic) IBOutlet UILabel *userFullName;
@property (strong, nonatomic) IBOutlet UIButton *userRate;
@property (strong, nonatomic) IBOutlet UIButton *signOutButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITableView *userParamsTable;
- (IBAction)showUserStatistic:(id)sender;
- (IBAction)signOut:(id)sender;
@end
