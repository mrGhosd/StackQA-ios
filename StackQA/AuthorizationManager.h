//
//  AuthorizationManager.h
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Authorization.h"
#import "User.h"

@interface AuthorizationManager : NSObject
@property(strong, nonatomic) User *currentUser;
@property(strong, nonatomic) Authorization *currentAuthorization;
+ (id) sharedInstance;
- (void) signInUserWithEmail:(NSString *)email andPassword: (NSString *) password;
@end
