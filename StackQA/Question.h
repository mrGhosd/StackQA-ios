//
//  QuestionM.h
//  StackQA
//
//  Created by vsokoltsov on 10.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ApiResponseCopmlition)(id data, BOOL success);
#import "RatingDelegate.h"
#import "QuestionDelegate.h"
@class SCategory;


@interface Question : NSObject
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, retain) NSNumber * categoryId;
@property (nonatomic) BOOL isClosed;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * views;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * tags;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSNumber * answersCount;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSMutableArray * answersList;
@property (nonatomic, strong) NSMutableArray *answers;
@property (nonatomic, retain) NSMutableArray *comments;
@property (nonatomic, retain) SCategory *category;
@property (nonatomic, weak) id<RatingDelegate> rateDelegate;
@property (nonatomic, weak) id<QuestionDelegate> questionDelegate;
- (instancetype) initWithParams: (NSDictionary *) params;
- (void) update: (NSDictionary *)params;
- (NSArray *) breakTagsLine;
- (void) changeQuestionRate: (NSString *) value;
- (void) destroy;
- (void) complaintToQuestion;
@end
