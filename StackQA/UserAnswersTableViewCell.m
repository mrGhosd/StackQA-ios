//
//  UserAnswersTableViewCell.m
//  StackQA
//
//  Created by vsokoltsov on 28.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "UserAnswersTableViewCell.h"

@implementation UserAnswersTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.answerText.delegate = self;
    self.answerText.backgroundColor = [UIColor clearColor];
    self.answerText.scrollView.scrollEnabled = NO;
    self.answerRate.backgroundColor = [UIColor lightGrayColor];
    self.answerRate.textColor = [UIColor whiteColor];
    self.answerRate.clipsToBounds = YES;
    self.answerRate.layer.cornerRadius = 30;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) setQUestionData: (Question *) question{
    Question *q = question;
    self.question = q;
}
- (void) setCellDataWithQuestion: (Question *) question andAnswer: (Answer *) answer{
    if(question != nil){
        [self.answerQuestion setTitle: question.title  forState:UIControlStateNormal];
    }
    self.answerRate.text = [NSString stringWithFormat:@"%@", answer.rate];
    NSNumber *questionId = question.objectId;
    
    if(answer.isHelpfull){
        self.answerRate.backgroundColor = [UIColor greenColor];
    } else {
        self.answerRate.backgroundColor = [UIColor lightGrayColor];
    }
    
    
    
    self.answerQuestion.tag = [questionId integerValue];
    
    [self.answerText loadHTMLString: answer.text baseURL:nil];
}
@end
