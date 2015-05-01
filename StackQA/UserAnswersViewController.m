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
#import "UserAnswersTableViewCell.h"

@interface UserAnswersViewController (){
    AuthorizationManager *auth;
    Question *chosenQuestion;
    float currentCellHeight;
    int selectedIndex;
    NSMutableArray *usersAnswersList;
    NSMutableArray *answerQuestionsList;
}

@end

@implementation UserAnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = -1;
    usersAnswersList = [NSMutableArray new];
    answerQuestionsList = [NSMutableArray new];
    auth = [AuthorizationManager sharedInstance];
    [self loadUsersAnswers];
    // Do any additional setup after loading the view.
}
- (void) loadUsersAnswers{
    [[Api sharedManager] getData:[NSString stringWithFormat:@"/users/%@/answers", self.user.object_id] andComplition:^(id data, BOOL success){
        if(success){
            [self parseData:data];
        } else {
            
        }
    }];
}
- (void) parseData:(NSDictionary *) data{
    NSArray *answers = data[@"users"];
    [Answer sync:answers];
    [Answer setAnswersToUser:self.user];
    for(Answer *answer in self.user.answers){
        Question *question = [answer getAnswerQuestion];
        [answerQuestionsList addObject:question];
        [usersAnswersList addObject:answer];
//        [defaultContext MR_Save];
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return usersAnswersList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Answer *answerItem = usersAnswersList[indexPath.row];
    Question *questionItem = [answerItem getAnswerQuestion];
    static NSString *CellIdentifier = @"userAnswersCell";
    UserAnswersTableViewCell *cell = (UserAnswersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setQUestionData:questionItem];
    if(questionItem != nil){
        [cell.answerQuestion setTitle: questionItem.title  forState:UIControlStateNormal];
    }
    cell.answerRate.text = [NSString stringWithFormat:@"%@", answerItem.rate];
    NSNumber *questionId = questionItem.object_id;
    
    if(answerItem.is_helpfull){
        cell.answerRate.backgroundColor = [UIColor greenColor];
    }
    
    if(currentCellHeight <= 30){
        cell.answerTextHeight.constant = 110;
    } else {
        cell.answerTextHeight.constant = currentCellHeight;
    }
    
    cell.answerQuestion.tag = [questionId integerValue];
    [cell.answerQuestion addTarget:self action:@selector(answerQuestionClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.answerText loadHTMLString: answerItem.text baseURL:nil];
    
    return cell;
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"userAnswersQuestion"]){
        QuestionDetailViewController *view = segue.destinationViewController;
        view.question = [chosenQuestion MR_inThreadContext];
    }
}

- (void) answerQuestionClicked: (UIButton *) sender{
    UserAnswersTableViewCell *cell = (UserAnswersTableViewCell *)[sender superview];
    __block Question *question;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context){
        NSNumber *questionID = [NSNumber numberWithInteger:sender.tag];
        question = [Question MR_findFirstByAttribute:@"object_id" withValue:questionID inContext:context];
    }];
    chosenQuestion = question;
    [self performSegueWithIdentifier:@"userAnswersQuestion" sender:self];
//    Question *question = [Question MR_findFirstByAttribute:@"object_id" withValue:questionId];
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

@end
