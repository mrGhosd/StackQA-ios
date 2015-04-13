//
//  SidebarViewController.m
//  StackQA
//
//  Created by vsokoltsov on 08.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "SidebarViewController.h"
#import "AuthorizationViewController.h"
#import "QuestionsViewController.h"
#import "AuthorizationManager.h"
#import "ProfileViewController.h"
#import "ProfileSidebarTableViewCell.h"
#import "SidebarTableViewCell.h"

@interface SidebarViewController (){
    AuthorizationManager *auth;
    NSArray *menuID;
    NSArray *menuItems;
    NSArray *menuIcons;
}

@end

@implementation SidebarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[ProfileSidebarTableViewCell class] forCellReuseIdentifier:@"profileCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileSidebarTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"profileCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor clearColor];
//    self.tableView.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *touched = menuID[indexPath.row];
    [self performSegueWithIdentifier:touched sender:self];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1 && auth.currentUser){
        static NSString *profileCell = @"profileCell";
        ProfileSidebarTableViewCell *cell = (ProfileSidebarTableViewCell *) [tableView dequeueReusableCellWithIdentifier:profileCell forIndexPath:indexPath];
        cell.profileImage.image = [auth.currentUser profileImage];
        cell.profileImage.layer.cornerRadius = cell.profileImage.frame.size.height / 2;
        cell.profileImage.layer.masksToBounds = YES;
        cell.profileImage.layer.borderWidth = 0;
        cell.profileName.text = auth.currentUser.correct_naming;
        [cell.profileRate setTitle:[NSString stringWithFormat:@"%@", auth.currentUser.rate ] forState:UIControlStateNormal];
        return cell;
    } else {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        cell.textLabel.text = menuItems[indexPath.row];
        cell.imageView.image = [UIImage imageNamed:menuIcons[indexPath.row]];
        return cell;
    }
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([[segue identifier] isEqualToString:@"login"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        AuthorizationViewController *controller = (AuthorizationViewController *)navController.topViewController;
        controller.firstView = 0;
    }
    if([[segue identifier] isEqualToString:@"registration"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        AuthorizationViewController *controller = (AuthorizationViewController *)navController.topViewController;
        controller.firstView = 1;
    }
    if([[segue identifier] isEqualToString:@"questions"]){
        QuestionsViewController *view = segue.destinationViewController;
    }
    if([[segue identifier] isEqualToString:@"profile"]){
        UINavigationController *navController = (UINavigationController *)segue.destinationViewController;
        ProfileViewController *controller = (ProfileViewController *)navController.topViewController;
        controller.user = auth.currentUser;
    }
}
- (void) viewDidAppear:(BOOL)animated{
    auth = [AuthorizationManager sharedInstance];
    if(auth.currentUser){
        menuID = @[@"logo", @"profile", @"questions"];
        menuItems = @[@"StackQ&A", @"Профиль", @"Вопросы"];
        menuIcons = @[@"", @"user7.png", @"ask_question-32.png"];
    } else {
        menuID = @[@"logo", @"login", @"registration", @"questions",  @"categories", @"feedbacks", @"callbacks", @"news"];
        menuItems = @[@"StackQ&A", @"Логин", @"Регистрация", @"Вопросы", @"Категории", @"Отзывы", @"Обратная связь", @"Новости"];
        menuIcons = @[@"", @"login17.png", @"create1.png", @"ask_question-32.png", @"category.png",@"response-32.png", @"feedback-32.png", @"news-32.png"];
    }
    [self.tableView reloadData];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 1 && auth.currentUser){
        return 100;
    } else {
        return 44;
    }
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
