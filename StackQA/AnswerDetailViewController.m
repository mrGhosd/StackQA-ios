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
    NSString *url = [NSString stringWithFormat:@"/questions/%@/answers/%@", self.answer.question_id, self.answer.object_id];
    NSDictionary *params = @{@"question_id": self.answer.object_id, @"user_id": auth.currentUser.object_id, @"text": self.answerDetailTextView.text };
    [[Api sharedManager] sendDataToURL:url parameters:params requestType:@"PUT" andComplition:^(id data, BOOL success){
        if(success){
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"updateAnswer"
             object:self];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            
        }
    }];
}
@end
