//
//  Comment.h
//  StackQA
//
//  Created by vsokoltsov on 11.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
@class User;
@class Question;
@class Answer;

@interface Comment : NSObject
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, retain) NSNumber * commentableId;
@property (nonatomic, retain) NSString * commentableType;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) Answer *answer;
@property (nonatomic, retain) Question *question;
@end
