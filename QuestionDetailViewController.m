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
#import "CommentsListViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AppDelegate.h"
#import "Api.h"

@interface QuestionDetailViewController (){
    Api *api;
    User *author;
    AppDelegate *app;
    NSManagedObjectContext *localContext;
    UIRefreshControl *refreshControl;
}

@end

@implementation QuestionDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webView.delegate = self;
    [self refreshInit];
    [self resizeView];
    
}
- (void) webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (void) resizeView{
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.scrollView.scrollEnabled = NO;
    CGSize size = [self.question.text sizeWithAttributes:nil];
    float viewHeight;
    CGSize fittingSize = [self.webView sizeThatFits:CGSizeZero];
    viewHeight = size.width / 10.0;

    self.questionTextHeight.constant = viewHeight;
}
- (void) uploadQuestionData{
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    api = [Api sharedManager];
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    Question *currentQuestion = [self.question MR_inContext:localContext];
    [api getData:[NSString stringWithFormat:@"/questions/%@", currentQuestion.object_id] andComplition:^(id data, BOOL result){
        if(result){
            [self parseQuestionData:data];
        } else {
            NSLog(@"data is %@", data);
        }
    }];
}
-(void) viewDidAppear:(BOOL)animated{
//    [self uploadQuestionData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self uploadQuestionData];
}

- (void) parseQuestionData:(id) data{
    NSMutableDictionary *question = data;
    [Question create:data];
    Question *qw = [Question MR_findFirstByAttribute:@"object_id" withValue:question[@"id"] inContext:localContext];
    if(qw){
        Question *q = qw;
        q.category = [SQACategory MR_createInContext:localContext];
        q.category.title = question[@"category"][@"title"];
        q.text = question[@"text"];
        self.question = q;
        [localContext MR_save];
    }
    author = [User create:data[@"user"]];
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
    
    [self.authorProfileLink setTitle:nil forState:UIControlStateNormal];
//    [self.authorProfileLink setImage:[author profileImage] forState:UIControlStateNormal];
//    self.authorProfileLink.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [self.authorProfileLink setBackgroundImage:[author profileImage] forState:UIControlStateNormal];
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
    if([[segue identifier] isEqualToString:@"commentsQuestionView"]){
        CommentsListViewController *view = segue.destinationViewController;
        view.question = self.question;
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
