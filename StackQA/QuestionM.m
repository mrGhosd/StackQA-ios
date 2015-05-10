//
//  QuestionM.m
//  StackQA
//
//  Created by vsokoltsov on 10.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionM.h"

@implementation QuestionM
- (instancetype) initWithParams: (NSDictionary *) params{
    if(self == [super init]){
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
    return self;
}

- (NSDate *) correctConvertOfDate:(NSString *) date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *correctDate = [dateFormat dateFromString:date];
    return correctDate;
}
@end
