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
    [self.scrollView addConstraint:[NSLayoutConstraint
                              constraintWithItem:self.scrollView
                              attribute:NSLayoutAttributeHeight
                              relatedBy:NSLayoutRelationEqual
                              toItem:self.scrollView
                              attribute:NSLayoutAttributeHeight
                              multiplier:0.5
                              constant:10000.0]];
        [self.nestedView addConstraint:[NSLayoutConstraint
                                  constraintWithItem:self.nestedView
                                  attribute:NSLayoutAttributeHeight
                                  relatedBy:NSLayoutRelationEqual
                                  toItem:self.nestedView
                                  attribute:NSLayoutAttributeHeight
                                  multiplier:0.5
                                  constant:10000.0]];
    
    [self.questionText addConstraint:[NSLayoutConstraint
                                    constraintWithItem:self.questionText
                                    attribute:NSLayoutAttributeHeight
                                    relatedBy:NSLayoutRelationEqual
                                    toItem:self.questionText
                                    attribute:NSLayoutAttributeHeight
                                    multiplier:0.5
                                    constant:10000.0]];
//    [self.questionText sizeToFit];
//    self.nestedView.translatesAutoresizingMaskIntoConstraints = NO;

    
//    [self viewSizeSettings];
//    [self uploadQuestionData];
//    [self.questionText.layoutManager ensureLayoutForTextContainer:self.questionText.textContainer];
    
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
//    self.questionTitle.text = self.question.title;
    self.questionText.text = self.question.text;
//    self.questionDate.text = [NSString stringWithFormat:@"%@", self.question.created_at];
//    self.questionCategory.text = self.question.category.title;
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
@end
