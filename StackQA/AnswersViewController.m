//
//  AnswersViewController.m
//  StackQA
//
//  Created by vsokoltsov on 23.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "AnswersViewController.h"
#import "AnswerDetailViewController.h"
#import "CommentsListViewController.h"
#import "Api.h"
#import "AnswerTableViewCell.h"
#import "AuthorizationManager.h"
#import <MBProgressHUD.h>

@interface AnswersViewController (){
    int selectedIndex;
    Api *api;
    AuthorizationManager *auth;
    float currentCellHeight;
    NSManagedObjectContext *localContext;
    Answer *selectedAnswer;
    Question *questionAnswerSelected;
    NSMutableArray *answersList;
}

@end

@implementation AnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = -1;
    auth = [AuthorizationManager sharedInstance];
    self.sendButton.layer.cornerRadius = 5;
    self.settingsButton.layer.cornerRadius = 5;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAnswers) name:@"updateAnswer" object:nil];
    [self setAnswersListData];
    self.tableView.delegate = self;
    
    // Do any additional setup after loading the view.
}
- (void) reloadAnswers{
    [self loadAnswersList];
}
- (void) setAnswersListData{
    if(auth.currentUser){
        self.actionView.hidden = NO;
        [self setActionViewBorder];
        [self setActionViewTextBorder];
    } else {
        self.tableViewBottom.constant = 0.0;
        self.actionView.hidden = YES;
    }
}
- (void) loadAnswersList{
    api = [Api sharedManager];
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [api getData:[NSString stringWithFormat:@"/questions/%@/answers", self.question.object_id ]
     andComplition:^(id data, BOOL success){
         if(success){
             [self parseAnswerData:data];
         } else {
             
         }
     }];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
- (void) viewWillAppear:(BOOL)animated{
    [self loadAnswersList];
}
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *keyboardValues = [notification userInfo];
    id keyboardSize = keyboardValues[@"UIKeyboardFrameEndUserInfoKey"];
    CGRect keyboardFrame = [keyboardSize CGRectValue];
    int orientation = (int)[[UIDevice currentDevice] orientation];
    float textViewConstraint;
    switch (orientation) {
        case 1:
            textViewConstraint = keyboardFrame.size.height;
            break;
            
        case 3:
            textViewConstraint = keyboardFrame.size.width;
            break;
            
        case 4:
            textViewConstraint = keyboardFrame.size.width;
            break;
        
        default:
            textViewConstraint = keyboardFrame.size.height;
            break;
    }
    self.tableViewBottom.constant = textViewConstraint + self.actionView.frame.size.height;
    self.textViewBottom.constant = textViewConstraint;
}
- (void) keyboardWillHide:(NSNotification *) notification{
    self.textViewBottom.constant = 0.0;
    self.tableViewBottom.constant = self.actionView.frame.size.height;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void) parseAnswerData:(id) data{
    [Answer sync:data[@"answers"]];
    answersList = [NSMutableArray arrayWithArray:[Answer answersForQuestion:self.question]];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if(selectedIndex == indexPath.row){
        selectedIndex = -1;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    CGSize size = [[answersList[path.row] text] sizeWithAttributes:nil];
    currentCellHeight = size.width / 10;
    [self.tableView cellForRowAtIndexPath:path];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Answer *answerItem = [answersList objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"answerCell";
    AnswerTableViewCell *cell = (AnswerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.answerText loadHTMLString: answerItem.text baseURL:nil];
    cell.answerComments.tag = [answerItem.object_id integerValue];
    [cell.answerComments setTitle:[NSString stringWithFormat:@"%@", answerItem.comments_count] forState:UIControlStateNormal];
    [cell.answerComments addTarget:self action:@selector(answerCommentsClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.answerText.exclusiveTouch = YES;
    UITapGestureRecognizer* singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTouchesRequired=1;
    singleTap.delegate=self;
//    [cell.answerText addGestureRecognizer:singleTap];
    
    cell.userName.text = [NSString stringWithFormat:@"%@", answerItem.user_name];
    cell.answerRate.text = [NSString stringWithFormat:@"%@", answerItem.rate];
    if(answerItem.is_helpfull){
        cell.answerRate.backgroundColor = [UIColor greenColor];
    } else {
        cell.answerRate.backgroundColor = [UIColor lightGrayColor];
    }
    
    if(currentCellHeight <= 30){
        cell.answerTextHeight.constant = 110;
    } else {
        cell.answerTextHeight.constant = currentCellHeight;
    }
    
    if(auth.currentUser){
        NSMutableArray *leftUtilityButtons = [NSMutableArray new];
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor yellowColor] icon:[UIImage imageNamed:@"up-32.png"]];
        [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor yellowColor] icon:[UIImage imageNamed:@"down-32.png"]];
        if(!self.question.is_closed){
            [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor] icon:[UIImage imageNamed:@"correct6.png"]];
        }
        if(answerItem.user_id == auth.currentUser.object_id){
            
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                     icon:[UIImage imageNamed:@"edit-32.png"]];
            [rightUtilityButtons sw_addUtilityButtonWithColor:
             [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
        }
        cell.leftUtilityButtons = leftUtilityButtons;
        cell.rightUtilityButtons = rightUtilityButtons;
        cell.delegate = self;
    }
    return cell;
}

- (void) handleSingleTap:(UITapGestureRecognizer *)gesture{
    AnswerTableViewCell * cell = [[[[gesture view] superview] superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognize{
    return YES;
}
- (void) answerCommentsClicked: (UIButton *) sender{
        NSNumber *answerID = [NSNumber numberWithInteger:sender.tag];
        Answer *answer = [Answer MR_findFirstByAttribute:@"object_id" withValue:answerID];
        selectedAnswer = answer;
        questionAnswerSelected = self.question;
        [self performSegueWithIdentifier:@"commentsAnswerView" sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    if(answersList.count != nil){
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.layer.frame.size.width, 500)];
        messageLabel.text = @"Ответов для данного вопроса нет";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    selectedAnswer = answersList[cellIndexPath.row];
    switch (index) {
        case 0:{
            [self performSegueWithIdentifier:@"answer_edit" sender:self];
            [self.tableView reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        case 1:{
            
            [self deleteAnswer:selectedAnswer atIndexPath:cellIndexPath];
            break;
        }
        case 2:{
            break;
        }
        default:
            break;
    }
}

- (void) deleteAnswer:(Answer *) answer atIndexPath: (NSIndexPath *) path{
    [api sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@", self.question.object_id, answer.object_id ] parameters:nil requestType:@"DELETE" andComplition:^(id data, BOOL success){
        if(success){
            AnswerTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            [answersList removeObjectAtIndex:path.row];
            [answer MR_deleteEntity];
            if(answersList.count == 0){
             [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:path.section] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            }
            [self loadAnswersList];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }];
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    Answer *currentAnswer = answersList[cellIndexPath.row];
    switch (index) {
        case 0:
        {
            [self changeAnswersRateWithAnswer:currentAnswer indexPath: cellIndexPath  andRate:@"plus"];
            break;
        }
        case 1:
        {
            [self changeAnswersRateWithAnswer:currentAnswer indexPath: cellIndexPath  andRate:@"minus"];
            break;
        }
        case 2:
        {
            [self setAnswerAsHelpfullWithAnswer:currentAnswer andIndexPath:cellIndexPath];
            break;
        }
        default:
            break;
    }
}
- (void) setAnswerAsHelpfullWithAnswer:(Answer *)answer andIndexPath: (NSIndexPath *) path{
    [api sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@/helpfull", self.question.object_id, answer.object_id ] parameters:nil requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            AnswerTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            cell.answerRate.backgroundColor = [UIColor greenColor];
            [self.question closeQuestion];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            [self loadAnswersList];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }];
}
- (void) changeAnswersRateWithAnswer: (Answer *) answer indexPath: (NSIndexPath *) path andRate: (NSString *) rate{
    [api sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@/rate", self.question.object_id, answer.object_id ] parameters:@{@"rate": rate} requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            AnswerTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            cell.answerRate.text = [NSString stringWithFormat:@"%@", data[@"rate"] ];
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
            [self loadAnswersList];
        } else {
            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return answersList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedIndex == indexPath.row){
        return currentCellHeight + 110;
    } else {
        return 110;
    }
    
}
- (void) setActionViewBorder{
    CGSize mainViewSize = self.actionView.frame.size;
    CGFloat borderWidth = 1;
    UIColor *borderColor = [UIColor lightGrayColor];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainViewSize.width, borderWidth)];
    topView.opaque = YES;
    topView.backgroundColor = borderColor;
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.actionView addSubview:topView];
}


- (void) setActionViewTextBorder{
    [self.actionViewText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.actionViewText.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.actionViewText.layer.cornerRadius = 5;
    self.actionViewText.clipsToBounds = YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"answer_edit"]){
        AnswerDetailViewController *view = segue.destinationViewController;
        view.answer = selectedAnswer;
    }
    if([[segue identifier] isEqualToString:@"commentsAnswerView"]){
        CommentsListViewController *view = segue.destinationViewController;
        view.answer = selectedAnswer;
        view.question = questionAnswerSelected;
    }
}

- (IBAction)createAnswer:(id)sender {
    [self setActionViewBorder];
    NSMutableDictionary *answerParams = @{@"user_id": auth.currentUser.object_id,
                                          @"question_id": self.question.object_id,
                                          @"text": self.actionViewText.text};
    if([self.actionViewText.text isEqualToString:@""]){
        [self.actionViewText.layer setBorderColor:[[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor]];
    } else {
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers", self.question.object_id] parameters:@{@"answer": answerParams} requestType:@"POST"
                         andComplition:^(id data, BOOL success){
                             if(success){
                                 self.actionViewText.text = @"";
                                 [self loadAnswersList];
                             } else{
                                 
                             }
                         }];
    }
    
}
- (IBAction)showSettings:(id)sender {
}
@end
