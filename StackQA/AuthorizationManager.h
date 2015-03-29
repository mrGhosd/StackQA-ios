//
//  AuthorizationManager.h
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AuthorizationManager : NSObject
+ (id) sharedInstance;
- (void) signInUserWithLogin:(NSString *)email andPassword: (NSString *) password;
@end
