//
//  User.m
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "User.h"

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
@end
