//
//  QuestionDetailViewController.m
//  StackQA
//
//  Created by vsokoltsov on 19.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionDetailViewController.h"
#import "QuestionsFormViewController.h"

@interface QuestionDetailViewController ()

@end

@implementation QuestionDetailViewController 

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initQuestionData];
    [self viewSizeSettings];
    
}
-(void) viewDidAppear:(BOOL)animated{
    [self initQuestionData];
    [self viewSizeSettings];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) initQuestionData{
    self.questionTitle.text = self.question.title;
    self.questionText.text = self.question.questionDetail.text;
    
}

- (void) viewSizeSettings{
    [self.questionText sizeToFit];
    self.nestedView.translatesAutoresizingMaskIntoConstraints = YES;
    self.questionText.scrollEnabled = NO;
    [self textViewDidChange:self.questionText];
    self.nestedView.frame = CGRectMake(0, 0, 320, self.questionText.frame.size.height + 450);
}

- (void)textViewDidChange:(UITextView *)textView
{
    CGFloat fixedWidth = 320;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    textView.frame = newFrame;
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"updateQuestion"]){
        QuestionsFormViewController *form = segue.destinationViewController;
        form.question = self.question;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


- (IBAction)editQuestion:(id)sender {
}
@end
