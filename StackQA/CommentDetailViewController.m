//
//  CommentDetailViewController.m
//  StackQA
//
//  Created by vsokoltsov on 06.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "Api.h"
#import "AuthorizationManager.h"

@interface CommentDetailViewController (){
    AuthorizationManager *auth;
}

@end

@implementation CommentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setActionView];
    auth = [AuthorizationManager sharedInstance];
    self.commentText.text = self.comment.text;
    self.commentText.autocorrectionType = UITextAutocorrectionTypeNo;
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *keyboardValues = [notification userInfo];
    id keyboardSize = keyboardValues[@"UIKeyboardFrameEndUserInfoKey"];
    CGRect keyboardFrame = [keyboardSize CGRectValue];
    int orientation = (int)[[UIDevice currentDevice] orientation];
    float textViewConstraint = keyboardFrame.size.height;
    self.scrollViewBottomMargin.constant = textViewConstraint + self.controlView.frame.size.height;
    self.actionViewBottomMargin.constant = textViewConstraint;
}
- (void) keyboardWillHide:(NSNotification *) notification{
    self.actionViewBottomMargin.constant = 0.0;
    self.scrollViewBottomMargin.constant = self.controlView.frame.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) setActionView{
    self.saveButton.layer.cornerRadius = 5.0;
    self.cancelButton.layer.cornerRadius = 5.0;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveComment:(id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"user_id": auth.currentUser.objectId, @"question_id": self.question.objectId, @"text": self.commentText.text}];
    NSString *url = [NSString stringWithFormat:@"/questions/%@/comments/%@", self.question.objectId, self.comment.objectId];
    
//    if(self.answer){
//        [params addEntriesFromDictionary:@{@"answer_id": self.answer.object_id}];
//        url = [NSString stringWithFormat:@"/questions/%@/answers/%@/comments/%@", self.question.objectId, self.answer.object_id, self.comment.object_id];
//    }
    [[Api sharedManager] sendDataToURL:url parameters:params requestType:@"PUT" andComplition:^(id data, BOOL success){
        if(success){
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            
        }
    }];
}

- (IBAction)dissmissView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
