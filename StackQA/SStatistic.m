//
//  SStatistic.m
//  StackQA
//
//  Created by vsokoltsov on 15.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "SStatistic.h"

@implementation SStatistic
- (instancetype) initWithParams: (NSDictionary *) params{
    if(self == [super init]){
        self.answers_negative_rate_count = params[@"answers_negative_rate_count"];
        self.answers_positive_rate_count = params[@"answers_positive_rate_count"];
        self.first_answers_count = params[@"first_answers_count"];
        self.first_self_answers_count = params[@"first_self_answers_count"];
        self.helpfull_answers_count = params[@"helpfull_answers_count"];
        self.questions_negative_rate_count = params[@"questions_negative_rate_count"];
        self.questions_positive_rate_count = params[@"questions_positive_rate_count"];
        self.self_answers_count = params[@"self_answers_count"];
    }
    return self;
}
@end
