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
#import "ServerError.h"
#import "Api.h"
#import <MBProgressHUD.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface ProfileViewController (){
    AuthorizationManager *auth;
    UICKeyChainStore *store;
    ImageView *imageWrapper;
    UIButton *errorButton;
    UIRefreshControl *refreshControl;
    ServerError *serverError;
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
    store = [UICKeyChainStore keyChainStore];
    self.userParamsTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self defineNavigationPanel];
    [self refreshInit];
    [self loadProfile];

    // Do any additional setup after loading the view.
}

- (void) refreshInit{
    UIView *refreshView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [self.scrollView addSubview:refreshView]; //the tableView is a IBOutlet
    
    refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor whiteColor];
    refreshControl.backgroundColor = [UIColor grayColor];
    [refreshView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(loadProfile
                                                    ) forControlEvents:UIControlEventValueChanged];
}

- (void) loadProfile{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/users/%@", self.user.objectId] parameters:@{} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            errorButton.hidden = YES;
            [self parseUserdata:data];
        } else {
            serverError = [[ServerError alloc] initWithData:data];
            serverError.delegate = self;
            [serverError handle];
        }
    }];
}

- (void) parseUserdata: (id) data{
    self.user = [[User alloc] initWithParams:data];
    paramsIDs = @[@"user_questions", @"userAnswers", @"user_comments"];
    userParams= @[NSLocalizedString(@"questions-count", nil), NSLocalizedString(@"answers-count", nil), NSLocalizedString(@"comments-count", nil)];
    userValues = @[self.user.questionsCount, self.user.answersCount, self.user.commentsCount];
    self.userFullName.text = [self.user getCorrectNaming];
    [self.userRate setTitle:[NSString stringWithFormat:@"%@", self.user.rate] forState:UIControlStateNormal];
    if(auth.currentUser && [auth.currentUser.objectId isEqual: self.user.objectId ]){
        self.signOutButton.hidden = NO;
    } else {
        self.signOutButton.hidden = YES;
    }
    NSURL *url = [self.user profileImageURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    UIImage *placeholderImage = [UIImage imageNamed:@"user7.png"];
    [self.userAvatar setImageWithURLRequest:request placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.userAvatar.image = image;
        self.userAvatar.layer.cornerRadius = self.userAvatar.frame.size.height / 2;
    } failure:nil];
    self.userAvatar.clipsToBounds = YES;
    [refreshControl endRefreshing];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.userParamsTable reloadData];
    
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
    if([self.user.objectId isEqual:auth.currentUser.objectId]){
        [self performSegueWithIdentifier:paramsIDs[indexPath.row] sender:self];
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
- (IBAction)showUserStatistic:(id)sender {
    if([self.user.objectId isEqual: auth.currentUser.objectId]){
        [self performSegueWithIdentifier:@"user_statistic" sender:self];
    } 
}

- (IBAction)signOut:(id)sender {
    auth.currentUser = nil;
    [store removeItemForKey:@"email"];
    [store removeItemForKey:@"password"];
    [store removeItemForKey:@"access_token"];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"signedOut"
     object:self];
    [self performSegueWithIdentifier:@"logOut" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"user_statistic"]){
        StatisticViewController *view = segue.destinationViewController;
        view.user = self.user;
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
        [errorButton addTarget:self action:@selector(loadProfile) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:errorButton];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [refreshControl endRefreshing];
}
@end
