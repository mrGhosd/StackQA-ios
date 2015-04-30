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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void) setQUestionData: (Question *) question{
    Question *q = question;
    self.question = q;
}

- (IBAction)showAnswerQuestion:(id)sender {
    Question *q = self.question;
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"showAnswerQuestion"
     object:self.question];
}
@end
