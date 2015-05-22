//
//  CommentSpec.m
//  StackQA
//
//  Created by vsokoltsov on 22.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <Kiwi.h>
#import "Answer.h"
#import "Question.h"
#import "Comment.h"
#import "User.h"
#import "CommentsListViewController.h"
#import "CommentDetailViewController.h"
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>
#import <OHHTTPStubs.h>
#import <OHHTTPStubsResponse.h>

SPEC_BEGIN(CommentSpec)
//describe(@"Comment instance attributes (initWithParams)", ^{
//
//});
__block Question *question;
__block Answer *answer;
__block Comment *comment;
__block User *user;
__block NSDictionary *questionParamsHash = @{@"id": @1, @"title": @"TestTitle",
                                     @"text": @"TestText", @"category_id": @1, @"tag_list": @"First, second, third"};

describe(@"#create", ^{
    context(@"parent is question", ^{
        question = [[Question alloc] initWithParams:questionParamsHash];
        user = [[User alloc] init];
        user.objectId = @1;
        CommentsListViewController *viewController = [[CommentsListViewController alloc] init];
        
        it(@"successfully create comment", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@{@"quesiton_id": question.objectId} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            
            Comment *comment = [[Comment alloc] init];
            comment.commentDelegate = viewController;
            
            [comment create:@{@"question_id": question.objectId, @"user_id": user.objectId, @"text": @"CommentText"}];

            [[[viewController shouldEventually] receive] createCallbackWithParams: @{@"quesiton_id": question.objectId}  andSuccess:YES];
        });
    });
    
    context(@"parent is answer", ^{
        question = [[Question alloc] initWithParams:questionParamsHash];
        __block NSDictionary *answerParamsHAsh = @{@"id": @1, @"text": @"AnswerText", @"question_id": @"1"};
        answer = [[Answer alloc] initWithParams:answerParamsHAsh];
        user = [[User alloc] init];
        user.objectId = @1;
        CommentsListViewController *viewController = [[CommentsListViewController alloc] init];
        
        it(@"successfully create comment", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:@{@"quesiton_id": question.objectId, @"answer_id": answer.objectId} statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            
            Comment *comment = [[Comment alloc] init];
            comment.commentDelegate = viewController;
            
            [comment create:@{@"question_id": question.objectId, @"user_id": user.objectId, @"text": @"CommentText"}];
            
            [[[viewController shouldEventually] receive] createCallbackWithParams: @{@"quesiton_id": question.objectId, @"answer_id": answer.objectId}  andSuccess:YES];
        });
    });
});

