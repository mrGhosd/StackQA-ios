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
#import <Kiwi.h>
#import "QuestionsViewController.h"
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
});
SPEC_END