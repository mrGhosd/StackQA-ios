//
//  Authorization.h
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Authorization : NSManagedObject

@property (nonatomic, retain) NSString * access_token;
@property (nonatomic, retain) NSNumber * created_at;
@property (nonatomic, retain) NSNumber * expires_in;
@property (nonatomic, retain) NSString * token_type;

@end
