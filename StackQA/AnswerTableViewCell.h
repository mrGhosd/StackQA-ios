//
//  AnswerTableViewCell.h
//  StackQA
//
//  Created by vsokoltsov on 24.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AnswerTableViewCell : UITableViewCell <UIWebViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *answerRate;
@property (strong, nonatomic) IBOutlet UIWebView *answerText;

@end
