//
//  CommentM.m
//  StackQA
//
//  Created by vsokoltsov on 11.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Comment.h"

@implementation Comment
- (instancetype) initWithParams: (NSDictionary *)params{
    if(self == [super init]){
        self.objectId = params[@"id"];
        self.userId = params[@"user_id"];
        self.commentableType = params[@"commentable_type"];
        self.commentableId = params[@"commentable_id"];
        self.text = params[@"text"];
    }
    return self;
}
@end
