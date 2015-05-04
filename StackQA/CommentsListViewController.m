//
//  CommentsListViewController.m
//  StackQA
//
//  Created by vsokoltsov on 04.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//
#import "Api.h"
#import "Comment.h"
#import "AuthorizationManager.h"
#import "CommentTableViewCell.h"
#import "CommentsListViewController.h"

@interface CommentsListViewController (){
    id currentEntity;
    NSMutableArray *commentsList;
    NSString *url;
    int selectedIndex;
    float currentCellHeight;
    NSManagedObjectContext *localContext;
}

@end

@implementation CommentsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    selectedIndex = -1;
    [self defineCorrectURL];
    [self loadCommentsData];
    // Do any additional setup after loading the view.
}

- (void) defineCorrectURL{
    if(self.answer){
        currentEntity = self.answer;
        url = [NSString stringWithFormat:@"/questions/%@/answers/%@/comments", self.question.object_id, self.answer.object_id];
    } else {
        currentEntity = self.question;
        url = [NSString stringWithFormat:@"/questions/%@/comments", self.question.object_id];
    }
}
- (void) loadCommentsData{
    [[Api sharedManager] sendDataToURL:url parameters:@{} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            [self parseCommentsData:data];
        } else {
        
        }
    }];
}

- (void) parseCommentsData: (id) data{
    [Comment sync:data[@"comments"]];
    commentsList = [NSMutableArray arrayWithArray:[Comment commentsForCurrentEntity:currentEntity andID:[currentEntity object_id]]];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"commentCell";
    Comment *cellComment = commentsList[indexPath.row];
    User *cellUser = [cellComment getUserForComment];
    CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    cell.userAvatar.image = [cellUser profileImage];
//    cell.userAvatar.layer.cornerRadius = cell.userAvatar.frame.size.width / 2;
//    cell.userAvatar.layer.masksToBounds = YES;
    cell.commentText.text = cellComment.text;
    [cell.userName setTitle:cellUser.correct_naming forState:UIControlStateNormal];
//    [cell.commentText loadHTMLString: cellComment.text baseURL:nil];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedTextView:)];
    [cell.commentText addGestureRecognizer:tapRecognizer];
    cell.commentText.selectable = YES;
//    singleTap.delegate = self;
//    [cell.commentText addGestureRecognizer:singleTap];
//    [cell.commentText];
//    [cell.commentText addTarget:self action:@selector(answerQuestionClicked:) forControlEvents:UIControlEventTouchUpInside];
//    cell.commentTextHeight.constant = 33;
    
    if(currentCellHeight <= 30){
        cell.commentTextHeight.constant = 33;
    } else {
        cell.commentTextHeight.constant = currentCellHeight;
    }
    return cell;
}

- (void)tappedTextView:(UITapGestureRecognizer *)tapGesture {
    CommentTableViewCell *cell = [[[tapGesture view] superview] superview];
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
