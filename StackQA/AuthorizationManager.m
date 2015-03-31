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
- (id) init{
    
    return self;
}
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
}

- (void) currentUserValue{

}

- (void) getTokenWithEmail:(NSString *) email andPassword: (NSString *)password{
    store = [UICKeyChainStore keyChainStore];
    [[Api sharedManager] getTokenWithParameters: @{@"grant_type":@"password",
    @"email": email, @"password": password} andComplition:^(id data, BOOL success){
    if(success){
            [store setString:data[@"access_token"] forKey:@"access_token"];
            [self getCurrentUserProfileWithEmail:email andPassword:password];
        } else {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"errorUserProfileDownloadMessage"
             object:self];
        }
    }];
}

- (void) getCurrentUserProfileWithEmail:(NSString *)email andPassword: (NSString *)password{
    [[Api sharedManager] getData:@"/profiles/me" andComplition:^(id data, BOOL success){
        if(success){
            [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext){
                User *current_user;
                User *user = [User MR_findFirstByAttribute:@"email" withValue:data[@"email"]];
                if(user){
                    current_user = user;
                } else {
                    current_user = [User MR_createInContext:localContext];
                }
                
                current_user.email = data[@"email"];
                current_user.surname = [NSString stringWithFormat:@"%@", data[@"surname"]];
                current_user.name = [NSString stringWithFormat:@"%@", data[@"name"]];
                current_user.correct_naming = data[@"correct_naming"];
                current_user.rate = data[@"rate"];
                current_user.avatar_url = [NSString stringWithFormat:@"%@", data[@"avatar"][@"url"]];
                self.currentUser = current_user;
                [localContext MR_saveOnlySelfAndWait];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"getCurrentUser"
                 object:self];
            }];
        } else {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"errorUserProfileDownloadMessage"
             object:self];
        }
    }];
}
@end
