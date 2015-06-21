//
//  QuestionsViewController.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionsViewController.h"
#import "QuestionCategoryView.h"
#import "AppDelegate.h"
#import "QuestionDetailViewController.h"
#import "QuestionsFormViewController.h"
#import "CommentsListViewController.h"
#import "CategoryDetailViewController.h"
#import <CoreData+MagicalRecord.h>
#import "QuestionsTableViewCell.h"
#import "Question.h"
#import "SWRevealViewController.h"
#import "Api.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AuthorizationManager.h"
#import <UIScrollView+InfiniteScroll.h>
#import "QuestionFilter.h"
#import "ServerError.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface QuestionsViewController (){
    Question *currentQuestion;
    AuthorizationManager *auth;
    NSNumber *pageNumber;
    NSString *mainURL;
    Api *api;
    UIApplication *app;
    ServerError *serverError;
    NSMutableArray *questionsArray;
    NSArray *searchResults;
    QuestionFilter *filterView;
    NSString *defaultQuestionURL;
    NSString *filter;
    UIRefreshControl *refreshControl;
    UIButton *errorButton;
}

@end

@implementation QuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageNumber = @1;
    self.questions = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserValue) name:@"getCurrentUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(answersListForQuestion:) name:@"answersListForQuestion" object:currentQuestion];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commentsListForQuestion:) name:@"commentsListForQuestion" object:currentQuestion];
    auth = [AuthorizationManager sharedInstance];
    defaultQuestionURL = @"/questions";
    filter = @"";
    [self refreshInit];
    [self defineNavigationPanel];
    [self pageType];
    [self.tableView reloadData];
    [self toggleCrateQuestionButton];
    
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        pageNumber = [NSNumber numberWithInteger:[pageNumber integerValue] + 1];
        [self pageType];
        [tableView finishInfiniteScroll];
    }];
}

- (void) answersListForQuestion:(NSNotification *) notification{
    currentQuestion = notification.object;
    [self performSegueWithIdentifier:@"showAnswersListForQuestion" sender:self];
}
- (void) commentsListForQuestion: (NSNotification *) notification{
    currentQuestion = notification.object;
    [self performSegueWithIdentifier:@"comments_list" sender:self];
}
- (void) pageType{
    if(self.user_page){
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ - %@", [self.user_page getCorrectNaming], NSLocalizedString(@"user-questions-title", nil) ] ];
        mainURL = [NSString stringWithFormat:@"/users/%@/questions", self.user_page.objectId];
    } else if(self.category){
        mainURL = [NSString stringWithFormat:@"/categories/%@/questions", self.category.objectId];
    }
    else {
        mainURL = @"/questions";
    }
    [self loadQuestions];
}

- (void) refreshInit{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView addSubview:refreshView]; //the tableView is a IBOutlet
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    refreshControl.backgroundColor = [UIColor grayColor];
    [refreshView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(loadLatestQuestions) forControlEvents:UIControlEventValueChanged];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(self.category != nil){
        return 100;
    } else {
        return 50;
    }
}
- (void) loadLatestQuestions{
    self.questions = [NSMutableArray new];
    pageNumber = @1;
    [self loadQuestions];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.1f)];
    if(self.category != nil){
        QuestionCategoryView *view = [[[NSBundle mainBundle] loadNibNamed:@"categoryHeader" owner:self options:nil] firstObject];
        view.categoryImageView.image = [self.category categoryImage];
        view.categoryImageView.layer.cornerRadius = 8.0;
        view.categoryImageView.clipsToBounds = YES;
        view.categoryWebView.backgroundColor = [UIColor clearColor];
        view.categoryWebView.opaque = NO;
        view.categoryWebView.scrollView.scrollEnabled = NO;
        view.categoryTitle.text = self.category.title;
        [view.categoryWebView loadHTMLString:self.category.desc baseURL:nil];
        NSURL *url = [self.category profileImageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIImage *placeholderImage = [UIImage imageNamed:@"category.png"];
        [view.categoryImageView setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            view.categoryImageView.image = image;
        } failure:nil];
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [view addGestureRecognizer:singleFingerTap];
        return view;
    } else {
        filterView = [[[NSBundle mainBundle] loadNibNamed:@"filterView" owner:self options:nil] firstObject];
        filterView.delegate = self;
        return filterView;
    }
}
- (void) handleSingleTap: (UITapGestureRecognizer *)recognizer{
    [self performSegueWithIdentifier:@"categoryDetail" sender:self];
}

