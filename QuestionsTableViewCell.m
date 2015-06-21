//
//  QuestionsTableViewCell.m
//  StackQA
//
//  Created by vsokoltsov on 19.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionsTableViewCell.h"

@implementation QuestionsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.questionRate.backgroundColor = [UIColor lightGrayColor];
    self.questionRate.textColor = [UIColor whiteColor];
    self.questionRate.clipsToBounds = YES;
    self.questionRate.layer.cornerRadius = 30;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) setQuestionData: (Question *) question{
    self.question = question ;
    self.questionTitle.text = question.title;
    self.questionDate.text = [NSString stringWithFormat:@"%@", (Question *)question.createdAt];
    self.questionRate.text = [NSString stringWithFormat:@"%@", question.rate];
    [self setQuestionRate];
    [self.viewsCount setTitle:[NSString stringWithFormat:@"%@", question.views] forState:UIControlStateNormal];
    [self.answersCount setTitle:[NSString stringWithFormat:@"%@", question.answersCount] forState:UIControlStateNormal];

    [self.commentsCount setTitle:[NSString stringWithFormat:@"%@", question.commentsCount] forState:UIControlStateNormal];
}
- (void) setQuestionRate{
    if(self.question.isClosed){
        self.questionRate.backgroundColor = [UIColor greenColor];
    } else {
        self.questionRate.backgroundColor = [UIColor lightGrayColor];
    }
    self.questionRate.textColor = [UIColor whiteColor];
    self.questionRate.clipsToBounds = YES;
    self.questionRate.layer.cornerRadius = 30;
}
- (IBAction)showCommentsList:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"commentsListForQuestion"
     object:self.question];
}

- (IBAction)showAnswersList:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"answersListForQuestion"
     object:self.question];

}
@end
