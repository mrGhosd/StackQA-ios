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
#import "CommentDetailViewController.h"
#import <SWTableViewCell.h>
#import <UIScrollView+InfiniteScroll.h>
#import "ServerError.h"
#import <MBProgressHUD.h>
#import <UIImage-ResizeMagick/UIImage+ResizeMagick.h>

@interface CommentsListViewController (){
    id currentEntity;
    NSMutableArray *commentsList;
    NSString *url;
    int selectedIndex;
    NSNumber *pageNumber;
    float currentCellHeight;
    AuthorizationManager *auth;
    Comment *selectedComment;
    NSManagedObjectContext *localContext;
    UIButton *errorButton;
    UIRefreshControl *refreshControl;
    ServerError *serverError;
}

@end

@implementation CommentsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageNumber = @1;
    commentsList = [NSMutableArray new];
    auth = [AuthorizationManager sharedInstance];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadComments:) name:@"updateComment" object:nil];
    [self refreshInit];
    [self setCommentControl];
    selectedIndex = -1;
    [self defineCorrectURL];
    [self loadCommentsData];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        pageNumber = [NSNumber numberWithInt:[pageNumber integerValue] + 1];
        [self loadCommentsData];
        [tableView finishInfiniteScroll];
    }];
    // Do any additional setup after loading the view.
}

- (void) refreshInit{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView addSubview:refreshView]; //the tableView is a IBOutlet
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    refreshControl.backgroundColor = [UIColor grayColor];
    [refreshView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(uploadCommentData) forControlEvents:UIControlEventValueChanged];
}

- (void) uploadCommentData{
    pageNumber = @1;
    commentsList = [NSMutableArray new];
    [self loadCommentsData];
}

-(void)reloadComments: (NSNotification *) notification{
    Comment *updatedComment = [[Comment alloc] initWithParams:notification.object];
    User *user = [[User alloc] initWithParams:notification.object[@"user"]];
    Question *question = [[Question alloc] initWithParams:notification.object[@"question"]];
    updatedComment.user = user;
    updatedComment.question = question;
    if(notification.object[@"answer"] != [NSNull null]){
        Answer *answer = [[Answer alloc] initWithParams:notification.object[@"answer"]];
        updatedComment.answer = answer;
    }
    updatedComment.commentDelegate = self;
    NSUInteger objectId = 0;
    for(Comment *comment in commentsList){
        if([comment.objectId isEqual:updatedComment.objectId]){
            objectId = [commentsList indexOfObject:comment];
        }
    }
    
    [commentsList removeObjectAtIndex:objectId];
    [commentsList insertObject:updatedComment atIndex:objectId];
    [self.tableView reloadData];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) setCommentControl{
    if(auth.currentUser){
        [self.controlView setHidden:NO];
        self.commentText.autocorrectionType = UITextAutocorrectionTypeNo;
        [self setTextViewBorder];
        self.commentSendButton.layer.cornerRadius = 5;
        self.commentTableBottomMargin.constant = self.controlView.frame.size.height;
    } else {
        self.commentTableBottomMargin.constant = 0.0;
        [self.controlView setHidden:YES];
    }
}
//
- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *keyboardValues = [notification userInfo];
    id keyboardSize = keyboardValues[@"UIKeyboardFrameEndUserInfoKey"];
    CGRect keyboardFrame = [keyboardSize CGRectValue];
    int orientation = (int)[[UIDevice currentDevice] orientation];
    float textViewConstraint = keyboardFrame.size.height;
    self.commentTableBottomMargin.constant = textViewConstraint + self.controlView.frame.size.height;
    self.controlViewBottomMargin.constant = textViewConstraint;
}
- (void) keyboardWillHide:(NSNotification *) notification{
    self.controlViewBottomMargin.constant = 0.0;
    self.commentTableBottomMargin.constant = self.controlView.frame.size.height;
}
- (void) setTextViewBorder{
    [self.commentText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.commentText.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.commentText.layer.cornerRadius = 5;
    self.commentText.clipsToBounds = YES;
}
//
//
- (void) defineCorrectURL{
    if(self.answer){
        currentEntity = self.answer;
        url = [NSString stringWithFormat:@"/questions/%@/answers/%@/comments", self.question.objectId, self.answer.objectId];
    } else {
        currentEntity = self.question;
        url = [NSString stringWithFormat:@"/questions/%@/comments", self.question.objectId];
    }
}
- (void) loadCommentsData{
    [[Api sharedManager] sendDataToURL:url parameters:@{@"page": pageNumber} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            errorButton.hidden = YES;
            [self parseCommentsData:data];
        } else {
            serverError = [[ServerError alloc] initWithData:data];
            serverError.delegate = self;
            [serverError handle];
        }
    }];
}
//
- (void) parseCommentsData: (id) data{
    NSMutableArray *comments = data[@"comments"];
    if(comments != nil){
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
        [refreshControl endRefreshing];
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"commentCell";
    Comment *cellComment = commentsList[indexPath.row];
    User *cellUser = cellComment.user;
    CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.commentText.text = cellComment.text;
    UIImage* resizedImage = [[cellUser profileImage] resizedImageByMagick: @"32x32#"];
    [cell.userName setTitle:[cellUser getCorrectNaming] forState:UIControlStateNormal];
    [cell.userName setImage:resizedImage forState:UIControlStateNormal];
    cell.commentText.editable = NO;
    cell.commentText.scrollEnabled = NO;
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];
    if(auth.currentUser){
        [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor yellowColor] icon:[UIImage imageNamed:@"child1.png"]];
        cell.leftUtilityButtons = leftUtilityButtons;
    }
    if(auth.currentUser && [auth.currentUser.objectId isEqual: cellComment.userId]){
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                     icon:[UIImage imageNamed:@"edit-32.png"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
        cell.rightUtilityButtons = rightUtilityButtons;
    }
    cell.delegate = self;
    
    if(currentCellHeight <= 30){
        cell.commentTextHeight.constant = 33;
    } else {
        cell.commentTextHeight.constant = currentCellHeight;
    }
    return cell;
}
//
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    selectedComment = commentsList[cellIndexPath.row];
    switch (index) {
        case 0:{
            [self performSegueWithIdentifier:@"comment_edit" sender:self];
            break;
        }
        case 1:{
            [selectedComment destroyWithPath:cellIndexPath];
            break;
        }
        default:
            break;
    }
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index {
    NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
    selectedComment = commentsList[cellIndexPath.row];
    switch (index) {
        case 0:{
            [selectedComment complainToCommentWithPath:cellIndexPath];
            break;
        }
        default:
            break;
    }
}

