//
//  AuthorizationViewController.m
//  StackQA
//
//  Created by vsokoltsov on 26.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "AuthorizationViewController.h"
#import "SWRevealViewController.h"

@interface AuthorizationViewController ()

@end

@implementation AuthorizationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self defineNavigationPanel];
    [self setSegmentValue];
    // Do any additional setup after loading the view.
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

-(void) setSegmentValue{
    [self.actionSegment setSelectedSegmentIndex:self.firstView];
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

- (IBAction)switchViews:(id)sender {
}
@end
