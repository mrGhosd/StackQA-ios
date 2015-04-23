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
}
- (IBAction)showAnswersList:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"answersListForQuestion"
     object:self.question];

}
@end
