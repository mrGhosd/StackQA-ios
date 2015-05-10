//
//  UserM.h
//  StackQA
//
//  Created by vsokoltsov on 10.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface User : NSObject
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * surname;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * avatarUrl;
@property (nonatomic, retain) NSString * correctNaming;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * questionsCount;
@property (nonatomic, retain) NSNumber * answersCount;
@property (nonatomic, retain) NSNumber * commentsCount;
@property (nonatomic, retain) NSNumber * objectId;
@property (nonatomic, strong) NSMutableSet * questions;
@property (nonatomic, retain) NSMutableSet * answers;
@property (nonatomic, retain) NSMutableSet * comments;
- (instancetype) initWithParams: (NSDictionary *) params;
- (UIImage *) profileImage;
@end
