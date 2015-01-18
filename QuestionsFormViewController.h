//
//  QuestionsFormViewController.h
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionsFormViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *questionTitle;
@property (strong, nonatomic) IBOutlet UITextView *questionText;
- (IBAction)saveQuestion:(id)sender;
- (IBAction)hideForm:(id)sender;

@end
