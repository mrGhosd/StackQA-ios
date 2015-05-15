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

@interface StatisticViewController (){
    NSArray *userStatList;
    NSArray *userStatValuesList;
    AuthorizationManager *auth;
    SStatistic *statistic;
}

@end

@implementation StatisticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    auth = [AuthorizationManager sharedInstance];
    userStatList = @[@"Рейтинг", @"Ответов", @"+ за вопрос", @"- за вопрос", @"+ за ответ", @"- за ответ", @"Полезных ответов на вопрос", @"Первых ответов на вопрос", @"Первых ответов на свои вопросы", @"Ответов на свои вопросы"];
    statistic = auth.currentUser.statistic;
    userStatValuesList = @[ auth.currentUser.rate,
                            auth.currentUser.answersCount,
                            statistic.questions_positive_rate_count,
                            statistic.questions_negative_rate_count,
                            statistic.answers_positive_rate_count,
                            auth.currentUser.statistic.answers_negative_rate_count,
                            auth.currentUser.statistic.helpfull_answers_count,
                            auth.currentUser.statistic.first_answers_count,
                            auth.currentUser.statistic.first_self_answers_count,
                            auth.currentUser.statistic.self_answers_count];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    // Do any additional setup after loading the view.
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
