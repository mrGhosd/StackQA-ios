//
//  User.h
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * surname;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * avatar_url;
@property (nonatomic, retain) NSString * correct_naming;
@property (nonatomic, retain) NSNumber * rate;
@property (nonatomic, retain) NSNumber * questions_count;
@property (nonatomic, retain) NSNumber * answers_count;
@property (nonatomic, retain) NSNumber * comments_count;

- (UIImage *) profileImage;
@end
