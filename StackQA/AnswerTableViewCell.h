//
//  AnswerTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 24.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
@interface AnswerTableViewCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *answerRate;
@property (strong, nonatomic) IBOutlet UIWebView *answerText;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *answerTextHeight;

@end
