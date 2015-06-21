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
        if(params[@"surname"]== [NSNull null]){
            self.surname = @"";
        } else {
            self.surname = params[@"surname"];
        }
        if(params[@"name"] == [NSNull null]){
            self.name = @"";
        } else {
            self.name = params[@"name"];
        }
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
- (NSURL *) profileImageURL{
    return [NSURL URLWithString:[[Api sharedManager] returnCorrectUrlPrefix:self.avatarUrl] ];
}
- (NSString *) getCorrectNaming{
    NSString *trimSurname  = [self.surname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trimName  = [self.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    if((![self.surname  isEqualToString: @""] && ![self.name  isEqualToString: @""]) &&
       (self.surname.length > 0 || self.name.length > 0)){
        return [NSString stringWithFormat:@"%@ %@", self.surname, self.name];
    } else {
        return self.email;
    }
}
@end
