//
//  AuthorizationManager.m
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "AuthorizationManager.h"
#import <Foundation/Foundation.h>
#import "Api.h"

@implementation AuthorizationManager{
    Api *api;
}

static AuthorizationManager *sharedSingleton_ = nil;

+ (id) sharedInstance{
    static AuthorizationManager *auth = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        auth = [[self alloc] init];
    });
    return auth;
}
- (void) signInUserWithLogin:(NSString *)email andPassword: (NSString *) password{
    [[Api sharedManager] sendDataToURL:@"/oauth/token" parameters:@{@"grant_type":@"password",
     @"email": email, @"password": password} andComplition:^(id data, BOOL success){
         if(success){
             
         } else {
             
         }
     }];
}
@end
