//
//  ProfileViewController.m
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "ProfileViewController.h"
#import "AuthorizationManager.h"
#import <UICKeyChainStore.h>
#import "SWRevealViewController.h"
#import "StatisticViewController.h"
#import "QuestionsViewController.h"
#import "UserAnswersViewController.h"
#import "UserCommentsViewController.h"
#import "ImageView.h"

@interface ProfileViewController (){
    AuthorizationManager *auth;
    UICKeyChainStore *store;
    ImageView *imageWrapper;
    NSArray *paramsIDs;
    NSArray *userParams;
    NSArray *userValues;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideImageView) name:@"hideImageView" object:nil];
    auth = [AuthorizationManager sharedInstance];
    paramsIDs = @[@"user_questions", @"userAnswers", @"user_comments"];
    userParams= @[@"Вопросов:", @"Ответов:", @"Комментариев"];
    userValues = @[auth.currentUser.questions_count, auth.currentUser.answers_count, auth.currentUser.comments_count];
    store = [UICKeyChainStore keyChainStore];
    self.userParamsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self defineNavigationPanel];
    self.userAvatar.image = [self.user profileImage];
    self.userAvatar.layer.cornerRadius = self.userAvatar.frame.size.height / 2;
    self.userAvatar.layer.masksToBounds = YES;
    self.userAvatar.layer.borderWidth = 0;
    self.userFullName.text = [self.user getCorrectNaming];
    [self.userRate setTitle:[NSString stringWithFormat:@"%@", auth.currentUser.rate] forState:UIControlStateNormal];
    self.signOutButton.layer.cornerRadius = 4.f;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
    singleTap.numberOfTapsRequired = 1;
    [self.userAvatar setUserInteractionEnabled:YES];
    [self.userAvatar addGestureRecognizer:singleTap];

    // Do any additional setup after loading the view.
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) hideImageView{
    [imageWrapper removeFromSuperview];
    self.navigationController.navigationBar.hidden = NO;
}
- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    imageWrapper.imageHeightConstraint.constant = screenSize.height - 80;
    imageWrapper.imageWidthConstraint.constant = screenSize.width - 20;
}
-(void) defineNavigationPanel{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        revealViewController.rightViewController = nil;
        
    }
}

- (void) tapDetected{
    NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"ImageView"
                                                      owner:self
                                                    options:nil];
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    imageWrapper = [nibViews objectAtIndex:0];
    imageWrapper.mainImage.image = [self.user profileImage];
    imageWrapper.imageHeightConstraint.constant = screenSize.height - 30;
    imageWrapper.imageWidthConstraint.constant = screenSize.width - 20;
    imageWrapper.backgroundColor = [UIColor lightGrayColor];
    self.navigationController.navigationBar.hidden = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleImageActionView)];
    singleTap.numberOfTapsRequired = 1;
    [imageWrapper.mainImage setUserInteractionEnabled:YES];
    [imageWrapper.mainImage addGestureRecognizer:singleTap];
    [self.view addSubview:imageWrapper];
//
}
- (void) toggleImageActionView{
    if(imageWrapper.actionView.hidden){
        imageWrapper.actionView.hidden = NO;
    } else {
        imageWrapper.actionView.hidden = YES;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return userParams.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"profileCell";
    NSString *label = userParams[indexPath.row];
    NSNumber *value = userValues[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.textLabel.text = label;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", value];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:paramsIDs[indexPath.row] sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)showUserStatistic:(id)sender {
    if(self.user.object_id == auth.currentUser.object_id){
        [self performSegueWithIdentifier:@"user_statistic" sender:self];
    } 
}

- (IBAction)signOut:(id)sender {
    auth.currentUser = nil;
    [store removeItemForKey:@"email"];
    [store removeItemForKey:@"password"];
    [store removeItemForKey:@"access_token"];
    [self performSegueWithIdentifier:@"logOut" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"show_statistic"]){
        StatisticViewController *view = segue.destinationViewController;
    }
    if([[segue identifier] isEqualToString:@"user_questions"]){
        QuestionsViewController *view = segue.destinationViewController;
        view.user_page = self.user;
    }
    if([[segue identifier] isEqualToString:@"user_comments"]){
        UserCommentsViewController *view = segue.destinationViewController;
        view.user = self.user;
    }
    if([[segue identifier] isEqualToString:@"userAnswers"]){
        UserAnswersViewController *view = segue.destinationViewController;
        view.user = self.user;
    }
}
@end
