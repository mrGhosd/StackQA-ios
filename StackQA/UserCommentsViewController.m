//
//  UserCommentsViewController.m
//  StackQA
//
//  Created by vsokoltsov on 07.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "UserCommentsViewController.h"
#import "UserCommentTableViewCell.h"
#import "CommentDetailViewController.h"
#import "QuestionDetailViewController.h"
#import "AnswersViewController.h"
#import "Comment.h"
#import "Api.h"
#import "AuthorizationManager.h"
#import <MBProgressHUD.h>
#import <UIScrollView+InfiniteScroll.h>
#import <UIImage-ResizeMagick/UIImage+ResizeMagick.h>

@interface UserCommentsViewController (){
    NSMutableArray *commentsList;
    float currentCellHeight;
    int selectedIndex;
    Question *selectedQuestion;
    NSNumber *pageNumber;
    Comment *selectedComment;
    NSManagedObjectContext *localContext;
    AuthorizationManager *auth;
}

@end

@implementation UserCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageNumber = @1;
    selectedIndex = -1;
    localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    auth = [AuthorizationManager sharedInstance];
    commentsList = [NSMutableArray new];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        pageNumber = [NSNumber numberWithInt:[pageNumber integerValue] + 1];
        [self loadUserCommentsData];
        [tableView finishInfiniteScroll];
    }];
    // Do any additional setup after loading the view.
}
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self loadUserCommentsData];
}
- (void) loadUserCommentsData{
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat: @"/users/%@/comments", self.user.objectId] parameters:@{@"page": pageNumber} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            [self parseData:data];
        } else {
            
        }
    }];
}
- (void) parseData: (id)data{
    NSMutableArray *comments = data[@"users"];
    if(data[@"users"] != [NSNull null]){
        for(NSDictionary *commentServer in comments){
            Comment *comment = [[Comment alloc] initWithParams:commentServer];
            User *user = [[User alloc] initWithParams:commentServer[@"user"]];
            Question *question = [[Question alloc] initWithParams:commentServer[@"question"]];
            comment.user = user;
            comment.question = question;
            if(commentServer[@"answer"] != [NSNull null]){
                Answer *answer = [[Answer alloc] initWithParams:commentServer[@"answer"]];
                comment.answer = answer;
            }
            comment.commentDelegate = self;
            [commentsList addObject:comment];
        }
        [self.tableView reloadData];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"commentCell";
    Comment *commentItem = commentsList[indexPath.row];
    UserCommentTableViewCell *cell = (UserCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    UIImage* resizedImage = [[commentItem.user profileImage] resizedImageByMagick: @"32x32#"];
//    [cell. setTitle:[commentItem.user getCorrectNaming] forState:UIControlStateNormal];
//    [cell.userName setImage:resizedImage forState:UIControlStateNormal];
    [cell setParametersForComment:commentItem];
    [cell.commentEntityLink addTarget:self action:@selector(commentEntityClicked:) forControlEvents:UIControlEventTouchUpInside];
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                 icon:[UIImage imageNamed:@"edit-32.png"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
    cell.rightUtilityButtons = rightUtilityButtons;
    cell.delegate = self;
    return cell;
}

- (void) commentEntityClicked:(UIButton *) sender{
//    UserCommentTableViewCell *cell = [[[[sender superview] superview] superview] superview];
//    NSIndexPath *path = [self.tableView indexPathForCell:cell];
//    Comment *comment = commentsList[path.row];
//    Question *q;
//    NSString *segueIdentifier;
//    if([comment.commentable_type isEqualToString: @"Question" ]){
//        q =[comment getEntity];
//        segueIdentifier = @"showQuestion";
//    }
//    if([comment.commentable_type isEqualToString: @"Answer" ]){
//        Answer *an = [comment getEntity];
////        q = [an getAnswerQuestion];
//        segueIdentifier = @"showQuestionAnswers";
//    }
//    selectedQuestion = q;
//    [self performSegueWithIdentifier:segueIdentifier sender:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(commentsList.count != nil){
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.layer.frame.size.width, 500)];
        messageLabel.text = @"Комментариев нет";
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return commentsList.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if(selectedIndex == indexPath.row){
        selectedIndex = -1;
        [self changeCommentTextHeightAt:indexPath];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    if(selectedIndex != -1){
        NSIndexPath *prevPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        [self changeCommentTextHeightAt:indexPath];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    selectedIndex = indexPath.row;
    [self changeCommentTextHeightAt:indexPath];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedIndex == indexPath.row){
        
        if(currentCellHeight <= 30){
            return 82;
            
        } else {
            return currentCellHeight;
        }
        
    } else {
        return 82;
    }
    
}

- (void) changeCommentTextHeightAt:(NSIndexPath *)path{
    Comment *comment = commentsList[path.row];
    CGSize size = [comment.text sizeWithAttributes:nil];
    currentCellHeight = size.width / 20;
    [self.tableView cellForRowAtIndexPath:path];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"showQuestion"]){
        QuestionDetailViewController *view = segue.destinationViewController;
//        view.question = [selectedQuestion MR_inThreadContext];
    }
    
    if([[segue identifier] isEqualToString:@"showQuestionAnswers"]){
        AnswersViewController *view = segue.destinationViewController;
//        view.question = [selectedQuestion MR_inThreadContext];
    }
    
    if([[segue identifier] isEqualToString:@"editComment"]){
//        CommentDetailViewController *view = segue.destinationViewController;
//        view.comment = [selectedComment MR_inThreadContext];
//        Question *q;
//        Answer *a;
//        if([selectedComment.commentable_type isEqualToString:@"Question"]){
//            q = [selectedComment getEntity];
//        }
//        if([selectedComment.commentable_type isEqualToString:@"Answer"]){
//            a = [selectedComment getEntity];
////            q = [a getAnswerQuestion];
//        }
//        view.question = [q MR_inThreadContext];
//        if(a){
//            view.answer = [a MR_inThreadContext];
//        }
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    selectedComment = commentsList[cellIndexPath.row];
    switch (index) {
        case 0:{
            [self performSegueWithIdentifier:@"editComment" sender:self];
            [self.tableView reloadRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
            break;
        }
        case 1:{
            [self deleteComment:selectedComment AtPath:cellIndexPath];
            //            [self deleteAnswer:selectedAnswer atIndexPath:cellIndexPath];
            break;
        }
        case 2:{
            break;
        }
        default:
            break;
    }
}
- (void) deleteComment:(Comment *) comment AtPath: (NSIndexPath *) path{
    NSMutableDictionary *params;
    NSString *url;
//    if([comment.commentable_type isEqualToString:@"Question"]){
//        Question *q = [comment getEntity];
//        params = [NSMutableDictionary dictionaryWithDictionary:@{@"user_id": auth.currentUser.objectId, @"question_id": q.objectId, @"text": comment.text}];
//        url = [NSString stringWithFormat:@"/questions/%@/comments/%@", q.objectId, comment.object_id];
//    }
//    if ([comment.commentable_type isEqualToString:@"Answer"]){
//        Answer *an = [comment getEntity];
////        Question *q = [an getAnswerQuestion];
////        params = [NSMutableDictionary dictionaryWithDictionary:@{@"user_id": auth.currentUser.objectId, @"question_id": q.objectId, @"answer_id": an.object_id, @"text": comment.text}];
////        url = [NSString stringWithFormat:@"/questions/%@/answers/%@/comments/%@", q.objectId, an.object_id, comment.object_id];
//    }
    [[Api sharedManager] sendDataToURL:url parameters:params requestType:@"DELETE" andComplition:^(id data, BOOL success){
        if(success){
//            [comment MR_deleteEntity];
//            [commentsList removeObjectAtIndex:path.row];
//            if(commentsList.count == 0){
//                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:path.section] withRowAnimation:UITableViewRowAnimationFade];
//            } else {
//                [self.tableView deleteRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
//            }
//            
//        } else {
//            
        }
    }];
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
