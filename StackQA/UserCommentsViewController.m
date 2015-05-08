//
//  UserCommentsViewController.m
//  StackQA
//
//  Created by vsokoltsov on 07.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "UserCommentsViewController.h"
#import "UserCommentTableViewCell.h"
#import "Comment.h"
#import "Api.h"
#import <CoreData+MagicalRecord.h>
#import "AuthorizationManager.h"

@interface UserCommentsViewController (){
    NSMutableArray *commentsList;
    NSManagedObjectContext *localContext;
    AuthorizationManager *auth;
}

@end

@implementation UserCommentsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    localContext = [NSManagedObjectContext MR_contextForCurrentThread];
    auth = [AuthorizationManager sharedInstance];
    commentsList = [NSMutableDictionary new];
    [self loadUserCommentsData];
    // Do any additional setup after loading the view.
}

- (void) loadUserCommentsData{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat: @"/users/%@/comments", self.user.object_id] parameters:@{} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            [self parseData:data];
        } else {
            
        }
    }];
}
- (void) parseData: (id)data{
    [Comment sync:data[@"users"]];
    [Comment setCommentsToUser:self.user];
    for(Comment *comment in self.user.comments){
        [commentsList addObject:comment];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"commentCell";
    UserCommentsViewController *cell = (UserCommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(commentsList.count != nil){
        self.tableView.backgroundView = nil;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return 1;
    } else{
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.layer.frame.size.width, 500)];
        messageLabel.text = @"Комментариев нет";
        messageLabel.textColor = [UIColor blackColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont fontWithName:@"Palatino-Italic" size:20];
        [messageLabel sizeToFit];
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return commentsList.count;
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
