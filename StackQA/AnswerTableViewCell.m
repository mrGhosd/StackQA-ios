//
//  AnswerTableViewCell.m
//  StackQA
//
//  Created by vsokoltsov on 24.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "AnswerTableViewCell.h"

@implementation AnswerTableViewCell

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

@end
