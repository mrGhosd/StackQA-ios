//
//  AnswersViewController.h
//  StackQA
//
//  Created by vsokoltsov on 23.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreData+MagicalRecord.h>
#import "Question.h"

@interface AnswersViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong) Question *question;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottom;
@property (strong, nonatomic) IBOutlet UIView *actionView;
@property (strong, nonatomic) IBOutlet UITextView *actionViewText;
@end
