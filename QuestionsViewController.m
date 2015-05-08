//
//  QuestionsViewController.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionsViewController.h"
#import "QuestionCategoryView.h"
#import "AppDelegate.h"
#import "QuestionDetailViewController.h"
#import "QuestionsFormViewController.h"
#import "CategoryDetailViewController.h"
#import <CoreData+MagicalRecord.h>
#import "QuestionsTableViewCell.h"
#import "Question.h"
#import "SWRevealViewController.h"
#import "Api.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AuthorizationManager.h"

@interface QuestionsViewController (){
    Question *currentQuestion;
    AuthorizationManager *auth;
    Api *api;
    UIApplication *app;
    NSMutableArray *questionsArray;
}

@end

@implementation QuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserValue) name:@"getCurrentUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(answersListForQuestion:) name:@"answersListForQuestion" object:currentQuestion];
    auth = [AuthorizationManager sharedInstance];
    [self defineNavigationPanel];
    [self pageType];
    [self.tableView reloadData];
    [self toggleCrateQuestionButton];
}

- (void) answersListForQuestion:(NSNotification *) notification{
    currentQuestion = notification.object;
    [self performSegueWithIdentifier:@"showAnswersListForQuestion" sender:self];
}
- (void) pageType{
    if(self.user_page){
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ - вопросы", self.user_page.correct_naming]];
        [self showUserQuestions];
    } else if(self.category){
        [self loadCategoryQuestion];
    }
    else {
        [self showQuestions];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(self.category != nil){
        return 100;
    } else {
        return 0;
    }
}
- (void) loadCategoryQuestion{
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    [[Api sharedManager] getData:[NSString stringWithFormat:@"/categories/%@/questions", self.category.object_id] andComplition:^(id data, BOOL result){
        if(result){
            [self parseCategoriesQuestions:data];
        } else {
            NSLog(@"data is %@", data);
        }
    }];
    [self.tableView reloadData];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.1f)];
    if(self.category != nil){
        QuestionCategoryView *view = [[[NSBundle mainBundle] loadNibNamed:@"categoryHeader" owner:self options:nil] firstObject];
        view.categoryImageView.image = [self.category categoryImage];
        view.categoryImageView.layer.cornerRadius = 8.0;
        view.categoryImageView.clipsToBounds = YES;
        view.categoryWebView.backgroundColor = [UIColor clearColor];
        view.categoryWebView.opaque = NO;
        view.categoryWebView.scrollView.scrollEnabled = NO;
        view.categoryTitle.text = self.category.title;
        [view.categoryWebView loadHTMLString:self.category.desc baseURL:nil];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [view addGestureRecognizer:singleFingerTap];
        return view;
    } else {
        return view;
    }
}
- (void) handleSingleTap: (UITapGestureRecognizer *)recognizer{
    [self performSegueWithIdentifier:@"categoryDetail" sender:self];
}

-(void) currentUserValue{
    [self toggleCrateQuestionButton];
    [self.tableView reloadData];
}
- (void) showQuestions{
    [self loadQuestions];
}

- (void) showUserQuestions{
    api = [Api sharedManager];
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    [api getData:[NSString stringWithFormat:@"/users/%@/questions", self.user_page.object_id] andComplition:^(id data, BOOL result){
        if(result){
            [self parseUserQuestionsData:data];
        } else {
            NSLog(@"data is %@", data);
        }
    }];
    [self.tableView reloadData];
}

- (void) toggleCrateQuestionButton{
    if([[AuthorizationManager sharedInstance] currentUser]){
        self.addQuestion.enabled = YES;
    } else {
        self.addQuestion.enabled = NO;
    }
    [self.tableView reloadData];
}
- (void) loadQuestions{
    api = [Api sharedManager];
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    [api getData:@"/questions" andComplition:^(id data, BOOL result){
        if(result){
            [self parseQuestionsData:data];
        } else {
            NSLog(@"data is %@", data);
        }
    }];
    [self.tableView reloadData];
}

