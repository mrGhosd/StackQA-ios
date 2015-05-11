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
#import <BENTagsView.h>
#import "RatingDelegate.h"
#import "QuestionDelegate.h"

@interface QuestionDetailViewController : UIViewController <UITextViewDelegate, UIWebViewDelegate, RatingDelegate>
@property (strong) Question *question;
@property (strong, nonatomic) IBOutlet UILabel *questionTitle;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView *nestedView;
//- (IBAction)deleteQuestion:(id)sender;
@property (strong, nonatomic) IBOutlet UILabel *questionDate;
@property (strong, nonatomic) IBOutlet UIButton *questionCategory;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIButton *commentsCount;
@property (strong, nonatomic) IBOutlet UIButton *answersCount;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *viewAndScrollViewHeight;
- (IBAction)questionPopupView:(id)sender;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *questionTextHeight;
@property (strong, nonatomic) IBOutlet UIButton *authorProfileLink;
@property (strong, nonatomic) IBOutlet UILabel *questionRate;
@property (strong, nonatomic) IBOutlet UIView *questionInfoView;
@property (strong, nonatomic) IBOutlet BENTagsView *tagsView;
@property (strong, nonatomic) IBOutlet UIView *buttonsView;
@property (strong, nonatomic) IBOutlet UIButton *upRateButton;
@property (strong, nonatomic) IBOutlet UIButton *downRateButton;
@property (strong, nonatomic) IBOutlet UIButton *questionAuthorButton;
@property (strong, nonatomic) IBOutlet UIView *controlView;

- (IBAction)increaseRate:(id)sender;
- (IBAction)decreaseRate:(id)sender;



- (IBAction)showQuestionCategory:(id)sender;
- (IBAction)showQuestionAuthor:(id)sender;



@end
