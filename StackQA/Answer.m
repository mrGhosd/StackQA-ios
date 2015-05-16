//
//  AnswerM.m
//  StackQA
//
//  Created by vsokoltsov on 11.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Answer.h"
#import "Question.h"
#import "Api.h"

@implementation Answer
- (instancetype) initWithParams: (NSDictionary *) params{
    if(self == [super init]){
        self.objectId = params[@"id"];
        self.userId = params[@"user_id"];
        self.userName = params[@"user_name"];
        self.questionId = params[@"question_id"];
        self.text = params[@"text"];
        self.rate = params[@"rate"];
        self.commentsCount = params[@"comments_count"];
        self.isHelpfull = (BOOL)[params[@"is_helpfull"] boolValue];
    }
    return self;
}
- (void) setDelegate: (id) delegate{
    self.answerDelegate = delegate;
}
- (void) create: (NSDictionary *) params{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers", params[@"question_id"]] parameters:@{@"answer": params} requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            [self.answerDelegate createCallbackWithParams:data andSuccess:YES];
        } else {
            [self.answerDelegate createCallbackWithParams:data andSuccess:NO];
        }
    }];
}

- (void) update: (NSDictionary *) params{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@", params[@"question_id"], self.objectId] parameters:@{@"answer": params} requestType:@"PUT" andComplition:^(id data, BOOL success){
        if(success){
            [self.answerDelegate updateWithParams:data andSuccess:YES];
        } else {
            [self.answerDelegate updateWithParams:data andSuccess:NO];
        }
    }];
}

- (void) destroyWithIndexPath:(NSIndexPath *) path{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@", self.question.objectId, self.objectId] parameters:@{} requestType:@"DELETE" andComplition:^(id data, BOOL success){
        if(success){
            [self.answerDelegate destroyCallback:YES path:path];
        } else {
            [self.answerDelegate destroyCallback:YES path:path];
        }
    }];
}

- (void) changeRateWithAction: (NSString *) action andIndexPAth: (NSIndexPath *) path{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@/rate", self.questionId,
                                        self.objectId ] parameters:@{@"rate": action} requestType:@"POST" andComplition:^(id data, BOOL success){
                if(success){
                    [self.answerDelegate changeRateCallbackWithParams:data path: path andSuccess:YES];
                } else {
                    [self.answerDelegate changeRateCallbackWithParams:data path: path andSuccess:NO];
                }
            }];
}

- (void) markAsHelpfullWithPath: (NSIndexPath *) path{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/answers/%@/helpfull", self.questionId, self.objectId ] parameters:nil requestType:@"POST" andComplition:^(id data, BOOL success){
                if(success){
                    [self.answerDelegate markAsHelpfullCallbackWithParams:data path:path andSuccess:YES];
                } else {
                    [self.answerDelegate markAsHelpfullCallbackWithParams:data path:path andSuccess:NO];
                }
            }];
}
- (void) complainToAnswerWithPath: (NSIndexPath *) path{
    NSString *url = [NSString stringWithFormat:@"/questions/%@/answers/%@/complaints", self.questionId, self.objectId];
    NSMutableDictionary *params =[NSMutableDictionary dictionaryWithDictionary:@{@"complaintable_type": @"Answer", @"complaintable_id": self.objectId}];
    [[Api sharedManager] sendDataToURL:url parameters:params requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            [self.answerDelegate complaintToAnswerWithSuccess:YES andIndexPath:path];
        } else {
            [self.answerDelegate complaintToAnswerWithSuccess:NO andIndexPath:path];
        }
    }];
}
@end
