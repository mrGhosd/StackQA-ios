//
//  UserM.m
//  StackQA
//
//  Created by vsokoltsov on 10.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "User.h"
#import "Api.h"

@implementation User
- (instancetype) initWithParams: (NSDictionary *) params{
    if(self == [super init]){
        self.objectId = params[@"id"];
        self.email = params[@"email"];
        self.surname = [NSString stringWithFormat:@"%@", params[@"surname"]];
        self.name = [NSString stringWithFormat:@"%@", params[@"name"]];
        self.correctNaming = params[@"correct_naming"];
        self.rate = params[@"rate"];
        self.questionsCount = params[@"questions_count"];
        self.answersCount = params[@"answers_count"];
        self.commentsCount = params[@"comments_count"];
        self.avatarUrl = params[@"avatar"][@"url"];
    }
    return self;
}
- (UIImage *) profileImage{
    UIImage *img  =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[[Api sharedManager] returnCorrectUrlPrefix:self.avatarUrl]]]];
    return img;
}
- (NSString *) getCorrectNaming{
    if(self.correctNaming != nil){
        return self.correctNaming;
    } else {
        if(self.surname != @"" && self.name != @""){
            return [NSString stringWithFormat:@"%@ %@", self.surname, self.name];
        } else {
            return self.email;
        }
    }
}
@end
