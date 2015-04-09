//
//  QuestionsViewController.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionsViewController.h"
#import "AppDelegate.h"
#import "QuestionDetailViewController.h"
#import "QuestionsFormViewController.h"
#import <CoreData+MagicalRecord.h>
#import "QuestionsTableViewCell.h"
#import "Question.h"
#import "SWRevealViewController.h"
#import "Api.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AuthorizationManager.h"

@interface QuestionsViewController (){
    AuthorizationManager *auth;
    Api *api;
    UIApplication *app;
    NSArray *questionsArray;
}

@end

@implementation QuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserValue) name:@"getCurrentUser" object:nil];
    auth = [AuthorizationManager sharedInstance];
    questionsArray = [Question MR_findAll];
    [self defineNavigationPanel];
    [self showQuestions];
    self.questions = [Question MR_findAll];
    [self.tableView reloadData];
    [self toggleCrateQuestionButton];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void) currentUserValue{
    [self toggleCrateQuestionButton];
    [self.tableView reloadData];
}
- (void) showQuestions{
    [self loadQuestions];
}
- (BOOL) questionsExists{
    if(questionsArray.count > 0){
        return true;
    } else {
        return false;
    }
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
            questionsArray = [NSArray arrayWithArray:data[@"questions"]];
        }
    }];
    self.questions = [Question MR_findAll];
    [self.tableView reloadData];
}

-(void) defineNavigationPanel{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        revealViewController.rightViewController = nil;
        
    }
}
- (void) parseQuestionsData:(id) data{
    NSMutableArray *questions = data[@"questions"];
    for(NSDictionary *question in questions){
        [Question create:question];
    }
    self.questions = [NSArray arrayWithArray:[Question MR_findAll]];
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
    self.questions = [Question MR_findAll];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
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
     NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    cell.questionTitle.text = (Question *)questionItem.title;
    cell.questionDate.text = [NSString stringWithFormat:@"%@", (Question *)questionItem.created_at];
    cell.questionRate.text = [NSString stringWithFormat:@"%@", questionItem.rate];
    [self setQuestionRateViewForCell:cell];
    [cell.viewsCount setTitle:[NSString stringWithFormat:@"%@", questionItem.views] forState:UIControlStateNormal];
    [cell.answersCount setTitle:[NSString stringWithFormat:@"%@", questionItem.answers_count] forState:UIControlStateNormal];
    [cell.commentsCount setTitle:[NSString stringWithFormat:@"%@", questionItem.comments_count] forState:UIControlStateNormal];
    return cell;
}
- (void) setQuestionRateViewForCell:(QuestionsTableViewCell *) cell{
    cell.questionRate.backgroundColor = [UIColor lightGrayColor];
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
        form.question = question;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
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
