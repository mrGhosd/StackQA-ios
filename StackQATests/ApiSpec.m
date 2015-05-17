//
//  ApiSpec.m
//  StackQA
//
//  Created by vsokoltsov on 17.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Api.h"
#import <Kiwi.h>
#import <OHHTTPStubs.h>
#import <OHHTTPStubsResponse.h>

SPEC_BEGIN(ApiSpec)
describe(@"#sendDataToUTL", ^{
        __block Api *api;
        __block BOOL result;
        __block id serverData;
    
        afterEach(^{
            [OHHTTPStubs removeAllStubs];
        });
    
        it(@"return false if status 404", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@[@"data"] statusCode:404 headers:@{@"Content-Type": @"application/json"}];
            }];
    
            [[Api sharedManager] sendDataToURL:@"/questions" parameters:@{} requestType:@"POST" andComplition:^(id data, BOOL success){
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
        
            [[Api sharedManager] sendDataToURL:@"/questions" parameters:@{} requestType:@"POST" andComplition:^(id data, BOOL success){
                result = success;
            }];
        
            [[expectFutureValue(theValue(result)) shouldEventually] beTrue];
        });
    
        it(@"return json string if data is not empty", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@[@"data"] statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
        
            [[Api sharedManager] sendDataToURL:@"/questions" parameters:@{} requestType:@"POST" andComplition:^(id data, BOOL success){
                result = success;
                serverData = data;
            }];
        
            [[expectFutureValue(serverData) shouldEventually] equal:@[@"data"]];
        });
        it(@"return dictionary with opeartion param and error param if status 404", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@[@"data"] statusCode:404 headers:@{@"Content-Type": @"application/json"}];
            }];
        
            [[Api sharedManager] sendDataToURL:@"/questions" parameters:@{} requestType:@"POST" andComplition:^(id data, BOOL success){
                serverData = data;
            }];
        
            [[expectFutureValue(serverData[@"error"]) shouldEventually] beKindOfClass:[NSError class]];
            [[expectFutureValue(serverData) shouldEventually] beKindOfClass:[NSDictionary class]];
            
        });


    });

SPEC_END

