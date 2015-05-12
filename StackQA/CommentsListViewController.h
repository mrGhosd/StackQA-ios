//
//  CommentsListViewController.h
//  StackQA
//
//  Created by vsokoltsov on 04.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"
#import "Question.h"
#import "Answer.h"
#import "CommentDelegate.h"

@interface CommentsListViewController : ViewController <UITableViewDataSource, UITableViewDelegate, CommentDelegate>
@property (strong) Question *question;
@property (strong) Answer *answer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *commentTableBottomMargin;
@property (strong, nonatomic) IBOutlet UIView *controlView;
@property (strong, nonatomic) IBOutlet UITextView *commentText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *controlViewBottomMargin;
@property (strong, nonatomic) IBOutlet UIButton *commentSendButton;
- (IBAction)createComment:(id)sender;
@end
