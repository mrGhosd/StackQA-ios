//
//  QuestionM.h
//  StackQA
//
//  Created by vsokoltsov on 10.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuestionM : NSObject
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
- (instancetype) initWithParams: (NSDictionary *) params;
@end
