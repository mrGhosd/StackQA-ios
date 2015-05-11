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
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor yellowColor] icon:[UIImage imageNamed:@"up-32.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor yellowColor] icon:[UIImage imageNamed:@"down-32.png"]];
    if(!question.isClosed && !answer.isHelpfull){
        [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor] icon:[UIImage imageNamed:@"correct6.png"]];
    }
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                 icon:[UIImage imageNamed:@"edit-32.png"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
    self.leftUtilityButtons = leftUtilityButtons;
    self.rightUtilityButtons = rightUtilityButtons;
    self.delegate = self;
    
    self.answerQuestion.tag = [questionId integerValue];
    
    [self.answerText loadHTMLString: answer.text baseURL:nil];
}
@end
