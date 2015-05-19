//
//  StatisticViewController.h
//  StackQA
//
//  Created by vsokoltsov on 06.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"
#import "AuthorizationManager.h"
#import "User.h"
#import "ServerErrorDelegate.h"

@interface StatisticViewController : ViewController <UITableViewDataSource, UITableViewDelegate, ServerErrorDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) User *user;
@end