describe(@"(void) update: (NSDictionary *) params", ^{
    context(@"parent is question", ^{
        question = [[Question alloc] initWithParams:questionParamsHash];
        __block NSDictionary *answerParamsHash = @{@"id": @1, @"text": @"AnswerText", @"question_id": @"1"};
        answer = [[Answer alloc] initWithParams:answerParamsHash];
        __block NSDictionary *commentsParamsHash = @{@"id": @1, @"text": @"CommentText", @"question_id": question.objectId};
        user = [[User alloc] init];
        user.objectId = @1;
        CommentDetailViewController *viewController = [[CommentDetailViewController alloc] init];
        
        it(@"successfully create comment", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:commentsParamsHash statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            
            Comment *comment = [[Comment alloc] init];
            comment.commentDelegate = viewController;
            
            [comment update:commentsParamsHash];
            
            [[[viewController shouldEventually] receive] updateWithParams:commentsParamsHash andSuccess:YES];
        });
    });
    context(@"parent is answer", ^{
        question = [[Question alloc] initWithParams:questionParamsHash];
        __block NSDictionary *answerParamsHash = @{@"id": @1, @"text": @"AnswerText", @"question_id": @"1"};
        answer = [[Answer alloc] initWithParams:answerParamsHash];
        __block NSDictionary *commentsParamsHash = @{@"id": @1, @"text": @"CommentText", @"question_id": question.objectId, @"answer_id": answer.objectId};
        user = [[User alloc] init];
        user.objectId = @1;
        CommentDetailViewController *viewController = [[CommentDetailViewController alloc] init];
        
        it(@"successfully create comment", ^{
            [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
                return YES;
            } withStubResponse:^(NSURLRequest *request){
                return [OHHTTPStubsResponse responseWithJSONObject:commentsParamsHash statusCode:200 headers:@{@"Content-Type": @"application/json"}];
            }];
            
            Comment *comment = [[Comment alloc] init];
            comment.commentDelegate = viewController;
            
            [comment update:commentsParamsHash];
            
            [[[viewController shouldEventually] receive] updateWithParams:commentsParamsHash andSuccess:YES];
        });
    });
});
describe(@"(void) destroyWithPath:(NSIndexPath *) path", ^{
    question = [[Question alloc] initWithParams:questionParamsHash];
    __block NSDictionary *commentsParamsHash = @{@"id": @1, @"text": @"CommentText", @"question_id": question.objectId};
    user = [[User alloc] init];
    user.objectId = @1;
    
    CommentsListViewController *viewController = [[CommentsListViewController alloc] init];
        
    it(@"successfully create comment", ^{
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:commentsParamsHash statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        NSIndexPath *path = [NSIndexPath new];
        Comment *comment = [[Comment alloc] init];
        comment.commentDelegate = viewController;
            
        [comment destroyWithPath:path];
        
        [[[viewController shouldEventually] receive] destroyCallback:YES path:path];
    });
});
describe(@"(id) getParentEntity", ^{
    context(@"parent is question", ^{
        question = [[Question alloc] initWithParams:questionParamsHash];
        NSDictionary *commentsParamsHash = @{@"id": @1, @"text": @"CommentText", @"question_id": question.objectId};
        Comment *comment = [[Comment alloc] initWithParams:commentsParamsHash];
        [[[comment getParentEntity] should] equal:question];
    });
    
    context(@"parent is answer", ^{
        question = [[Question alloc] initWithParams:questionParamsHash];
        NSDictionary *answerParamsHash = @{@"id": @1, @"text": @"AnswerText", @"question_id": question.objectId};
        answer = [[Answer alloc] initWithParams:answerParamsHash];
        NSDictionary *commentsParamsHash = @{@"id": @1, @"text": @"CommentText", @"question_id": question.objectId, @"answer_id": answer.objectId};
        Comment *comment = [[Comment alloc] initWithParams:commentsParamsHash];
        [[[comment getParentEntity] should] equal:answer];
    });
});

describe(@"(void) complainToCommentWithPath: (NSIndexPath *) path", ^{
    
    context(@"success ", ^{
        question = [[Question alloc] initWithParams:questionParamsHash];
        __block NSDictionary *commentsParamsHash = @{@"id": @1, @"text": @"CommentText", @"question_id": question.objectId};
        user = [[User alloc] init];
        user.objectId = @1;
        
        CommentsListViewController *viewController = [[CommentsListViewController alloc] init];
        
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:commentsParamsHash statusCode:200 headers:@{@"Content-Type": @"application/json"}];
        }];
        
        NSIndexPath *path = [NSIndexPath new];
        Comment *comment = [[Comment alloc] initWithParams:commentsParamsHash];
        comment.commentDelegate = viewController;
        
        [comment complainToCommentWithPath:path];
        
        [[[viewController shouldEventually] receive] complaintToCommentWithSuccess:YES andIndexPath:path];
    });
    
    context(@"failure", ^{
        question = [[Question alloc] initWithParams:questionParamsHash];
        __block NSDictionary *commentsParamsHash = @{@"id": @1, @"text": @"CommentText", @"question_id": question.objectId};
        user = [[User alloc] init];
        user.objectId = @1;
        
        CommentsListViewController *viewController = [[CommentsListViewController alloc] init];
        
        [OHHTTPStubs stubRequestsPassingTest:^(NSURLRequest *request){
            return YES;
        } withStubResponse:^(NSURLRequest *request){
            return [OHHTTPStubsResponse responseWithJSONObject:commentsParamsHash statusCode:404 headers:@{@"Content-Type": @"application/json"}];
        }];
        
        NSIndexPath *path = [NSIndexPath new];
        Comment *comment = [[Comment alloc] initWithParams:commentsParamsHash];
        comment.commentDelegate = viewController;
        
        [comment complainToCommentWithPath:path];
        
        [[[viewController shouldEventually] receive] complaintToCommentWithSuccess:NO andIndexPath:path];
    });
});
SPEC_END