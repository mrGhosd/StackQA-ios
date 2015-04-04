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
#import "ImageView.h"

@interface ProfileViewController (){
    AuthorizationManager *auth;
    UICKeyChainStore *store;
    ImageView *imageWrapper;
}

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideImageView) name:@"hideImageView" object:nil];
    auth = [AuthorizationManager sharedInstance];
    store = [UICKeyChainStore keyChainStore];
    [self defineNavigationPanel];
    self.userAvatar.image = [self.user profileImage];
    self.userAvatar.layer.cornerRadius = self.userAvatar.frame.size.height / 2;
    self.userAvatar.layer.masksToBounds = YES;
    self.userAvatar.layer.borderWidth = 0;
    self.userFullName.text = self.user.correct_naming;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)logOut:(id)sender {
    auth.currentUser = nil;
    [store removeItemForKey:@"email"];
    [store removeItemForKey:@"password"];
    [store removeItemForKey:@"access_token"];
    [self performSegueWithIdentifier:@"logOut" sender:self];
}
@end
