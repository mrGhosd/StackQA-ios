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
#import "SStatistic.h"

@implementation AuthorizationManager{
    Api *api;
    UICKeyChainStore *store;
}
@synthesize completed = _completed;
@synthesize errored = _errored;


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
    [self getTokenWithEmail:email andPassword:password andComplition:^(id data, BOOL success){
        if(success){
            [self getCurrentUserProfileWithEmail:email andPassword:password];
        } else {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"errorUserProfileDownloadMessage"
             object:self];
        }
        
    }];
}
- (void) signUpWithParams:(NSDictionary *) params andComplition:(ResponseCopmlition) complition{
    ResponseCopmlition response = [complition copy];
    [[Api sharedManager] sendDataToURL:@"/users" parameters:params requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
            [self signInUserWithEmail:params[@"user"][@"email"] andPassword:params[@"user"][@"password"]];
            complition(data, YES);
        } else {
            complition(data, NO);
        }
    }];
}

- (void) getTokenWithEmail:(NSString *) email andPassword: (NSString *)password andComplition: (ResponseCopmlition) complition{
    store = [UICKeyChainStore keyChainStore];
    ResponseCopmlition response = [complition copy];
    [[Api sharedManager] getTokenWithParameters: @{@"grant_type":@"password",
    @"email": email, @"password": password} andComplition:^(id data, BOOL success){
    if(success){
            [store setString:data[@"access_token"] forKey:@"access_token"];
        response(data, success);
        } else {
            response(data, success);
        }
    }];
}
- (void) getCurrentUserProfileWithEmail:(NSString *)email andPassword: (NSString *)password{
    [[Api sharedManager] getData:@"/profiles/me" andComplition:^(id data, BOOL success){
        if(success){
            [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext){
                User *current_user = [[User alloc] init];
                current_user.objectId = data[@"id"];
                current_user.email = data[@"email"];
                current_user.surname = [NSString stringWithFormat:@"%@", data[@"surname"]];
                current_user.name = [NSString stringWithFormat:@"%@", data[@"name"]];
                current_user.correctNaming = data[@"correct_naming"];
                current_user.rate = data[@"rate"];
                current_user.questionsCount = data[@"questions_count"];
                current_user.answersCount = data[@"answers_count"];
                current_user.commentsCount = data[@"comments_count"];
                current_user.avatarUrl = [NSString stringWithFormat:@"%@", data[@"avatar"][@"url"]];
                current_user.statistic = [[SStatistic alloc] initWithParams:data[@"statistic"]];
                self.currentUser = current_user;
                [localContext MR_saveToPersistentStoreAndWait];
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
