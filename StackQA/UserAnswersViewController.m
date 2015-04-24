//
//  UserAnswersViewController.m
//  StackQA
//
//  Created by vsokoltsov on 24.04.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "UserAnswersViewController.h"
#import "Api.h"
#import "Answer.h"
#import "AuthorizationManager.h"

@interface UserAnswersViewController (){
    AuthorizationManager *auth;
}

@end

@implementation UserAnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    auth = [AuthorizationManager sharedInstance];
    [[Api sharedManager] getData:[NSString stringWithFormat:@"/users/%@/answers", self.user.object_id] andComplition:^(id data, BOOL success){
        if(success){
            [self parseData:data];
        } else {
            
        }
    }];
    // Do any additional setup after loading the view.
}
- (void) parseData:(NSDictionary *) data{
    NSArray *answers = data[@"users"];
    [Answer sync:answers];
    [Answer setAnswersToUser:self.user];
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

@end
