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
    [[Api sharedManager] sendDataToURL:@"/profiles/me" parameters:nil requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
                self.currentUser = [[User alloc] initWithParams:data];
                [[NSNotificationCenter defaultCenter]
                 postNotificationName:@"getCurrentUser"
                 object:self];
        } else {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"errorUserProfileDownloadMessage"
             object:data];
        }
    }];
}
@end
