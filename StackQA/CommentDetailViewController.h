//
//  CommentDetailViewController.h
//  StackQA
//
//  Created by vsokoltsov on 06.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ViewController.h"
#import "Comment.h"
#import "Question.h"
#import "Answer.h"
#import "ServerErrorDelegate.h"

@interface CommentDetailViewController : ViewController <CommentDelegate, ServerErrorDelegate>
@property (strong) Comment *comment;
@property (strong) Question *question;
@property (strong) Answer *answer;
@property (strong, nonatomic) IBOutlet UIView *controlView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *cancelButton;
@property (strong, nonatomic) IBOutlet UITextView *commentText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *actionViewBottomMargin;
- (IBAction)saveComment:(id)sender;
- (IBAction)dissmissView:(id)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *scrollViewBottomMargin;
@end
