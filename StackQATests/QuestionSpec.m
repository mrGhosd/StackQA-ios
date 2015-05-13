//
//  QuestionSpec.m
//  StackQA
//
//  Created by vsokoltsov on 13.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Specta/Specta.h>
#import "Question.h"
#import "Api.h"
#import "QuestionsViewController.h"
#import <Expecta/Expecta.h>
//#import "RatingDelegate.h"
//#define MOCKITO_SHORTHAND
//#import <OCMockito/OCMockito.h>


SpecBegin(QuestionSpec)
describe(@"Question model class", ^{
    NSDictionary *questionParamsHash = @{@"id": @1, @"title": @"TestTitle",
    @"text": @"TestText", @"category_id": @1, @"tag_list": @"First, second, third"};
    
    __block NSMutableDictionary *questionParams = [NSDictionary dictionaryWithDictionary:questionParamsHash];
    
    describe(@"creation of class instance", ^{
        it(@"create an question with parameters", ^{
            Question *question = [[Question alloc] initWithParams:questionParams];
            expect(question.objectId).to.equal(questionParams[@"id"]);
            expect(question.title).to.equal(questionParams[@"title"]);
            expect(question.text).to.equal(questionParams[@"text"]);
            expect(question.categoryId).to.equal(questionParams[@"category_id"]);
            expect(question.tags).to.equal(questionParams[@"tag_list"]);
        });
    
        it(@"create an empty question if it was created without params", ^{
            Question *question = [[Question alloc] init];
            expect(question.objectId).to.equal(nil);
            expect(question.title).to.equal(nil);
            expect(question.text).to.equal(nil);
            expect(question.categoryId).to.equal(nil);
            expect(question.tags).to.equal(nil);
        });
    });

    describe(@"update", ^{
        it(@"set parameters for question instance", ^{
            Question *question = [[Question alloc] init];
            expect(question.objectId).to.equal(nil);
        
            [question update:questionParams];
            expect(question.objectId).to.equal(questionParams[@"id"]);
        });
    });
    
    describe(@"#breakTagsLine", ^{
        Question *question = [[Question alloc] initWithParams:questionParams];
        
        it(@"return an array of splitted tags", ^{
            expect([question breakTagsLine]).to.equal(@[@"First", @"second", @"third"]);
        });
        
        it(@"return nil", ^{
            question.tags = nil;
            expect([question breakTagsLine]).to.equal(nil);
        });
    });
    
    

    
    
    
});
SpecEnd