-(void) defineNavigationPanel{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController ){
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        revealViewController.rightViewController = nil;
    }
}
- (void) parseQuestionsData:(id) data{
    NSMutableArray *questions = data[@"questions"];
    [Question sync:questions];
    self.questions = [NSMutableArray arrayWithArray:[Question MR_findAll]];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void) parseCategoriesQuestions: (id) data{
    NSMutableArray *questions = data[@"categories"];
    [Question sync:questions];
    self.questions = [self.category questionsList];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void) parseUserQuestionsData:(id) data{
    NSMutableArray *questions = data[@"questions"];
    for(NSDictionary *question in questions){
        [Question create:question];
    }
    [Question setQuestionsForUser:self.user_page];
    self.questions = [NSMutableArray arrayWithArray:[self.user_page.questions allObjects]];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self toggleCrateQuestionButton];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.questions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Question *questionItem = [self.questions objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"questionCell";
    QuestionsTableViewCell *cell = (QuestionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setQuestionData:questionItem];
    cell.questionTitle.text = (Question *)questionItem.title;
    cell.questionDate.text = [NSString stringWithFormat:@"%@", (Question *)questionItem.created_at];
    cell.questionRate.text = [NSString stringWithFormat:@"%@", questionItem.rate];
    [self setQuestionRateViewForCell:cell andItem:questionItem];
    [cell.viewsCount setTitle:[NSString stringWithFormat:@"%@", questionItem.views] forState:UIControlStateNormal];
    [cell.answersCount setTitle:[NSString stringWithFormat:@"%@", questionItem.answers_count] forState:UIControlStateNormal];
    [cell.commentsCount setTitle:[NSString stringWithFormat:@"%@", questionItem.comments_count] forState:UIControlStateNormal];
    
    if(auth.currentUser && [questionItem.user_id integerValue] == [auth.currentUser.object_id integerValue]){
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                     icon:[UIImage imageNamed:@"edit-32.png"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
        cell.rightUtilityButtons = rightUtilityButtons;
        cell.delegate = self;
    }
    return cell;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            currentQuestion = self.questions[cellIndexPath.row];
            [self performSegueWithIdentifier:@"showQuestionForm" sender:self];
            break;
        }
        case 1:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            currentQuestion = self.questions[cellIndexPath.row];
            [api sendDataToURL:[NSString stringWithFormat:@"/questions/%@", currentQuestion.object_id] parameters:@{} requestType:@"DELETE" andComplition:^(id data, BOOL success){
                if(success){
                    [self.questions removeObjectAtIndex:cellIndexPath.row];
                    [currentQuestion MR_deleteEntity];
                    if(self.questions.count == 0){
                        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:cellIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                    } else {
                        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }

                } else {
                    
                }
            }];
            break;
        }
        default:
            break;
    }
}


- (void) setQuestionRateViewForCell:(QuestionsTableViewCell *) cell andItem: (Question *) question{
    if(question.is_closed){
        cell.questionRate.backgroundColor = [UIColor greenColor];
    } else {
        cell.questionRate.backgroundColor = [UIColor lightGrayColor];
    }
    cell.questionRate.textColor = [UIColor whiteColor];
    cell.questionRate.clipsToBounds = YES;
    cell.questionRate.layer.cornerRadius = 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showQuestion"]) {
        Question *question = [self.questions objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        QuestionDetailViewController *detail = segue.destinationViewController;
        detail.question = question;
    }
    if([[segue identifier] isEqualToString:@"showQuestionForm"]){
        Question *question = [self.questions objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        QuestionsFormViewController *form = segue.destinationViewController;
        form.question = currentQuestion;
    }
    if([[segue identifier] isEqualToString:@"showAnswersListForQuestion"]){
        QuestionsFormViewController *form = segue.destinationViewController;
        form.question = currentQuestion;
    }
    if([[segue identifier] isEqualToString:@"categoryDetail"]){
        CategoryDetailViewController *view = segue.destinationViewController;
        view.category = self.category;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showQuestion" sender:self];
}

- (NSDate *) correctConvertOfDate:(NSString *) date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *correctDate = [dateFormat dateFromString:date];
    return correctDate;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
