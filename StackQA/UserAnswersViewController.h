//
//  UserAnswersViewController.h
//  StackQA
//
//  Created by vsokoltsov on 24.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"
#import "User.h"
#import <SWTableViewCell.h>
#import <CoreData/CoreData.h>
#import <CoreData+MagicalRecord.h>

@interface UserAnswersViewController : ViewController <UITableViewDataSource, UITableViewDelegate, SWTableViewCellDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) User *user;
@end