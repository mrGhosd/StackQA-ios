//
//  AuthorizationManager.m
//  StackQA
//
//  Created by vsokoltsov on 29.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "AuthorizationManager.h"
#import <Foundation/Foundation.h>
#import <CoreData+MagicalRecord.h>
#import <UICKeyChainStore.h>
#import "Api.h"

@implementation AuthorizationManager{
    Api *api;
    UICKeyChainStore *store;
}

static AuthorizationManager *sharedSingleton_ = nil;

+ (id) sharedInstance{
    static AuthorizationManager *auth = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        auth = [[self alloc] init];
        auth.currentAuthorization = [[Authorization MR_findAll] firstObject];
    });
    return auth;
}
- (void) signInUserWithEmail:(NSString *)email andPassword: (NSString *) password{
    [self getTokenWithEmail:email andPassword:password];
    [self getCurrentUserProfileWithEmail:email andPassword:password];
}

- (void) getTokenWithEmail:(NSString *) email andPassword: (NSString *)password{
    store = [UICKeyChainStore keyChainStore];
    [[Api sharedManager] getTokenWithParameters: @{@"grant_type":@"password",
    @"email": email, @"password": password} andComplition:^(id data, BOOL success){
    if(success){
            [store setString:data[@"access_token"] forKey:@"access_token"];
        } else {
                                                           
        }
    }];
}

- (void) getCurrentUserProfileWithEmail:(NSString *)email andPassword: (NSString *)password{
    [[Api sharedManager] getData:@"/profiles/me" andComplition:^(id data, BOOL success){
        if(success){
            [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext){
                User *current_user = [User MR_createInContext:localContext];
                current_user.email = data[@"email"];
                current_user.surname = data[@"surname"];
                self.currentUser = current_user;
                [localContext MR_saveOnlySelfAndWait];
            }];
        } else {
            [self signInUserWithEmail:email andPassword:password];
        }
    }];
}
@end
