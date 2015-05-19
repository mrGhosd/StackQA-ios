//
//  UserAnswersViewController.m
//  StackQA
//
//  Created by vsokoltsov on 24.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "UserAnswersViewController.h"
#import "QuestionDetailViewController.h"
#import "Api.h"
#import "Answer.h"
#import "Question.h"
#import "AuthorizationManager.h"
#import "AnswerDetailViewController.h"
#import "UserAnswersTableViewCell.h"
#import "ServerError.h"
#import <MBProgressHUD.h>
#import <UIScrollView+InfiniteScroll.h>

@interface UserAnswersViewController (){
    AuthorizationManager *auth;
    Question *chosenQuestion;
    Answer *currentAnswer;
    NSNumber *pageNumber;
    float currentCellHeight;
    int selectedIndex;
    NSMutableArray *usersAnswersList;
    NSMutableArray *answerQuestionsList;
    UIRefreshControl *refreshControl;
    ServerError *serverError;
    UIButton *errorButton;
}

@end

@implementation UserAnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = -1;
    pageNumber = @1;
    usersAnswersList = [NSMutableArray new];
    answerQuestionsList = [NSMutableArray new];
    auth = [AuthorizationManager sharedInstance];
    [self refreshInit];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAnswers:) name:@"reloadAnswers" object:nil];
    [self loadUsersAnswers];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        pageNumber = [NSNumber numberWithInt:[pageNumber integerValue] + 1];
        [self loadUsersAnswers];
        [tableView finishInfiniteScroll];
    }];
    
    // Do any additional setup after loading the view.
}

- (void) reloadAnswers:(NSNotification *) notification{
    Answer *updatedAnswer = [[Answer alloc] initWithParams:notification.object];
    NSUInteger objectId = 0;
    for(Answer *answer in usersAnswersList){
        if([answer.objectId isEqual:updatedAnswer.objectId]){
            objectId = [usersAnswersList indexOfObject:answer];
        }
    }
    [usersAnswersList removeObjectAtIndex:objectId];
    [usersAnswersList insertObject:updatedAnswer atIndex:objectId];
    [self.tableView reloadData];
}

- (void) loadUsersAnswers{
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/users/%@/answers", self.user.objectId] parameters:@{@"page": pageNumber} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            errorButton.hidden = YES;
            [self parseData:data];
        } else {
            serverError = [[ServerError alloc] initWithData:data];
            serverError.delegate = self;
            [serverError handle];
        }
    }];
}
- (void) refreshInit{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView addSubview:refreshView]; //the tableView is a IBOutlet
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    refreshControl.backgroundColor = [UIColor grayColor];
    [refreshView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(loadLatestAnswers) forControlEvents:UIControlEventValueChanged];
}

- (void) loadLatestAnswers{
    pageNumber = @1;
    usersAnswersList = [NSMutableArray new];
    [self loadUsersAnswers];
}


- (void) viewDidAppear:(BOOL)animated{
    [self.tableView reloadData];
}
- (void) parseData:(NSDictionary *) data{
    NSArray *answers = data[@"users"];
    if(answers != [NSNull null]){
        for(NSMutableDictionary *serverAnswer in answers){
            Question *question = [[Question alloc] initWithParams:serverAnswer[@"question"]];
            Answer *answer = [[Answer alloc] initWithParams:serverAnswer];
            [answer setDelegate:self];
            answer.question = question;
            [usersAnswersList addObject:answer];
        }
        [self.tableView reloadData];
    }
    [refreshControl endRefreshing];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return usersAnswersList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Answer *answerItem = usersAnswersList[indexPath.row];
    Question *questionItem = answerItem.question;
    static NSString *CellIdentifier = @"userAnswersCell";
    UserAnswersTableViewCell *cell = (UserAnswersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setCellDataWithQuestion:questionItem andAnswer:answerItem];
    [cell.answerQuestion addTarget:self action:@selector(answerQuestionClicked:) forControlEvents:UIControlEventTouchUpInside];
    if(currentCellHeight <= 30){
        cell.answerTextHeight.constant = 110;
    } else {
        cell.answerTextHeight.constant = currentCellHeight;
    }
    
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor yellowColor] icon:[UIImage imageNamed:@"up-32.png"]];
    [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor yellowColor] icon:[UIImage imageNamed:@"down-32.png"]];
    if(!questionItem.isClosed && !answerItem.isHelpfull){
        [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor] icon:[UIImage imageNamed:@"correct6.png"]];
    }
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                 icon:[UIImage imageNamed:@"edit-32.png"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
    cell.leftUtilityButtons = leftUtilityButtons;
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    
    return cell;
}

