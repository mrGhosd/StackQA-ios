//
//  QuestionsTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 19.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"
#import <SWTableViewCell.h>

@interface QuestionsTableViewCell : SWTableViewCell
@property (strong) Question *question;
@property (strong, nonatomic) IBOutlet UILabel *questionTitle;
@property (strong, nonatomic) IBOutlet UILabel *questionDate;
@property (strong, nonatomic) IBOutlet UILabel *questionRate;
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) IBOutlet UIButton *answersCount;
@property (strong, nonatomic) IBOutlet UIButton *commentsCount;
- (IBAction)showCommentsList:(id)sender;
- (IBAction)showAnswersList:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *viewsCount;
- (void) setQuestionData: (Question *) question;
@end
