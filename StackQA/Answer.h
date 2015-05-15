//
//  AnswerM.h
//  StackQA
//
//  Created by vsokoltsov on 11.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnswerDelegate.h"
@class Question;
@class User;
@class Comment;

@interface Answer : NSObject
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic) BOOL isHelpfull;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * questionId;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Question *question;
@property (nonatomic, retain) User *user;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, weak) id<AnswerDelegate> answerDelegate;
- (instancetype) initWithParams: (NSDictionary *) params;
- (void) create: (NSDictionary *) params;
- (void) update: (NSDictionary *) params;
- (void) setDelegate: (id) delegate;
- (void) destroyWithIndexPath:(NSIndexPath *) path;
- (void) changeRateWithAction: (NSString *) action andIndexPAth: (NSIndexPath *) path;
- (void) markAsHelpfullWithPath: (NSIndexPath *) path;
@end
