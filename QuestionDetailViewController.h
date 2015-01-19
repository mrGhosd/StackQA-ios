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

@interface QuestionDetailViewController : UIViewController
@property(nonatomic, strong) NSDictionary *dict;
@property (strong) Question *question;
@property (strong, nonatomic) IBOutlet UILabel *questionTitle;
@property (strong, nonatomic) IBOutlet UITextView *questionText;
@end
