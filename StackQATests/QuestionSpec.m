//
//  QuestionSpec.m
//  StackQA
//
//  Created by vsokoltsov on 13.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Question.h"
#import "Api.h"
#import "QuestionDelegate.h"
#import <Kiwi.h>
#import "QuestionDetailViewController.h"
#import "RatingDelegate.h"
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import <OHHTTPStubs.h>
#import <OHHTTPStubsResponse.h>

SPEC_BEGIN(QuestionSpec)
describe(@"Question model class", ^{
    
    NSDictionary *questionParamsHash = @{@"id": @1, @"title": @"TestTitle",
    @"text": @"TestText", @"category_id": @1, @"tag_list": @"First, second, third"};

    __block NSMutableDictionary *questionParams = [NSDictionary dictionaryWithDictionary:questionParamsHash];
    
    afterEach(^{
        [OHHTTPStubs removeAllStubs];
    });

    describe(@"creation of class instance", ^{
        it(@"create an question with parameters", ^{
            Question *question = [[Question alloc] initWithParams:questionParams];
            [[question.objectId should] equal:questionParams[@"id"]];
            [[question.title should] equal:questionParams[@"title"]];
            [[question.text should] equal:questionParams[@"text"]];
            [[question.categoryId should] equal:questionParams[@"category_id"]];
            [[question.tags should] equal:questionParams[@"tag_list"]];
        });

        it(@"create an empty question if it was created without params", ^{
            Question *question = [[Question alloc] init];
            [[question.objectId should] beNil];
            [[question.title should] beNil];
            [[question.text should] beNil];
            [[question.categoryId should] beNil];
            [[question.tags should] beNil];
        });
    });

    describe(@"update", ^{
        it(@"set parameters for question instance", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:questionParams statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            
            Question *question = [[Question alloc] init];
            [question update:questionParams];
            
            [[question.objectId should] equal:@1];
        });
    });

    describe(@"#breakTagsLine", ^{
        Question *question = [[Question alloc] initWithParams:questionParams];
        
        it(@"return an array of splitted tags", ^{
            [[[question breakTagsLine] should] equal:@[@"First", @"second", @"third"]];
        });
        
        it(@"return nil", ^{
            question.tags = nil;
            [[[question breakTagsLine] should] beNil];
        });
    });
    
    describe(@"#changeQuestionRate", ^{
        Question *question = [[Question alloc] initWithParams:questionParams];
        question.rate = @0;
        __block QuestionDetailViewController *viewController;
        
        it(@"increase questions rate", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@{@"rate": @1, @"action": @"plus", @"object_id": question.objectId} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            
            [question changeQuestionRate:@"plus"];
            
            [[expectFutureValue(question.rate) shouldEventually] equal:@1];
        });
        
        it(@"decrease questions rate", ^{
            question.rate = @2;
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@{@"rate": @1, @"action": @"minus", @"object_id": question.objectId} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            NSObject <RatingDelegate> *delegate = mockProtocol(@protocol(RatingDelegate));
            question.rateDelegate = delegate;
            
            [question changeQuestionRate:@"minus"];
            
            [[expectFutureValue(question.rate)shouldEventually] equal:@1];
            
        });
        
        it(@"call success callback", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@{@"rate": @1, @"action": @"plus", @"object_id": question.objectId} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            viewController = [[QuestionDetailViewController alloc] init];
            question.rateDelegate = viewController;
            
            [question changeQuestionRate:@"plus"];
            
            [[[viewController shouldEventually] receive] successRateCallbackWithData:@{@"rate": @1, @"action": @"plus", @"object_id": question.objectId}];
        });
    });
    
    describe(@"#destroy", ^{
        Question *question = [[Question alloc] initWithParams:questionParams];
        __block QuestionDetailViewController *viewController;
        it(@"successfully destroy question", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@{} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            viewController = [[QuestionDetailViewController alloc] init];
            question.questionDelegate = viewController;
            
            [question destroy];
            
            [[[viewController shouldEventually] receive] successDestroyCallback];
            
        });
    });
    
    describe(@"#complaintToQuestion", ^{
        Question *question = [[Question alloc] initWithParams:questionParams];
        __block QuestionDetailViewController *viewController;
        
        it(@"successfully complaint on question", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@{@"success": @"true"} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            
            viewController = [[QuestionDetailViewController alloc] init];
            question.questionDelegate = viewController;
            
            [question complaintToQuestion];
            
            [[[viewController shouldEventually] receive] complainToQuestionWithData:@{@"success": @"true"} andSuccess:YES];
        });
    });
});
SPEC_END