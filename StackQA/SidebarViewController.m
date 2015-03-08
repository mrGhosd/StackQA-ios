//
//  SidebarViewController.m
//  StackQA
//
//  Created by vsokoltsov on 08.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "SidebarViewController.h"

@interface SidebarViewController (){
    NSArray *menuItems;
    NSArray *menuIcons;
}

@end

@implementation SidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    menuItems = @[@"StackQ&A", @"Логин", @"Регистрация", @"Вопросы", @"Категории", @"Отзывы", @"Обратная связь", @"Новости"];
    menuIcons = @[@"", @"login17.png", @"create1.png", @"ask_question-32.png", @"category.png",@"response-32.png", @"feedback-32.png", @"news-32.png"];
//    self.tableView.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = menuItems[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:menuIcons[indexPath.row]];
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
