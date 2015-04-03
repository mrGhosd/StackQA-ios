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

@interface ProfileViewController : ViewController
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) IBOutlet UIImageView *userAvatar;
@property (strong) User *user;
@property (strong, nonatomic) IBOutlet UILabel *userFullName;
@end