- (void) answerQuestionClicked: (UIButton *) sender{
    UserAnswersTableViewCell *cell = (UserAnswersTableViewCell *)[sender superview];
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    chosenQuestion = [usersAnswersList[path.row] question];
    [self performSegueWithIdentifier:@"userAnswersQuestion" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedIndex == indexPath.row){
        
        if(currentCellHeight <= 110){
            return 110;
            
        } else {
            return currentCellHeight;
        }
        
    } else {
        return 110;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if(selectedIndex == indexPath.row){
        selectedIndex = -1;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    if(selectedIndex != -1){
        NSIndexPath *prevPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    selectedIndex = indexPath.row;
    [self changeAnswerTextHeightAt:indexPath];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    currentAnswer = usersAnswersList[cellIndexPath.row];
    switch (index) {
        case 0:{
            [self performSegueWithIdentifier:@"answer_edit" sender:currentAnswer];
            [self.tableView reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        case 1:{
            [currentAnswer destroyWithIndexPath:cellIndexPath];
            break;
        }
        case 2:{
            break;
        }
        default:
            break;
    }
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    Answer *currentAnswer = usersAnswersList[cellIndexPath.row];
    switch (index) {
        case 0:{
            [currentAnswer changeRateWithAction:@"plus" andIndexPAth:cellIndexPath];
            break;
        }
        case 1:{
            [currentAnswer changeRateWithAction:@"minus" andIndexPAth:cellIndexPath];
            break;
        }
        case 2:{
            [currentAnswer markAsHelpfullWithPath:cellIndexPath];
            break;
        }
        default:
            break;
    }
}
- (void) setAnswerAsHelpfullWithAnswer:(Answer *)answer question: (Question *) question andIndexPath: (NSIndexPath *) path{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@/helpfull", question.objectId, answer.objectId ] parameters:nil requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            UserAnswersTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            cell.answerRate.backgroundColor = [UIColor greenColor];
//            [question closeQuestion];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            [self loadUsersAnswers];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }];
}
- (void) changeAnswersRateWithAnswer: (Answer *) answer question: (Question *) question indexPath: (NSIndexPath *) path andRate: (NSString *) rate{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@/rate", question.objectId, answer.objectId ] parameters:@{@"rate": rate} requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            UserAnswersTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            cell.answerRate.text = [NSString stringWithFormat:@"%@", data[@"rate"] ];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            [self loadUsersAnswers];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }];
}


- (void) changeAnswerTextHeightAt:(NSIndexPath *)path{
    CGSize size = [[usersAnswersList[path.row] text] sizeWithAttributes:nil];
    currentCellHeight = size.width / 10;
    [self.tableView cellForRowAtIndexPath:path];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Navigation Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"userAnswersQuestion"]){
        QuestionDetailViewController *view = segue.destinationViewController;
        view.question = chosenQuestion;
    }
    if([[segue identifier] isEqualToString:@"answer_edit"]){
        AnswerDetailViewController *view = segue.destinationViewController;
        view.answer = sender;
    }
}
- (void) changeRateCallbackWithParams:(NSDictionary *) params path:(NSIndexPath *) path andSuccess: (BOOL) success{
    if(success){
        UserAnswersTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        cell.answerRate.text = [NSString stringWithFormat:@"%@", params[@"rate"] ];
        NSInteger objectId;
        for(Answer *answer in usersAnswersList){
            if([answer.objectId isEqual:params[@"object_id"]]){
                objectId = [usersAnswersList indexOfObject:answer];
            }
        }
        Answer *changedAnswer = [usersAnswersList objectAtIndex:objectId];
        changedAnswer.rate = params[@"rate"];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
- (void) markAsHelpfullCallbackWithParams:(NSDictionary *)params path:(NSIndexPath *)path andSuccess:(BOOL)success{
    if(success){
        UserAnswersTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        cell.answerRate.backgroundColor = [UIColor greenColor];
        Answer *answer = usersAnswersList[path.row];
        answer.isHelpfull = YES;
        answer.question.isClosed = YES;
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
- (void) destroyCallback: (BOOL) success path: (NSIndexPath *) path {
    if(success){
        NSInteger indexPath = path.row;
        [usersAnswersList removeObjectAtIndex:path.row];
        [self.tableView reloadData];
    } else {
    
    }
}
- (void) handleServerErrorWithError:(id)error{
    if(errorButton){
        errorButton.hidden = NO;
    } else {
        errorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        errorButton.backgroundColor = [UIColor lightGrayColor];
        [errorButton setTitle:[error messageText] forState:UIControlStateNormal];
        [errorButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [errorButton addTarget:self action:@selector(loadLatestAnswers) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:errorButton];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [refreshControl endRefreshing];
}



@end
