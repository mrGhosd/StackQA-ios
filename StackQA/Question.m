//
//  QuestionM.m
//  StackQA
//
//  Created by vsokoltsov on 10.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Question.h"
#import "Api.h"

@implementation Question
- (instancetype) initWithParams: (NSDictionary *) params{
    if(self == [super init]){
        [self setParams:params];
    }
    return self;
}

- (void) update: (NSDictionary *)params{
    [self setParams:params];
}
- (NSDate *) correctConvertOfDate:(NSString *) date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *correctDate = [dateFormat dateFromString:date];
    return correctDate;
}

- (void) setParams: (NSDictionary *)params{
    self.objectId = params[@"id"];
    self.userId = params[@"user_id"];
    self.categoryId = params[@"category_id"];
    self.rate = params[@"rate"];
    self.views = params[@"views"];
    self.title = params[@"title"];
    self.isClosed = (BOOL)[params[@"is_closed"] boolValue];
    self.createdAt = [self correctConvertOfDate:params[@"created_at"]];
    self.answersCount = params[@"answers_count"];
    self.commentsCount = params[@"comments_count"];
    self.tags = params[@"tag_list"];
    self.text = params[@"text"];
}

- (NSArray *) breakTagsLine{
    return self.tags.length > 0 ? [self.tags componentsSeparatedByString:@", "] : nil;
}

- (void) changeQuestionRate: (NSString *) value{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@/rate", self.objectId] parameters:@{@"rate": value} requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            [self.rateDelegate successRateCallbackWithData:data];
        } else {
            [self.rateDelegate failedRateCallbackWithData:data];
        }
    }];
}

- (void) destroy{
    [[Api sharedManager] sendDataToURL:[NSString stringWithFormat:@"/questions/%@", self.objectId] parameters:@{} requestType:@"DELETE" andComplition:^(id data, BOOL success){
        if(success){
            [self.questionDelegate successDestroyCallback];
        } else {
            [self.questionDelegate failedDestroyCallback];
        }
    }];
}
@end
