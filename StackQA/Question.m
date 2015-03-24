//
//  Question.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Question.h"
#import "AppDelegate.h"
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
@dynamic answers_count;
@dynamic comments_count;
@dynamic answers_list;

- (void) create:(id) attributes{
    Question *question = [Question MR_findFirstByAttribute:@"object_id" withValue:attributes[@"id"]];
    if(!question){
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext){
            Question *q = [Question MR_createInContext:localContext];
            q.object_id = attributes[@"id"];
            q.user_id = attributes[@"user_id"];
            q.category_id = attributes[@"category_id"];
            q.rate = attributes[@"rate"];
            q.title = attributes[@"title"];
            q.created_at = [Question correctConvertOfDate:attributes[@"created_at"]];
            q.text = attributes[@"text"];
            [localContext MR_save];
        }];
    }

}

+ (NSDate *) correctConvertOfDate:(NSString *) date{
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSDate *correctDate = [dateFormat dateFromString:date];
    return correctDate;
}

@end
