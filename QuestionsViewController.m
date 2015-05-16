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

@interface QuestionsViewController (){
    Question *currentQuestion;
    AuthorizationManager *auth;
    NSNumber *pageNumber;
    Api *api;
    UIApplication *app;
    NSMutableArray *questionsArray;
    NSArray *searchResults;
    QuestionFilter *filterView;
    NSString *defaultQuestionURL;
    NSString *filter;
}

@end

@implementation QuestionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageNumber = @1;
    self.questions = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(currentUserValue) name:@"getCurrentUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(answersListForQuestion:) name:@"answersListForQuestion" object:currentQuestion];
    auth = [AuthorizationManager sharedInstance];
    defaultQuestionURL = @"/questions";
    filter = @"";
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
- (void) pageType{
    if(self.user_page){
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ - вопросы", [self.user_page getCorrectNaming]]];
        [self showUserQuestions];
    } else if(self.category){
        [self loadCategoryQuestion];
    }
    else {
        [self showQuestions];
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(self.category != nil){
        return 100;
    } else {
        return 50;
    }
}
- (void) loadCategoryQuestion{
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/categories/%@/questions", self.category.objectId] parameters:@{@"page": pageNumber} requestType:@"GET" andComplition:^(id data, BOOL result){
        if(result){
            [self parseCategoriesQuestions:data];
        } else {
            NSLog(@"data is %@", data);
        }
    }];
    [self.tableView reloadData];
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

- (void) showUserQuestions{
    api = [Api sharedManager];
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    
    [api sendDataToURL:[NSString stringWithFormat:@"/users/%@/questions", self.user_page.objectId] parameters:@{@"page": pageNumber} requestType:@"GET" andComplition:^(id data, BOOL result){
        if(result){
            [self parseUserQuestionsData:data];
        } else {
            NSLog(@"data is %@", data);
        }
    }];
    [self.tableView reloadData];
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
    
    [[Api sharedManager] sendDataToURL:defaultQuestionURL parameters:@{@"page": pageNumber, @"filter": filter} requestType:@"GET" andComplition:^(id data, BOOL result){
        if(result){
            [self parseQuestionsData:data];
        } else {
            NSLog(@"data is %@", data);
        }
    }];
    [self.tableView reloadData];
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
    NSMutableArray *questions = data[@"questions"];
    if(data[@"questions"] != [NSNull null]){
        for(NSMutableDictionary *serverQuestion in questions){
            Question *question = [[Question alloc] initWithParams:serverQuestion];
            [self.questions addObject:question];
        }
        [self.tableView reloadData];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void) parseCategoriesQuestions: (id) data{
    NSMutableArray *questions = data[@"categories"];
    if(data[@"categories"] != [NSNull null]){
        for(NSMutableDictionary *serverQuestion in questions){
            Question *category = [[Question alloc] initWithParams:serverQuestion];
            [self.questions addObject:category];
        }
        [self.tableView reloadData];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}
- (void) parseUserQuestionsData:(id) data{
    NSMutableArray *questions = data[@"users"];
    if(data[@"questions"] != [NSNull null]){
        for(NSMutableDictionary *serverQuestion in questions){
            Question *category = [[Question alloc] initWithParams:serverQuestion];
            [self.questions addObject:category];
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
    cell.questionTitle.text = questionItem.title;
    cell.questionDate.text = [NSString stringWithFormat:@"%@", (Question *)questionItem.createdAt];
    cell.questionRate.text = [NSString stringWithFormat:@"%@", questionItem.rate];
    [self setQuestionRateViewForCell:cell andItem:questionItem];
    [cell.viewsCount setTitle:[NSString stringWithFormat:@"%@", questionItem.views] forState:UIControlStateNormal];
    [cell.answersCount setTitle:[NSString stringWithFormat:@"%@", questionItem.answersCount] forState:UIControlStateNormal];
    [cell.commentsCount setTitle:[NSString stringWithFormat:@"%@", questionItem.commentsCount] forState:UIControlStateNormal];
    
    if(auth.currentUser && [questionItem.userId integerValue] == [auth.currentUser.objectId integerValue]){
        NSMutableArray *rightUtilityButtons = [NSMutableArray new];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:0.78f green:0.78f blue:0.8f alpha:1.0]
                                                     icon:[UIImage imageNamed:@"edit-32.png"]];
        [rightUtilityButtons sw_addUtilityButtonWithColor:
         [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f] icon:[UIImage imageNamed:@"delete_sign-32.png"]];
        cell.rightUtilityButtons = rightUtilityButtons;
        cell.delegate = self;
    }
    return cell;
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
    switch (index) {
        case 0:
        {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            currentQuestion = self.questions[cellIndexPath.row];
            [self performSegueWithIdentifier:@"showQuestionForm" sender:self];
            break;
        }
        case 1:
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


- (void) setQuestionRateViewForCell:(QuestionsTableViewCell *) cell andItem: (Question *) question{
    if(question.isClosed){
        cell.questionRate.backgroundColor = [UIColor greenColor];
    } else {
        cell.questionRate.backgroundColor = [UIColor lightGrayColor];
    }
    cell.questionRate.textColor = [UIColor whiteColor];
    cell.questionRate.clipsToBounds = YES;
    cell.questionRate.layer.cornerRadius = 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showQuestion"]) {
        Question *question = [self.questions objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
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
    defaultQuestionURL = @"/questions/filter";
    filter = @"answers_count";
    [self loadQuestions];
}

- (void) sortByComments{
    [self resetAllHighlights];
    filterView.commentCountFilter.highlighted = YES;
    pageNumber = @1;
    self.questions = [NSMutableArray new];
    defaultQuestionURL = @"/questions/filter";
    filter = @"comments_count";
    [self loadQuestions];
}

- (void) sortByRate{
    [self resetAllHighlights];
    pageNumber = @1;
    self.questions = [NSMutableArray new];
    defaultQuestionURL = @"/questions/filter";
    filter = @"rate";
    [self loadQuestions];
}

- (void) sortByViews{
    [self resetAllHighlights];
    pageNumber = @1;
    filterView.viewsCountFilter.layer.borderWidth = 2.0f;
    filterView.viewsCountFilter.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.questions = [NSMutableArray new];
    defaultQuestionURL = @"/questions/filter";
    filter = @"views";
    [self loadQuestions];
}

- (void) resetAllHighlights{
    filterView.rateFilter.selected = NO;
    filterView.answersCountFilter.selected = NO;
    filterView.commentCountFilter.selected = NO;
    filterView.viewsCountFilter.selected = NO;
}
@end
