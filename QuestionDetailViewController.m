//
//  QuestionDetailViewController.m
//  StackQA
//
//  Created by vsokoltsov on 19.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionDetailViewController.h"

@interface QuestionDetailViewController ()

@end

@implementation QuestionDetailViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initQuestionData];
    
//    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y,
//                                                                          self.view.frame.size.width, self.view.frame.size.height)];
//    UITextView *text = [[UITextView alloc] initWithFrame:CGRectMake(10, 100, 320, 800)];
//    UIView *nestedView = [[UIView alloc] init];
//    [self.view addSubview:scroll];
//    [scroll addSubview:text];
//    
//    scroll.translatesAutoresizingMaskIntoConstraints  = NO;
//    text.translatesAutoresizingMaskIntoConstraints = NO;
//    
//
//    
//    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(scroll, text);
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scroll]|" options:0 metrics: 0 views:viewsDictionary]];
//    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scroll]|" options:0 metrics: 0 views:viewsDictionary]];
//    [scroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[text]|" options:0 metrics: 0 views:viewsDictionary]];
//    [scroll addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[text]|" options:0 metrics: 0 views:viewsDictionary]];
//    
//    text.text = self.question.questionDetail.text;
//    [scroll layoutIfNeeded];
//    [text sizeToFit];

//    float sizeOfContent = 0;
////    UIView *lLast = [self.scrollView.subviews firstObject];
//    NSInteger wd = view.frame.origin.y;
//    NSInteger ht = view.frame.size.height;
//
//    self.scrollView.translatesAutoresizingMaskIntoConstraints = YES;
//    lLast.translatesAutoresizingMaskIntoConstraints = YES;
//    
//    sizeOfContent = wd+ht;
//    self.questionText.scrollEnabled = NO;
//    self.questionText.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, sizeOfContent);
//    CGRect frame = text.frame;
//    self.scrollView.frame = CGRectMake(0, 0, 320, 600);
//    lLast.frame = CGRectMake(0, 0, 320, self.scrollView.frame.size.height + 1000);
//    self.scrollView.contentSize = CGSizeMake(320, 1800);
//    frame.size.height = text.contentSize.height;

//    [self initQuestionData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) initQuestionData{
    self.questionTitle.text = self.question.title;
    self.questionText.text = self.question.questionDetail.text;
    [self.questionText sizeToFit];
//    self.webViewHeightConstraint.constant = self.questionText.frame.size.height + 200;
//    [self.questionText layoutIfNeeded];
    self.nestedView.translatesAutoresizingMaskIntoConstraints = YES;
    self.questionText.scrollEnabled = NO;
    [self textViewDidChange:self.questionText];
    self.nestedView.frame = CGRectMake(0, 0, 320, self.questionText.frame.size.height + 450);

//    self.questionText.frame = CGRectMake(self.questionText.frame.origin.x, self.questionText.frame.origin.y, self.questionText.frame.size.width, 25000.0);
//    self.questionText.contentSize = CGSizeMake(320, 25000.0);
//    [self textViewDidChange:self.questionText];
//    self.questionText.scrollEnabled = NO;
    
//    self.scrollView.frame = CGRectMake(0, 0, 320, 25000);
//    self.scrollView.contentSize = CGSizeMake(320, 25000);
//    view.frame = CGRectMake(0,0, 320,250000);
//    self.view.frame = CGRectMake(0, 0, 320, 25000);
//    NSDictionary *viewsDictionary = @{@"scroll":self.scrollView, @"view": view};
//    self.scrollView. = self.view.frame.size.height;
    
//    self.bottomConstraint.constant = 1000.0;
}
- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = 320;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
}

-(void) viewDidAppear:(BOOL)animated{
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
