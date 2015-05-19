//
//  StatisticViewController.m
//  StackQA
//
//  Created by vsokoltsov on 06.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "StatisticViewController.h"
#import "StatisticTableViewCell.h"
#import "SStatistic.h"
#import "ServerError.h"
#import "Api.h"
#import "SStatistic.h"
#import <MBProgressHUD.h>

@interface StatisticViewController (){
    NSArray *userStatList;
    NSArray *userStatValuesList;
    AuthorizationManager *auth;
    SStatistic *statistic;
    ServerError *serverError;
    UIButton *errorButton;
    UIRefreshControl *refreshControl;
}

@end

@implementation StatisticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    auth = [AuthorizationManager sharedInstance];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self refreshInit];
    [self loadUserStatistic];
    // Do any additional setup after loading the view.
}

- (void) loadUserStatistic{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/users/%@/statistic", self.user.objectId] parameters:@{} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            errorButton.hidden = YES;
            [self parseStatistic:data];
        } else {
            serverError = [[ServerError alloc] initWithData:data];
            serverError.delegate = self;
            [serverError handle];
        }
    }];
}

- (void) parseStatistic: (id) data{
    self.user.statistic = [[SStatistic alloc] initWithParams:data];
    userStatList = @[NSLocalizedString(@"rating", nil), NSLocalizedString(@"answers", nil), NSLocalizedString(@"positive_questions_count", nil), NSLocalizedString(@"negative_questions_count", nil),NSLocalizedString(@"positive_answers_count", nil), NSLocalizedString(@"negative_answers_count", nil), NSLocalizedString(@"helpfull_answers", nil), NSLocalizedString(@"first_answer", nil), NSLocalizedString(@"first_answers_on_own_questions", nil), NSLocalizedString(@"own_questions_answers", nil)];
    statistic = self.user.statistic;
    userStatValuesList = @[ self.user.rate,
                            self.user.answersCount,
                            statistic.questions_positive_rate_count,
                            statistic.questions_negative_rate_count,
                            statistic.answers_positive_rate_count,
                            statistic.answers_negative_rate_count,
                            statistic.helpfull_answers_count,
                            statistic.first_answers_count,
                            statistic.first_self_answers_count,
                            statistic.self_answers_count];
    [self.tableView reloadData];
    [refreshControl endRefreshing];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];

}

- (void) refreshInit{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.tableView addSubview:refreshView]; //the tableView is a IBOutlet
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    refreshControl.backgroundColor = [UIColor grayColor];
    [refreshView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(loadUserStatistic) forControlEvents:UIControlEventValueChanged];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return userStatList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *CellIdentifier = @"statisticCell";
    StatisticTableViewCell *cell = (StatisticTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.titleLabel.text = userStatList[indexPath.row];
    cell.numberLabel.text = [NSString stringWithFormat:@"%@", userStatValuesList[indexPath.row]];
    return cell;
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
        [errorButton addTarget:self action:@selector(loadUserStatistic) forControlEvents:UIControlEventTouchUpInside];
        [self.tableView addSubview:errorButton];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [refreshControl endRefreshing];
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
