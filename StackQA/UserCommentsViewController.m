//
//  UserCommentsViewController.m
//  StackQA
//
//  Created by vsokoltsov on 07.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "UserCommentsViewController.h"
#import "UserCommentTableViewCell.h"
#import "QuestionDetailViewController.h"
#import "AnswersViewController.h"
#import "Comment.h"
#import "Api.h"
#import <CoreData+MagicalRecord.h>
#import "AuthorizationManager.h"

@interface UserCommentsViewController (){
    NSMutableArray *commentsList;
    float currentCellHeight;
    int selectedIndex;
    Question *selectedQuestion;
    NSManagedObjectContext *localContext;
    AuthorizationManager *auth;
}

@end

@implementation UserCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = -1;
    localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    auth = [AuthorizationManager sharedInstance];
    commentsList = [NSMutableArray new];
    [self loadUserCommentsData];
    // Do any additional setup after loading the view.
}

- (void) loadUserCommentsData{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat: @"/users/%@/comments", self.user.object_id] parameters:@{} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            [self parseData:data];
        } else {
            
        }
    }];
}
- (void) parseData: (id)data{
    [Comment sync:data[@"users"]];
    [Comment setCommentsToUser:self.user];
    for(Comment *comment in self.user.comments){
        [commentsList addObject:comment];
    }
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"commentCell";
    Comment *commentItem = commentsList[indexPath.row];
    UserCommentTableViewCell *cell = (UserCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
    UserCommentTableViewCell *cell = [[[[sender superview] superview] superview] superview];
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    Comment *comment = commentsList[path.row];
    Question *q;
    NSString *segueIdentifier;
    if([comment.commentable_type isEqualToString: @"Question" ]){
        q =[comment getEntity];
        segueIdentifier = @"showQuestion";
    }
    if([comment.commentable_type isEqualToString: @"Answer" ]){
        Answer *an = [comment getEntity];
        q = [an getAnswerQuestion];
        segueIdentifier = @"showQuestionAnswers";
    }
    selectedQuestion = q;
    [self performSegueWithIdentifier:segueIdentifier sender:self];
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
        view.question = [selectedQuestion MR_inThreadContext];
    }
    
    if([[segue identifier] isEqualToString:@"showQuestionAnswers"]){
        AnswersViewController *view = segue.destinationViewController;
        view.question = [selectedQuestion MR_inThreadContext];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
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
