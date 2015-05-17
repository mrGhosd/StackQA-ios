//
//  ServerConnection.m
//  StackQA
//
//  Created by vsokoltsov on 14.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ServerConnection.h"
#import <Kiwi.h>
#import <Nocilla.h>
#import <OHHTTPStubs.h>
#import <OHHTTPStubsResponse.h>

#define TestNeedsToWaitForBlock() __block BOOL blockFinished = NO
#define BlockFinished() blockFinished = YES
#define WaitForBlock() while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !blockFinished)

SPEC_BEGIN(ServerConnectionSpec)
describe(@"ServerConnection instance attributes", ^{

});

describe(@"#start", ^{
    __block ServerConnection *serverConnection;
    __block BOOL result;
    __block id serverData;
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });
    
    beforeEach(^{
        serverConnection = [ServerConnection new];
        serverConnection.url = @"/questions";
        serverConnection.requestType = @"POST";
        serverConnection.params = @{@"text": @"text", @"title": @"title", @"category_id": @"1"};
    });
    
    it(@"return false if status 404", ^{
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:@[@"data"] statusCode:404 headers:@{@"Content-Type": @"application/json"}];
        }];
    
        [serverConnection startWithParams:^(id data, BOOL success){
            serverData = data;
            result = success;
        }];

        [[expectFutureValue(theValue(result)) shouldEventually] beFalse];
    });
    
    it(@"return true if status 200", ^{
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:@[@"data"] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        
        [serverConnection startWithParams:^(id data, BOOL success){
            serverData = data;
            result = success;
        }];
        
        [[expectFutureValue(theValue(result)) shouldEventually] beTrue];
    });
    
    it(@"data is json string, if status 200", ^{
        
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:@[@"data"] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        [serverConnection startWithParams:^(id data, BOOL success){
            serverData = data;
            result = success;
        }];
        
        [[expectFutureValue(serverData) shouldEventually] equal:@[@"data"]];
    });

    
    it(@"data is nil, if status is error", ^{
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:@[@"error"] statusCode:404 headers:@{@"Content-Type": @"application/json"}];
        }];
        
        [serverConnection startWithParams:^(id data, BOOL success){
            serverData = data;
            result = success;
        }];
        
        [[expectFutureValue(serverData) shouldEventually] beKindOfClass:[NSError class]];
    });

});
SPEC_END