-(void) currentUserValue{
    [self toggleCrateQuestionButton];
    [self.tableView reloadData];
}
- (void) showQuestions{
    [self loadQuestions];
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
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    [[Api sharedManager] sendDataToURL:mainURL parameters:@{@"page": pageNumber, @"filter": filter} requestType:@"GET" andComplition:^(id data, BOOL result){
        if(result){
            errorButton.hidden = YES;
            errorButton = nil;
            [errorButton removeFromSuperview];
            [self parseQuestionsData:data];
        } else {
            serverError = [[ServerError alloc] initWithData:data];
            serverError.delegate = self;
            [serverError handle];
        }
    }];
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

-(void) defineNavigationPanel{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController ){
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        revealViewController.rightViewController = nil;
    }
}
- (void) parseQuestionsData:(id) data{
    NSMutableArray *questions;
    if(data[@"questions"] != nil){
        questions = data[@"questions"];
    } else if(data[@"categories"] != nil){
        questions = data[@"categories"];
    } else if(data[@"users"] != nil){
        questions = data[@"users"];
    }
    if(questions != [NSNull null]){
        for(NSMutableDictionary *serverQuestion in questions){
            Question *question = [[Question alloc] initWithParams:serverQuestion];
            [self.questions addObject:question];
        }
        [self.tableView reloadData];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self toggleCrateQuestionButton];
    [self.tableView reloadData];
}
- (void) addQuestionsToList:(NSArray *) arr{
    [self.questions addObjectsFromArray:arr];
//    for(Question *question in arr){
//        [self.questions addObjectsFromquestion];
//    }
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchResults count];
        
    } else {
        return [self.questions count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Question *questionItem;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        questionItem = [searchResults objectAtIndex:indexPath.row];
    } else {
        questionItem = [self.questions objectAtIndex:indexPath.row];
    }
    static NSString *CellIdentifier = @"questionCell";
    QuestionsTableViewCell *cell = (QuestionsTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setQuestionData:questionItem];
    [cell.commentsCount addTarget:self action:@selector(commentsClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.viewsCount addTarget:self action:@selector(viewsClick:) forControlEvents:UIControlEventTouchUpInside];
    if(auth.currentUser && [questionItem.userId integerValue] == [auth.currentUser.objectId integerValue]){
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];

        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
        cell.rightUtilityButtons = rightUtilityButtons;
        cell.delegate = self;
    }
    return cell;
}
- (void) viewsClick: (UIButton *) sender{
    QuestionsTableViewCell *cell = [[[[sender superview] superview] superview] superview];
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    [self tableView:self.tableView didSelectRowAtIndexPath:path];
}
- (void) commentsClick: (UIButton *) sender{
    QuestionsTableViewCell *cell = [[[[sender superview] superview] superview] superview];
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    currentQuestion = self.questions[path.row];
    [self performSegueWithIdentifier:@"comments_list" sender:self];
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            currentQuestion = self.questions[cellIndexPath.row];
            [api sendDataToURL:[NSString stringWithFormat:@"/questions/%@", currentQuestion.objectId] parameters:@{} requestType:@"DELETE" andComplition:^(id data, BOOL success){
                if(success){
                    [self.questions removeObjectAtIndex:cellIndexPath.row];
                    if(self.questions.count == 0){
                        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:cellIndexPath.section] withRowAnimation:UITableViewRowAnimationFade];
                    } else {
                        [self.tableView deleteRowsAtIndexPaths:@[cellIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                    }

                } else {
                    
                }
            }];
            break;
        }
        default:
            break;
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showQuestion"]) {
        Question *question;
        if(self.searchDisplayController.active){
                question = [searchResults objectAtIndex:self.searchDisplayController.searchResultsTableView.indexPathForSelectedRow.row];
        } else {
            question = [self.questions objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        }
        QuestionDetailViewController *detail = segue.destinationViewController;
        detail.question = question;
    }
    if([[segue identifier] isEqualToString:@"showQuestionForm"]){
        Question *question = [self.questions objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        QuestionsFormViewController *form = segue.destinationViewController;
        form.question = currentQuestion;
    }
    if([[segue identifier] isEqualToString:@"showAnswersListForQuestion"]){
        QuestionsFormViewController *form = segue.destinationViewController;
        form.question = currentQuestion;
    }
    if([[segue identifier] isEqualToString:@"categoryDetail"]){
        CategoryDetailViewController *view = segue.destinationViewController;
        view.category = self.category;
    }
    if([[segue identifier] isEqualToString:@"comments_list"]){
        CommentsListViewController *view = segue.destinationViewController;
        view.question = currentQuestion;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"showQuestion" sender:self];
}

- (NSDate *) correctConvertOfDate:(NSString *) date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *correctDate = [dateFormat dateFromString:date];
    return correctDate;
}
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"title contains[c] %@", searchText];
    searchResults = [self.questions filteredArrayUsingPredicate:resultPredicate];
}
- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterContentForSearchText:searchString
    scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
    objectAtIndex:[self.searchDisplayController.searchBar
    selectedScopeButtonIndex]]];
    
    return YES;
}

- (void) sortByAnswer{
    [self resetAllHighlights];
    filterView.answersCountFilter.selected = YES;
    pageNumber = @1;
    self.questions = [NSMutableArray new];
    mainURL = @"/questions/filter";
    filter = @"answers_count";
    [self loadQuestions];
}

- (void) sortByComments{
    [self resetAllHighlights];
    filterView.commentCountFilter.highlighted = YES;
    pageNumber = @1;
    self.questions = [NSMutableArray new];
    mainURL = @"/questions/filter";
    filter = @"comments_count";
    [self loadQuestions];
}

- (void) sortByRate{
    [self resetAllHighlights];
    pageNumber = @1;
    self.questions = [NSMutableArray new];
    mainURL = @"/questions/filter";
    filter = @"rate";
    [self loadQuestions];
}

- (void) sortByViews{
    [self resetAllHighlights];
    pageNumber = @1;
    filterView.viewsCountFilter.layer.borderWidth = 2.0f;
    filterView.viewsCountFilter.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.questions = [NSMutableArray new];
    mainURL = @"/questions/filter";
    filter = @"views";
    [self loadQuestions];
}

- (void) resetAllHighlights{
    filterView.rateFilter.selected = NO;
    filterView.answersCountFilter.selected = NO;
    filterView.commentCountFilter.selected = NO;
    filterView.viewsCountFilter.selected = NO;
}
- (void) handleServerErrorWithError:(id)error{
    if(errorButton){
        errorButton.hidden = NO;
    } else {
        errorButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        errorButton.backgroundColor = [UIColor lightGrayColor];
        [errorButton setTitle:[error messageText] forState:UIControlStateNormal];
        [errorButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [errorButton addTarget:self action:@selector(sendRequest) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:errorButton];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [refreshControl endRefreshing];
}

- (void) sendRequest{
    [self loadQuestions];
}
@end
