//
//  UserCommentsViewController.h
//  StackQA
//
//  Created by vsokoltsov on 07.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import "CommentDelegate.h"
#import "ServerErrorDelegate.h"

@interface UserCommentsViewController : ViewController <UITableViewDataSource, UITableViewDelegate, CommentDelegate, ServerErrorDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) User *user;
@end
