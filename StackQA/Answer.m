//
//  AnswerM.m
//  StackQA
//
//  Created by vsokoltsov on 11.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Answer.h"
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
    
}

- (void) destroy{
    
}

- (void) changeRateWithAction: (NSString *) action{

}

- (void) markAsHelpfull{

}
@end
