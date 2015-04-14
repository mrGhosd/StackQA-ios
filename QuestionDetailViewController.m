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
#import "AnswersViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "Api.h"

@interface QuestionDetailViewController (){
    Api *api;
    AppDelegate *app;
    NSManagedObjectContext *localContext;
    UIRefreshControl *refreshControl;
}

@end

@implementation QuestionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self uploadQuestionData];
    self.webView.delegate = self;
    [self refreshInit];
    [self initQuestionData];
    self.questionText.layoutManager.allowsNonContiguousLayout = NO;
    [self resizeView];
}
- (void) webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void) resizeView{
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    CGSize size = [self.question.text sizeWithAttributes:nil];
    float viewHeight;
    CGSize fittingSize = [self.webView sizeThatFits:CGSizeZero];
    float height_diff = self.view.frame.size.height - size.width;
    if(height_diff < 0){
        viewHeight = size.width / 9.9;
    } else {
        viewHeight = height_diff / 3;
    }
    self.webView.scrollView.scrollEnabled = NO;
    float fullViewHeight = viewHeight + self.questionTitle.frame.size.height + self.questionDate.frame.size.height + self.questionCategory.frame.size.height;
    self.viewAndScrollViewHeight.constant = fullViewHeight;
    [self.webView addConstraint:[NSLayoutConstraint
                                      constraintWithItem:self.webView
                                      attribute:NSLayoutAttributeHeight
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:self.webView
                                      attribute:NSLayoutAttributeHeight
                                      multiplier:1.0
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
}

- (void) parseQuestionData:(id) data{
    NSMutableDictionary *question = data;
    Question *qw = [Question MR_findFirstByAttribute:@"object_id" withValue:question[@"id"] inContext:localContext];
    if(qw){
        Question *q = qw;
        q.category = [SQACategory MR_createInContext:localContext];
        q.category.title = question[@"category"][@"title"];
        q.text = question[@"text"];
    
        [localContext MR_save];
    }
    [self initQuestionData];
    [refreshControl endRefreshing];
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
    if ([[segue identifier] isEqualToString:@"answers_list"]) {
        AnswersViewController *detail = segue.destinationViewController;
        detail.question = self.question;
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

- (void) refreshInit{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.scrollView addSubview:refreshView]; //the tableView is a IBOutlet
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    refreshControl.backgroundColor = [UIColor grayColor];
    [refreshView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(uploadQuestionData) forControlEvents:UIControlEventValueChanged];
}

-(void)reloadData
{
    if (refreshControl) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d, h:mm a"];
        NSString *title = [NSString stringWithFormat:@"Последнее обновление: %@", [formatter stringFromDate:[NSDate date]]];
        NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:[UIColor whiteColor]
                                                                    forKey:NSForegroundColorAttributeName];
        NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrsDictionary];
        refreshControl.attributedTitle = attributedTitle;
        
        [refreshControl endRefreshing];
    }
    [self initQuestionData];
}
@end
