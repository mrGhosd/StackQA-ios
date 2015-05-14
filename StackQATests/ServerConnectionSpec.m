//
//  ServerConnection.m
//  StackQA
//
//  Created by vsokoltsov on 14.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ServerConnection.h"
#import <Kiwi/Kiwi.h>
#import <Nocilla.h>

SPEC_BEGIN(ServerConnectionSpec)
describe(@"start", ^{
    
    beforeAll(^{
        [[LSNocilla sharedInstance] start];
    });
    afterAll(^{
        [[LSNocilla sharedInstance] stop];
    });
    afterEach(^{
        [[LSNocilla sharedInstance] clearStubs];
    });

    it(@"return false if status 404", ^{
        __block BOOL result;
        ServerConnection *serverConnection = [[ServerConnection alloc] init];
        serverConnection.url = @"/questions";
        serverConnection.requestType = @"POST";
        serverConnection.params = @{};
        stubRequest(@"POST", @"http://localhost:3000/api/v1/questions").
        andReturn(404).
        withHeaders(@{@"Content-Type": @"application/json"});

        [serverConnection startWithParams:^(id data, BOOL success){
            result = success;
            
        }];
        [[expectFutureValue(theValue(result)) shouldEventually] beFalse];
    });
    
});
SPEC_END
