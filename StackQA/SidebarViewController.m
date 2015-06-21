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
#import <AFNetworking/UIImageView+AFNetworking.h>

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedIn) name:@"getCurrentUser" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(signedOut) name:@"signedOut" object:nil];
    [self.tableView registerClass:[ProfileSidebarTableViewCell class] forCellReuseIdentifier:@"profileCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ProfileSidebarTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"profileCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor clearColor];
    [self setTableData];
//    [self.tableView reloadData];
//    self.tableView.backgroundColor = [UIColor redColor];
    // Do any additional setup after loading the view.
}
- (void) signedIn{
    [self setTableData];
    [self.tableView reloadData];
}

- (void) signedOut{
    [self setTableData];
    [self.tableView reloadData];
}

- (void) setTableData{
    auth = [AuthorizationManager sharedInstance];
    if(auth.currentUser){
        menuID = @[@"logo", @"profile", @"questions", @"categories"];
        menuItems = @[@"StackQ&A", [auth.currentUser getCorrectNaming], NSLocalizedString(@"sidebar-questions", nil), NSLocalizedString(@"sidebar-categories", nil)];
        menuIcons = @[@"", @"user7.png", @"ask_question-32.png", @"category.png"];
    } else {
        menuID = @[@"logo", @"login", @"registration", @"questions",  @"categories"];
        menuItems = @[@"StackQ&A", NSLocalizedString(@"sidebar-sign-in", nil), NSLocalizedString(@"sidebar-sign-up", nil), NSLocalizedString(@"sidebar-questions", nil), NSLocalizedString(@"sidebar-categories", nil)];
        menuIcons = @[@"", @"login17.png", @"create1.png", @"ask_question-32.png", @"category.png"];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 0){
        return;
    } else {
        NSString *touched = menuID[indexPath.row];
        [self performSegueWithIdentifier:touched sender:self];
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return menuItems.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = menuItems[indexPath.row];
    cell.imageView.frame = CGRectMake(0, 0, 32, 32);
    if(indexPath.row == 0){
        [cell.textLabel setFont:[UIFont fontWithName:@"System" size:22.0]];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    if (auth.currentUser && indexPath.row == 1) {
        NSURL *url = [auth.currentUser profileImageURL];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        UIImage *placeholderImage = [UIImage imageNamed:@"user7.png"];
        [cell.imageView setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {

            cell.imageView.image = image;
            cell.imageView.layer.cornerRadius = cell.imageView.frame.size.height / 2;
        } failure:nil];
        cell.imageView.clipsToBounds = YES;
    } else {
        cell.imageView.image = [UIImage imageNamed:menuIcons[indexPath.row]];
    }
    
    return cell;
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
   
}
//- (void) viewWillAppear:(BOOL)animated{
//}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row == 1 && auth.currentUser){
        return 85;
    } else {
        return 49;
    }
}
- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
