//
//  AnswerSpec.m
//  StackQA
//
//  Created by vsokoltsov on 19.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <XCTest/XCTest.h>
#import <Kiwi.h>
#import "Answer.h"
#import "Question.h"
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import <OHHTTPStubs.h>
#import <OHHTTPStubsResponse.h>
#import "AnswersViewController.h"
#import "AnswerDetailViewController.h"

SPEC_BEGIN(AnswerSpec)
__block Answer *answer;
__block Question *question;
NSDictionary *answerParamsHash = @{@"id": @1, @"question_id": @1,
                                     @"text": @"TestText", @"rate": @0, @"user_name": @"UserName",
                                     @"comments_count": @0, @"is_helpfull": @NO};

__block NSMutableDictionary *answerParams = [NSDictionary dictionaryWithDictionary:answerParamsHash];
__block AnswersViewController *viewController;

afterEach(^{
    [OHHTTPStubs removeAllStubs];
});


describe(@"#initWithParams", ^{
    it(@"define a new answer with specific parameters", ^{
        answer = [[Answer alloc] initWithParams:answerParams];
        [[answer.objectId should] equal:answerParams[@"id"]];
        [[answer.questionId should] equal:answerParams[@"question_id"]];
        [[answer.text should] equal:answerParams[@"text"]];
        [[answer.rate should] equal:answerParams[@"rate"]];
        [[answer.userName should] equal:answerParams[@"user_name"]];
        [[answer.commentsCount should] equal:answerParams[@"comments_count"]];
        [[theValue(answer.isHelpfull) should] beFalse];
    });
});

describe(@"#create", ^{
    it(@"successfully create a new answer", ^{
        answer = [[Answer alloc] init];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:answerParams statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        
        viewController = [[AnswersViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer create:answerParams];
        
        [[[viewController shouldEventually] receive] createCallbackWithParams:answerParams andSuccess:YES];
    });
});

describe(@"#update", ^{
    it(@"successfully update a answer", ^{
        answer = [[Answer alloc] init];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:answerParams statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        
        AnswerDetailViewController *viewController = [[AnswerDetailViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer update:answerParams];
        
        [[[viewController shouldEventually] receive] updateWithParams:answerParams andSuccess:YES];
    });
});

describe(@"destroyWithIndexPath", ^{
    it(@"successfully destroy answer", ^{
        answer = [[Answer alloc] init];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:answerParams statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        NSIndexPath *path = [NSIndexPath new];
        
        viewController = [[AnswersViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer destroyWithIndexPath:path];
        
        [[[viewController shouldEventually] receive] destroyCallback:YES path:path];
    });
    
    it(@"failed to destroy answer", ^{
        answer = [[Answer alloc] init];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:answerParams statusCode:400 headers:@{@"Content-Type": @"application/json"}];
        }];
        NSIndexPath *path = [NSIndexPath new];
        
        viewController = [[AnswersViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer destroyWithIndexPath:path];
        
        [[[viewController shouldEventually] receive] destroyCallback:NO path:path];
    });
});

describe(@"changeRateWithAction: (NSString *) action andIndexPAth: (NSIndexPath *) path", ^{
    it(@"successfully increase answers rate", ^{
        answer = [[Answer alloc] initWithParams:answerParams];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:@{@"rate": @1, @"action": @"plus", @"object_id": answer.objectId} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        NSIndexPath *path = [NSIndexPath new];
        
        viewController = [[AnswersViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer changeRateWithAction:@"plus" andIndexPAth:path];
        
        [[expectFutureValue(answer.rate) shouldEventually] equal:@1];
    });
    
    it(@"successfully decrease answers rate", ^{
        answer = [[Answer alloc] initWithParams:answerParams];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:@{@"rate": @-1, @"action": @"minus", @"object_id": answer.objectId} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        NSIndexPath *path = [NSIndexPath new];
        
        viewController = [[AnswersViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer changeRateWithAction:@"minus" andIndexPAth:path];
        
        [[expectFutureValue(answer.rate) shouldEventually] equal:@-1];
    });
});

describe(@"- (void) markAsHelpfullWithPath: (NSIndexPath *) path", ^{
    it(@"it successfully mark answer as helpfull", ^{
        answer = [[Answer alloc] initWithParams:answerParams];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:answerParams statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        NSIndexPath *path = [NSIndexPath new];
        
        viewController = [[AnswersViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer markAsHelpfullWithPath:path];
        
        [[[viewController shouldEventually] receive] markAsHelpfullCallbackWithParams:answerParams path:path andSuccess:YES];
    });
});

describe(@"- (void) complainToAnswerWithPath: (NSIndexPath *) path", ^{
    it(@"succesfully make complaint on answer", ^{
        answer = [[Answer alloc] initWithParams:answerParams];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:answerParams statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        NSIndexPath *path = [NSIndexPath new];
        
        viewController = [[AnswersViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer complainToAnswerWithPath:path];
        
        [[[viewController shouldEventually] receive] complaintToAnswerWithSuccess:YES andIndexPath:path];
    });
    
    it(@"failed in complain to answer", ^{
        answer = [[Answer alloc] initWithParams:answerParams];
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:answerParams statusCode:400 headers:@{@"Content-Type": @"application/json"}];
        }];
        NSIndexPath *path = [NSIndexPath new];
        
        viewController = [[AnswersViewController alloc] init];
        answer.answerDelegate = viewController;
        
        [answer complainToAnswerWithPath:path];
        
        [[[viewController shouldEventually] receive] complaintToAnswerWithSuccess:NO andIndexPath:path];
    });
});
SPEC_END