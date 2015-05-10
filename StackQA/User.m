//
//  User.m
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "User.h"
#import "Question.h"
#import <CoreData+MagicalRecord.h>

@implementation User

@dynamic object_id;
@dynamic email;
@dynamic surname;
@dynamic name;
@dynamic avatar_url;
@dynamic correct_naming;
@dynamic rate;
@dynamic questions_count;
@dynamic answers_count;
@dynamic comments_count;
@dynamic statistic;

- (NSString *) fullUrlToUserImage{
    NSString *url = [NSString stringWithFormat:@"http://localhost:3000%@", self.avatar_url];
    return url;
}

- (UIImage *) profileImage{
    UIImage *img  =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self fullUrlToUserImage]]]];
    return img;
}

+ (User *) create: (NSDictionary *) params{
    __block User *userData;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        User *user = [self defineUserWithId:params[@"id"] andContext:localContext];
        [user setParams:params inContext:localContext];
        userData = user;
        [localContext MR_save];
    }];
    return userData;
}
+ (User *) defineUserWithId: (id) object_id andContext: (NSManagedObjectContext *) context{
    User *user;
    User *current_c = [User MR_findFirstByAttribute:@"object_id" withValue:object_id];
    if(current_c){
        user = current_c;
    } else {
        user = [User MR_createInContext:context];
    }
    return user;
}

- (void) setParams:(NSDictionary *)params inContext:(NSManagedObjectContext *) context{
    if (!self.statistic){;
        self.statistic = [SQAStatistic MR_createInContext:context];
    }
    self.object_id = params[@"id"];
    self.email = params[@"email"];
    self.surname = [NSString stringWithFormat:@"%@", params[@"surname"]];
    self.name = [NSString stringWithFormat:@"%@", params[@"name"]];
    self.correct_naming = params[@"correct_naming"];
    self.rate = params[@"rate"];
    self.questions_count = params[@"questions_count"];
    self.answers_count = params[@"answers_count"];
    self.comments_count = params[@"comments_count"];
    self.statistic.answers_negative_rate_count = params[@"statistic"][@"answers_negative_rate_count"];
    self.statistic.answers_positive_rate_count = params[@"statistic"][@"answers_positive_rate_count"];
    self.statistic.first_answers_count = params[@"statistic"][@"first_answers_count"];
    self.statistic.first_self_answers_count = params[@"statistic"][@"first_self_answers_count"];
    self.statistic.helpfull_answers_count = params[@"statistic"][@"helpfull_answers_count"];
    self.statistic.questions_negative_rate_count = params[@"statistic"][@"questions_negative_rate_count"];
    self.statistic.questions_positive_rate_count = params[@"statistic"][@"questions_positive_rate_count"];
    self.statistic.self_answers_count = params[@"statistic"][@"self_answers_count"];
    self.avatar_url = [NSString stringWithFormat:@"%@", params[@"avatar"][@"url"]];
    
}

- (NSArray *) getQuestions{
    __block NSArray *questions;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"user_id = %@", self.object_id];
        questions = [Question MR_findAllWithPredicate:peopleFilter];
        [localContext MR_save];
    }];
    return questions;
}

- (NSString *) getCorrectNaming{
    if(self.correct_naming != nil){
        return self.correct_naming;
    } else {
        if(self.surname != nil && self.name != nil){
            return [NSString stringWithFormat:@"%@  %@", self.surname, self.name];
        } else {
            return self.email;
        }
    }
}
@end
