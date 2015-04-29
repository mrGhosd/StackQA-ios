//
//  UserAnswersViewController.m
//  StackQA
//
//  Created by vsokoltsov on 24.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "UserAnswersViewController.h"
#import "Api.h"
#import "Answer.h"
#import "Question.h"
#import "AuthorizationManager.h"
#import "UserAnswersTableViewCell.h"

@interface UserAnswersViewController (){
    AuthorizationManager *auth;
    NSMutableArray *usersAnswersList;
}

@end

@implementation UserAnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    usersAnswersList = [NSMutableArray new];
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
        [usersAnswersList addObject:answer];
    }
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return usersAnswersList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Answer *answerItem = usersAnswersList[indexPath.row];
    Question *question = [answerItem getAnswerQuestion];
    static NSString *CellIdentifier = @"userAnswersCell";
    UserAnswersTableViewCell *cell = (UserAnswersTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(question != nil){
        
        [cell.answerQuestion setTitle: question.title  forState:UIControlStateNormal];
    }
    cell.answerRate.text = [NSString stringWithFormat:@"%@", answerItem.rate];
    [cell.answerText loadHTMLString: answerItem.text baseURL:nil];
    
//    cell.answerAuthor
//    QuestionsTableViewCell *cell = (QuestionsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    [cell setQuestionData:questionItem];
//    cell.questionTitle.text = (Question *)questionItem.title;
//    cell.questionDate.text = [NSString stringWithFormat:@"%@", (Question *)questionItem.created_at];
//    cell.questionRate.text = [NSString stringWithFormat:@"%@", questionItem.rate];
//    [self setQuestionRateViewForCell:cell andItem:questionItem];
//    [cell.viewsCount setTitle:[NSString stringWithFormat:@"%@", questionItem.views] forState:UIControlStateNormal];
//    [cell.answersCount setTitle:[NSString stringWithFormat:@"%@", questionItem.answers_count] forState:UIControlStateNormal];
//    [cell.commentsCount setTitle:[NSString stringWithFormat:@"%@", questionItem.comments_count] forState:UIControlStateNormal];
//    
//    if(auth.currentUser && questionItem.user_id == auth.currentUser.object_id){
//        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//        [rightUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
//                                                     icon:[UIImage imageNamed:@"edit-32.png"]];
//        [rightUtilityButtons sw_addUtilityButtonWithColor:
//         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
//        cell.rightUtilityButtons = rightUtilityButtons;
//        cell.delegate = self;
//    }
    return cell;
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
