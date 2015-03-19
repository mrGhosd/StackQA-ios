//
//  QuestionDetailViewController.m
//  StackQA
//
//  Created by vsokoltsov on 19.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionDetailViewController.h"
#import "QuestionsFormViewController.h"
#import "QuestionsViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "Api.h"

@interface QuestionDetailViewController (){
    Api *api;
    AppDelegate *app;
    NSManagedObjectContext *localContext;
}

@end

@implementation QuestionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initQuestionData];
    self.questionText.layoutManager.allowsNonContiguousLayout = NO;
    [self resizeView];
    
//    [self.questionText sizeToFit];
//    self.nestedView.translatesAutoresizingMaskIntoConstraints = NO;

    
//    [self viewSizeSettings];
//    [self uploadQuestionData];
//    [self.questionText.layoutManager ensureLayoutForTextContainer:self.questionText.textContainer];
    
}

- (void) resizeView{

//    [self.questionText setTextContainerInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    CGSize size_view = [self.webView.scrollView sizeThatFits:CGSizeMake(self.questionText.frame.size.width, FLT_MAX)];
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView.scrollView sizeThatFits:CGSizeMake(self.questionText.frame.size.width, FLT_MAX)].height;
    CGSize size = [self.question.text sizeWithAttributes:nil];
    float viewHeight;
    float height_diff = self.view.frame.size.height - size.width;
    if(height_diff < 0){
        viewHeight = size.width / 20.615 - 2000;
    } else {
        viewHeight = height_diff / 3;
    }
    self.webView.scrollView.scrollEnabled = NO;
//    [self.webView sizeToFit];
//    [self.scrollView addConstraint:[NSLayoutConstraint
//                                    constraintWithItem:self.scrollView
//                                    attribute:NSLayoutAttributeHeight
//                                    relatedBy:NSLayoutRelationEqual
//                                    toItem:self.scrollView
//                                    attribute:NSLayoutAttributeHeight
//                                    multiplier:0.5
//                                    constant:viewHeight]];
//    [self.nestedView addConstraint:[NSLayoutConstraint
//                                    constraintWithItem:self.nestedView
//                                    attribute:NSLayoutAttributeHeight
//                                    relatedBy:NSLayoutRelationEqual
//                                    toItem:self.nestedView
//                                    attribute:NSLayoutAttributeHeight
//                                    multiplier:0.5
//                                    constant:viewHeight]];
    
    [self.webView addConstraint:[NSLayoutConstraint
                                      constraintWithItem:self.webView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.webView
                                      attribute:NSLayoutAttributeHeight
                                      multiplier:0.5
                                      constant:viewHeight]];
}
- (void) uploadQuestionData{
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    api = [Api sharedManager];
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    [api getData:[NSString stringWithFormat:@"/questions/%@", self.question.object_id] andComplition:^(id data, BOOL result){
        if(result){
            [self parseQuestionData:data];
        } else {
            NSLog(@"data is %@", data);
        }
    }];
}
-(void) viewDidAppear:(BOOL)animated{
//    [self viewSizeSettings];
}

- (void) parseQuestionData:(id) data{
    NSMutableDictionary *question = data;
    Question *qw = [Question MR_findFirstByAttribute:@"object_id" withValue:question[@"id"] inContext:localContext];
    if(qw){
        Question *q = qw;
//        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
//            Question *q = [Question MR_createInContext:localContext];
        q.category = [SQACategory MR_createInContext:localContext];
        q.category.title = question[@"category"][@"title"];
        q.text = question[@"text"];
    
        [localContext MR_save];
//        [self initQuestionData:q];
//        }];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) initQuestionData{
    self.questionTitle.text = self.question.title;
    [self.webView loadHTMLString:self.question.text baseURL:nil];
    self.questionDate.text = [NSString stringWithFormat:@"%@", self.question.created_at];
    self.questionCategory.text = self.question.category.title;
    [self.answersCount setTitle:[NSString stringWithFormat:@"%@", self.question.answers_count] forState:UIControlStateNormal];
    [self.commentsCount setTitle:[NSString stringWithFormat:@"%@", self.question.comments_count] forState:UIControlStateNormal];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
//    [self viewSizeSettings];
}

- (void) viewSizeSettings{
    [self.questionText sizeToFit];
    self.nestedView.translatesAutoresizingMaskIntoConstraints = YES;
    self.questionText.scrollEnabled = NO;
    [self textViewDidChange:self.questionText];
//    self.questionText.contentSize.height
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

-(void) findQuestionAndDelete{
    NSManagedObjectContext *localContext    = [NSManagedObjectContext MR_contextForCurrentThread];
    if(self.question){
        [self.question MR_deleteEntity];
        [localContext MR_save];
    }
    else{
        [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Данный вопрос не найден" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    }
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"updateQuestion"]){
        QuestionsFormViewController *form = segue.destinationViewController;
        form.question = self.question;
    }
    if([[segue identifier] isEqualToString:@"afterDeleteQuestion"]){
        QuestionsViewController *view = segue.destinationViewController;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
-(IBAction)deleteQuestion:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Сообшение" message:@"Вы действительно хотите удалить вопрос?" delegate:self cancelButtonTitle:@"Нет" otherButtonTitles:@"Да", nil];
    [alert show];
}
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex){
            case 1:
            [self findQuestionAndDelete];
            break;
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}
- (IBAction)questionPopupView:(id)sender {
        UIActionSheet *popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:nil otherButtonTitles:
                                @"+1",
                                @"-1",
                                @"Редактировать",
                                @"Удалить",
                                nil];
        popup.tag = 1;
        [popup showInView:self.nestedView];
}

- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch(buttonIndex)
    {
        case 0:
            break;
        case 1:
            break;
        case 2:
            break;
    }
}
@end
