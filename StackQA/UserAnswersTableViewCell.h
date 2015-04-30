//
//  UserAnswersTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 28.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import "Question.h"

@interface UserAnswersTableViewCell : SWTableViewCell
@property (strong, nonatomic) IBOutlet UILabel *answerRate;
@property (strong, nonatomic) IBOutlet UIButton *answerQuestion;
@property (strong, nonatomic) IBOutlet UIWebView *answerText;
@property (strong) Question *question;
- (void) setQUestionData: (Question *) question;
@end
