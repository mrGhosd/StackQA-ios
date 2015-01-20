//
//  QuestionDetailViewController.h
//  StackQA
//
//  Created by vsokoltsov on 19.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData+MagicalRecord.h>
#import "Question.h"
#import "QuestionDetail.h"

@interface QuestionDetailViewController : UIViewController <UITextViewDelegate>
@property (strong) Question *question;
@property (strong, nonatomic) IBOutlet UILabel *questionTitle;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *nestedView;
@property (strong, nonatomic) IBOutlet UITextView *questionText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewHeightConstraint;
@end
