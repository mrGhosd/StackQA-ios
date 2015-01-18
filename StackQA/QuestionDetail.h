//
//  QuestionDetail.h
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface QuestionDetail : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSManagedObject *question;

@end
