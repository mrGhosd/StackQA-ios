//
//  Question.h
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class QuestionDetail;

@interface Question : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * created_at;
@property (nonatomic, retain) NSNumber * user_id;
@property (nonatomic, retain) QuestionDetail *questionDetail;

@end
