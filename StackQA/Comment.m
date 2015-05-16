//
//  CommentM.m
//  StackQA
//
//  Created by vsokoltsov on 11.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Comment.h"
#import "Api.h"
#import "Question.h"
#import "Answer.h"
#import "User.h"

@implementation Comment
- (instancetype) initWithParams: (NSDictionary *)params{
    if(self == [super init]){
        self.objectId = params[@"id"];
        self.userId = params[@"user_id"];
        self.commentableType = params[@"commentable_type"];
        self.commentableId = params[@"commentable_id"];
        self.text = params[@"text"];
    }
    return self;
}
- (void) create: (NSDictionary *) params{
    NSString *url;
    if(self.answer != nil){
        url = [NSString stringWithFormat:@"/questions/%@/answers/%@/comments", params[@"question_id"], params[@"answer_id"]];
    } else {
        url = [NSString stringWithFormat:@"/questions/%@/comments", params[@"question_id"]];
    }
    [[Api sharedManager] sendDataToURL:url parameters:params requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            [self.commentDelegate createCallbackWithParams:data andSuccess:YES];
        } else {
            [self.commentDelegate createCallbackWithParams:data andSuccess:NO];
        }
    }];
}
- (void) update: (NSDictionary *) params {
    NSString *url;
    if(self.answer != nil){
        url = [NSString stringWithFormat:@"/questions/%@/answers/%@/comments/%@", params[@"question_id"], params[@"answer_id"], self.objectId];
    } else {
        url = [NSString stringWithFormat:@"/questions/%@/comments/%@", params[@"question_id"], self.objectId];
    }
    [[Api sharedManager] sendDataToURL:url parameters:params requestType:@"PUT" andComplition:^(id data, BOOL success){
        if(success){
            [self.commentDelegate updateWithParams:data andSuccess:YES];
        } else {
            [self.commentDelegate updateWithParams:data andSuccess:NO];
        }
    }];
}
- (void) destroyWithPath:(NSIndexPath *) path{
    NSString *url = [self convertCorrectUrl];
    [[Api sharedManager] sendDataToURL:url parameters:nil requestType:@"DELETE" andComplition:^(id data, BOOL success){
        if(success){
            [self.commentDelegate destroyCallback:YES path:path];
        } else {
            [self.commentDelegate destroyCallback:NO path:path];
        }
    }];
}
- (NSMutableString *) convertCorrectUrl{
    if(self.answer != nil){
        return [NSMutableString stringWithFormat:@"/questions/%@/answers/%@/comments/%@", self.question.objectId, self.answer.objectId,
                self.objectId];
    } else {
        return [NSMutableString stringWithFormat:@"/questions/%@/comments/%@", self.question.objectId, self.objectId];
    }
}
- (id) getParentEntity{
    if(self.answer){
        return self.answer;
    } else {
        return self.question;
    }
}
- (void) complainToCommentWithPath: (NSIndexPath *) path{
    NSString *url = [NSString stringWithFormat:@"%@/complaints", [self convertCorrectUrl]];
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"complaintable_type": @"Comment", @"complaintable_id": self.objectId}];
    [[Api sharedManager] sendDataToURL:url parameters:params requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            [self.commentDelegate complaintToCommentWithSuccess:YES andIndexPath:path];
        } else {
            [self.commentDelegate complaintToCommentWithSuccess:NO andIndexPath:path];
        }
    }];
}
@end
