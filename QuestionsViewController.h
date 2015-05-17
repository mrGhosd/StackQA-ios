//
//  QuestionsViewController.h
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "User.h"
#import "SCategory.h"
#import "FilterDelegate.h"
#import "ServerErrorDelegate.h"

@interface QuestionsViewController : UITableViewController <SWTableViewCellDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchDisplayDelegate, FilterDelegate, ServerErrorDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property(strong, nonatomic) NSMutableArray *questions;
@property (strong) User *user_page;
@property (strong) SCategory *category;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addQuestion;
@end
