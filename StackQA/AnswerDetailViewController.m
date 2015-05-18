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
#import "ServerError.h"

@interface AnswerDetailViewController (){
    AuthorizationManager *auth;
    ServerError *serverError;
    UIButton *errorButton;
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
    self.answerDetailTextView.autocorrectionType = UITextAutocorrectionTypeNo;

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
    self.controlViewBottomMargin.constant = textViewConstraint;
}
- (void) keyboardWillHide:(NSNotification *) notification{
    self.controlViewBottomMargin.constant = 0.0;
    self.scrollViewBottomMargin.constant = self.controlView.frame.size.height;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) updateWithParams:(NSDictionary *) params andSuccess:(BOOL) success{
    if(success){
        errorButton.hidden = YES;
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"reloadAnswers"
         object:params];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        serverError = [[ServerError alloc] initWithData:params];
        serverError.delegate = self;
        [serverError handle];
//        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (void) handleServerErrorWithError:(id)error{
    if(errorButton){
        errorButton.hidden = NO;
    } else {
        errorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        errorButton.backgroundColor = [UIColor lightGrayColor];
        NSString *errorText;
        if([error messageText]){
            errorText = [error messageText];
        } else {
            errorText = NSLocalizedString(@"server-connection-disabled", nil);
        }
        [errorButton setTitle:errorText forState:UIControlStateNormal];
        [errorButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.scrollView addSubview:errorButton];
    }
}

- (void) handleServerFormErrorWithError:(id)error{
    NSMutableString *finalResult = [NSMutableString stringWithString:@""];
    NSMutableString *attribute;
    
    for (NSString *key in [serverError.message allKeys]){
        NSString *localizedStringName = [NSString stringWithFormat:@"answer-%@", key];
        attribute = NSLocalizedString(localizedStringName, nil);
        [finalResult appendString:[NSString stringWithFormat:@"%@ - ",attribute]];
        
        for(NSString *message in serverError.message[key]){
            [finalResult appendString:[NSString stringWithFormat:@"%@ ", message]];
        }
        
    }
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:finalResult delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil, nil];
    [alert show];
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
