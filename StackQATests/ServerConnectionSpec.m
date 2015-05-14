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
#define TestNeedsToWaitForBlock() __block BOOL blockFinished = NO
#define BlockFinished() blockFinished = YES
#define WaitForBlock() while (CFRunLoopRunInMode(kCFRunLoopDefaultMode, 0, true) && !blockFinished)

SPEC_BEGIN(ServerConnectionSpec)
describe(@"start", ^{
    __block ServerConnection *serverConnection;
//
    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });
    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });
    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });
//
    it(@"return false if status 404", ^{
        __block BOOL result;
        stubRequest(@"POST", @"http://localhost:3000/api/v1/questions").
        withHeaders(@{@"Content-Type": @"application/json"}).
        andReturn(404);
        
        serverConnection = [ServerConnection new];
        serverConnection.url = @"/questions";
        serverConnection.requestType = @"POST";
        serverConnection.params = @{};

        [serverConnection startWithParams:^(id data, BOOL success){
            result = success;
        }];
        [[expectFutureValue(theValue(result)) shouldEventually] beFalse];
    });
//
//    it(@"return true if status 200", ^{
//        __block BOOL result;
//        stubRequest(@"GET", @"http://localhost:3000/api/v1/questions").
//        andReturn(200).
//        withHeaders(@{@"Content-Type": @"application/json"});
//        
//        [serverConnection startWithParams:^(id data, BOOL success){
//            result = success;
//            
//        }];
//        [[expectFutureValue(theValue(result)) shouldEventually] beTrue];
//    });
    
});
SPEC_END
