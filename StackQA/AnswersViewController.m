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
#import <UIScrollView+InfiniteScroll.h>

@interface AnswersViewController (){
    int selectedIndex;
    Api *api;
    AuthorizationManager *auth;
    float currentCellHeight;
    NSNumber *pageNumber;
    NSManagedObjectContext *localContext;
    Answer *selectedAnswer;
    Question *questionAnswerSelected;
    NSMutableArray *answersList;
    UIRefreshControl *refreshControl;
}

@end

@implementation AnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = -1;
    pageNumber = @1;
    answersList = [NSMutableArray new];
    auth = [AuthorizationManager sharedInstance];
    self.sendButton.layer.cornerRadius = 5;
    self.settingsButton.layer.cornerRadius = 5;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAnswers:) name:@"updateAnswer" object:nil];
    [self setAnswersListData];
    self.tableView.delegate = self;
    Answer *answer = [[Answer alloc] init];
//    [];
    answer.answerDelegate = self;
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        pageNumber = [NSNumber numberWithInt:[pageNumber integerValue] + 1];
        [self loadAnswersList];
        [tableView finishInfiniteScroll];
    }];
}
- (void) reloadAnswers:(NSNotification *) notification{
    Answer *updatedAnswer = [[Answer alloc] initWithParams:notification.object];
    NSUInteger objectId;
    for(Answer *answer in answersList){
        if([answer.objectId isEqual:updatedAnswer.objectId]){
             objectId = [answersList indexOfObject:answer];
        }
    }
    [answersList removeObjectAtIndex:objectId];
    [answersList insertObject:updatedAnswer atIndex:objectId];
    [self.tableView reloadData];
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
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers", self.question.objectId ] parameters:@{@"page": pageNumber} requestType:@"GET" andComplition:^(id data, BOOL success){
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
    if(answersList.count ==nil){
        [self loadAnswersList];
    }
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
    NSArray *answers = data[@"answers"];
    NSMutableArray *answersTransfer = [NSMutableArray new];
    if(data[@"answers"] != [NSNull null]){
        for(NSMutableDictionary *serverAnswer in answers){
            Answer *answer = [[Answer alloc] initWithParams:serverAnswer];
            [answer setDelegate:self];
            [answersList addObject:answer];
        }
        [self.tableView reloadData];
    }
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
    [cell.answerComments setTitle:[NSString stringWithFormat:@"%@", answerItem.commentsCount] forState:UIControlStateNormal];
    [cell.answerComments addTarget:self action:@selector(answerCommentsClicked:) forControlEvents:UIControlEventTouchUpInside];
    cell.answerText.exclusiveTouch = YES;
    UITapGestureRecognizer* singleTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTouchesRequired=1;
    singleTap.delegate=self;
    
    cell.userName.text = [NSString stringWithFormat:@"%@", answerItem.userName];
    cell.answerRate.text = [NSString stringWithFormat:@"%@", answerItem.rate];
    if(answerItem.isHelpfull){
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
        if(!self.question.isClosed){
            [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor greenColor] icon:[UIImage imageNamed:@"correct6.png"]];
        }
        if([answerItem.userId isEqual: auth.currentUser.objectId]){
            
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
//        Answer *answer = [Answer MR_findFirstByAttribute:@"object_id" withValue:answerID];
//        selectedAnswer = answer;
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
    [api sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@", self.question.objectId, answer.objectId ] parameters:nil requestType:@"DELETE" andComplition:^(id data, BOOL success){
        if(success){
            AnswerTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
            [answersList removeObjectAtIndex:path.row];
//            [answer MR_deleteEntity];
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
            [currentAnswer changeRateWithAction:@"plus"andIndexPAth:cellIndexPath];
            break;
        }
        case 1:
        {
            [currentAnswer changeRateWithAction:@"minus" andIndexPAth:cellIndexPath];
            break;
        }
        case 2:
        {
            [currentAnswer markAsHelpfullWithPath:cellIndexPath];
            break;
        }
        default:
            break;
    }
}
- (void) setAnswerAsHelpfullWithAnswer:(Answer *)answer andIndexPath: (NSIndexPath *) path{
//    [api sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@/helpfull", self.question.objectId, answer.object_id ] parameters:nil requestType:@"POST" andComplition:^(id data, BOOL success){
//        if(success){
//            AnswerTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
//            cell.answerRate.backgroundColor = [UIColor greenColor];
////            [self.question closeQuestion];
//            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
//            [self loadAnswersList];
//        } else {
//            [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
//        }
//    }];
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
- (void) createCallbackWithParams:(NSDictionary *) params andSuccess: (BOOL) success{
    self.actionViewText.text = @"";
    if(success){
        Answer *answer = [[Answer alloc] initWithParams:params];
        [answersList insertObject:answer atIndex:0];
        [self.tableView reloadData];
    } else {
        
    }
}
- (void) changeRateCallbackWithParams:(NSDictionary *) params path:(NSIndexPath *) path andSuccess: (BOOL) success{
    if(success){
        AnswerTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        cell.answerRate.text = [NSString stringWithFormat:@"%@", params[@"rate"] ];
        NSInteger objectId;
        for(Answer *answer in answersList){
            if([answer.objectId isEqual:params[@"object_id"]]){
                objectId = [answersList indexOfObject:answer];
            }
        }
        Answer *changedAnswer = [answersList objectAtIndex:objectId];
        changedAnswer.rate = params[@"rate"];
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
}
- (IBAction)createAnswer:(id)sender {
    [self setActionViewBorder];
    NSMutableDictionary *answerParams = @{@"user_id": auth.currentUser.objectId,
                                          @"question_id": self.question.objectId,
                                          @"text": self.actionViewText.text};
    if([self.actionViewText.text isEqualToString:@""]){
        [self.actionViewText.layer setBorderColor:[[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor]];
    } else {
        Answer *answer = [[Answer alloc] init];
        [answer setDelegate:self];
        [answer create:answerParams];
    }
}

- (void) markAsHelpfullCallbackWithParams:(NSDictionary *)params path:(NSIndexPath *)path andSuccess:(BOOL)success{
    if(success){
        AnswerTableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
        cell.answerRate.backgroundColor = [UIColor greenColor];
        Answer *answer = answersList[path.row];
        answer.isHelpfull = YES;
        self.question.isClosed = YES;
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationLeft];
    }
}


//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView
//                     withVelocity:(CGPoint)velocity
//              targetContentOffset:(inout CGPoint *)targetContentOffset {
//    pageNumber = [NSNumber numberWithInt:[pageNumber integerValue] + 1];
//    [self loadAnswersList];
//}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)showSettings:(id)sender {
}
@end
