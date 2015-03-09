//
//  Question.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Question.h"
#import <CoreData+MagicalRecord.h>


@implementation Question

@dynamic object_id;
@dynamic category_id;
@dynamic rate;
@dynamic title;
@dynamic views;
@dynamic is_closed;
@dynamic created_at;
@dynamic user_id;
@dynamic text;

- (BOOL) create:(id) attributes{
    @try {
        NSDictionary *questionJSON = [NSDictionary dictionaryWithDictionary:[attributes copy]];

//        question.questionDetail = [QuestionDetail MR_createInContext:context];
        self.object_id = questionJSON[@"id"];
        self.user_id = questionJSON[@"user_id"];
        self.category_id = questionJSON[@"category_id"];
        self.rate = questionJSON[@"rate"];
        self.title = questionJSON[@"title"];
        self.created_at = [self correctConvertOfDate:questionJSON[@"created_at"]];
        self.text = questionJSON[@"text"];
        return true;
    }
    @catch(NSException *e){
        return false;
    }
    
}

- (NSDate *) correctConvertOfDate:(NSString *) date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *correctDate = [dateFormat dateFromString:date];
//    [dateFormat setDateFormat:@"dd.MM.YYYY HH:mm:SS"];
//    NSString *finalDate = [dateFormat stringFromDate:correctDate];
    return correctDate;
}

@end
