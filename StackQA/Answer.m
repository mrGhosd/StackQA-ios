//
//  Answer.m
//  StackQA
//
//  Created by vsokoltsov on 24.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "Answer.h"
#import "Question.h"


@implementation Answer

@dynamic object_id;
@dynamic user_id;
@dynamic text;
@dynamic is_helpful;
@dynamic created_at;
@dynamic updated_at;
@dynamic question;
@dynamic user_name;
@dynamic rate;

+ (void) sync: (NSArray *) params{
    NSMutableArray *serverObjects = [NSMutableArray new];
    //Разбиваем пришедшие с сервера вопросы по id
    [params enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        [serverObjects addObject:object[@"id"]];
    }];
    
    //Находим вопросы, которых нет на сервере, но есть на устройстве, и удаляем их
    NSPredicate *questionFilter = [NSPredicate predicateWithFormat:@"NOT (object_id IN %@)", serverObjects];
    NSArray *deletedQuestions = [Question MR_findAllWithPredicate:questionFilter];
    for(Question *question in deletedQuestions){
        [question MR_deleteEntity];
    }
    
    //Создаем массив с id на устройстве и добавляем туда значения id всех вопросов
    NSMutableArray *deviceObjects = [NSMutableArray new];
    NSMutableArray *questionsList = [Question MR_findAll];
    [questionsList enumerateObjectsUsingBlock:^(Question *object, NSUInteger index, BOOL *stop){
        [deviceObjects addObject:object.object_id];
    }];
    
    [deviceObjects enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        for(NSDictionary *attr in params){
            if((BOOL)[object isEqual:attr[@"id"]]){
                [self create:attr];
            }
        }
    }];
    
    //Удаляем из массива объектов с сервера id с устройства
    [serverObjects removeObjectsInArray:deviceObjects];
    
    
    //Создаем отсутствующие вопросы
    [serverObjects enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        for(NSDictionary *dict in params){
            if(dict[@"id"] == object){
                [self create:dict];
            }
        }
    }];
}

+ (void) create: (NSDictionary *) params{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        Question *question = [self defineQuestionWithId:params[@"id"] andContext:localContext];
        [self setParams:params toQuestion:question];
        [localContext MR_save];
    }];
}

+ (Question *) defineQuestionWithId: (id) object_id andContext: (NSManagedObjectContext *) context{
    Question *q;
    Question *current_q = [Question MR_findFirstByAttribute:@"object_id" withValue:object_id];
    if(current_q){
        q = current_q;
    } else {
        q = [Question MR_createInContext:context];
    }
    return q;
}

+ (void) setParams:(NSDictionary *)params toQuestion:(Question *) question{
    question.object_id = params[@"id"];
    question.user_id = params[@"user_id"];
    question.category_id = params[@"category_id"];
    question.rate = params[@"rate"];
    question.title = params[@"title"];
    question.created_at = [self correctConvertOfDate:params[@"created_at"]];
    question.answers_count = params[@"answers_count"];
    question.comments_count = params[@"comments_count"];
    question.tags = params[@"tag_list"];
    question.text = params[@"text"];
}
+ (void) setAnswerssForUser:(User *) user{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        NSPredicate *peopleFilter = [NSPredicate predicateWithFormat:@"user_id = %@", user.object_id];
        Answer *answers = [Answer MR_findAllWithPredicate:peopleFilter];
        [user setValue:[NSMutableSet setWithArray:answers] forKey:@"answers"];
        [localContext MR_save];
    }];
}

+ (void) setAnswersForQuestion:(Question *) question{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        NSPredicate *questionFilter = [NSPredicate predicateWithFormat:@"question_id = %@", question.object_id];
        Answer *questions = [Answer MR_findAllWithPredicate:questionFilter];
        [question setValue:[NSMutableSet setWithArray:questions] forKey:@"answers"];
        [localContext MR_save];
    }];
}

@end
