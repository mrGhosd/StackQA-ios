//
//  AnswerDetailViewController.m
//  StackQA
//
//  Created by vsokoltsov on 22.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "AnswerDetailViewController.h"
#import "AuthorizationManager.h"
#import "Api.h"

@interface AnswerDetailViewController (){
    AuthorizationManager *auth;
}

@end

@implementation AnswerDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.answer.answerDelegate = self;
    auth = [AuthorizationManager sharedInstance];
    // Do any additional setup after loading the view.
    self.answerDismissButton.layer.cornerRadius = 5.0;
    self.answerSaveButton.layer.cornerRadius = 5.0;
    self.answerDetailTextView.text = self.answer.text;

    float viewHeight;
    CGSize size = [self.answerDetailTextView.text sizeWithAttributes:nil];
    float height_diff = self.view.frame.size.height - size.width;
    if(height_diff < 0){
        viewHeight = size.width / 12.9;
    } else {
        viewHeight = height_diff / 1.1;
    }

    self.answerDetailTextViewHeightConstraint.constant = viewHeight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) updateWithParams:(NSDictionary *) params andSuccess:(BOOL) success{
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"updateAnswer"
     object:params];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dissmissDetailAnswerView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)answerSave:(id)sender {
    NSDictionary *params = @{@"question_id": self.answer.questionId, @"user_id": auth.currentUser.objectId, @"text": self.answerDetailTextView.text };
    [self.answer update:params];
}
@end
