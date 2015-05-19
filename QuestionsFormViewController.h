//
//  QuestionsFormViewController.h
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"
#import "ServerErrorDelegate.h"

@interface QuestionsFormViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, ServerErrorDelegate>
@property(strong) Question *question;
@property (strong, nonatomic) IBOutlet UITextField *questionTitle;
@property (strong, nonatomic) IBOutlet UITextField *questionCategory;
@property (strong, nonatomic) IBOutlet UITextView *questionText;
@property (strong, nonatomic) IBOutlet UITextField *questionTags;
- (IBAction)saveQuestion:(id)sender;
- (IBAction)hideForm:(id)sender;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *dismissFormButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveQuestionButton;


@end
