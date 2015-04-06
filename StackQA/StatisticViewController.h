//
//  StatisticViewController.h
//  StackQA
//
//  Created by vsokoltsov on 06.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"
#import "AuthorizationManager.h"

@interface StatisticViewController : ViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