- (void) destroyCallback:(BOOL)success path:(NSIndexPath *)path{
    if(success){
        [commentsList removeObjectAtIndex:path.row];
        [self.tableView reloadData];
    } else {
        serverError = [[ServerError alloc] init];
        serverError.delegate = self;
        [serverError callErrorHAndlerWithoutData];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(commentsList.count != nil){
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.layer.frame.size.width, 500)];
        messageLabel.text = NSLocalizedString(@"empty_comments_list", nil);
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
//
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
        [self changeCommentTextHeightAt:indexPath];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    selectedIndex = indexPath.row;
    [self changeCommentTextHeightAt:indexPath];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
//
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedIndex == indexPath.row){
        return currentCellHeight + 82;
    } else {
        return 82;
    }
    
}
//
- (void) changeCommentTextHeightAt:(NSIndexPath *)path{
    Comment *comment = commentsList[path.row];
    CGSize size = [comment.text sizeWithAttributes:nil];
    currentCellHeight = size.width / 20;
    [self.tableView cellForRowAtIndexPath:path];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"comment_edit"]){
        CommentDetailViewController *view = segue.destinationViewController;
        view.comment = selectedComment;
        view.question = self.question;
        if(self.answer){
            view.answer = self.answer;
        }
    }
}
- (IBAction)createComment:(id)sender {
    if([self.commentText.text isEqualToString:@""]){
        [self.commentText.layer setBorderColor:[[[UIColor redColor] colorWithAlphaComponent:0.5] CGColor]];
    } else {
        [self setTextViewBorder];
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"user_id": auth.currentUser. objectId, @"question_id": self.question.objectId, @"text": self.commentText.text}];
        if(self.answer){
            [params addEntriesFromDictionary:@{@"answer_id": self.answer.objectId}];
        }
        Comment *comment = [[Comment alloc] init];
        comment.commentDelegate = self;
        [comment create:params];
    }
}
- (void) createCallbackWithParams:(NSDictionary *)params andSuccess:(BOOL)success{
    if(success){
        errorButton.hidden = YES;
        self.commentText.text = @"";
        Comment *comment = [[Comment alloc] initWithParams:params];
        Question *question = [[Question alloc] initWithParams:params[@"question"]] ;
        User *user = [[User alloc] initWithParams:params[@"user"]];
        if(params[@"answer"] != [NSNull null]){
            Answer *answer = [[Answer alloc] initWithParams:params[@"answer"]];
            comment.answer = answer;
        }
        comment.question = question;
        comment.user = user;
        [commentsList insertObject:comment atIndex:0];
        [self.tableView reloadData];
    } else {
        serverError = [[ServerError alloc] initWithData:params];
        serverError.delegate = self;
        [serverError handle];
    }
}
- (void) complaintToCommentWithSuccess: (BOOL) success andIndexPath: (NSIndexPath *) path{
    if(success){
        errorButton.hidden = YES;
        [self.tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        serverError = [[ServerError alloc] init];
        serverError.delegate = self;
        [serverError callErrorHAndlerWithoutData];
    }
}

- (void) handleServerErrorWithError:(id)error{
    if(errorButton){
        errorButton.hidden = NO;
    } else {
        errorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        errorButton.backgroundColor = [UIColor lightGrayColor];
        NSString *errorText;
        if([error messageText]){
            errorText = [error messageText];
        } else {
            errorText = NSLocalizedString(@"server-connection-disabled", nil);
        }
        [errorButton setTitle:errorText forState:UIControlStateNormal];
        [errorButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [errorButton addTarget:self action:@selector(uploadCommentData) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:errorButton];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

@end
