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
@dynamic is_helpfull;
@dynamic created_at;
@dynamic updated_at;
@dynamic question;
@dynamic user_name;
@dynamic rate;
@dynamic question_id;
@dynamic comments_count;

+ (void) sync: (NSArray *) params{
    NSMutableArray *serverObjects = [NSMutableArray new];
    //Разбиваем пришедшие с сервера вопросы по id
    [params enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        [serverObjects addObject:object[@"id"]];
    }];
    
    //Находим вопросы, которых нет на сервере, но есть на устройстве, и удаляем их
    NSPredicate *answerFilter = [NSPredicate predicateWithFormat:@"NOT (object_id IN %@)", serverObjects];
    NSArray *deletedQuestions = [Answer MR_findAllWithPredicate:answerFilter];
    for(Answer *answer in deletedQuestions){
        [answer MR_deleteEntity];
    }
    
    //Создаем массив с id на устройстве и добавляем туда значения id всех вопросов
    NSMutableArray *deviceObjects = [NSMutableArray new];
    NSMutableArray *questionsList = [Answer MR_findAll];
    [questionsList enumerateObjectsUsingBlock:^(Answer *object, NSUInteger index, BOOL *stop){
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
//    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
//        NSArray *serverObjects = [params copy];
//        NSMutableArray *deviceObjects = [Answer MR_findAll];
//        for(NSDictionary *serverAnswer in serverObjects){
//            [Answer create:serverAnswer];
//            NSArray *deviceAnswer = [Answer MR_findByAttribute:@"object_id" withValue:serverAnswer[@"id"] inContext:localContext];
//            if([deviceAnswer count] > 1){
//                for(Answer *ans in deviceAnswer){
//                    [ans MR_deleteInContext:localContext];
//                }
//            }
//            [Answer create:serverAnswer inContext:localContext];
//        }
//    }];
}
+ (void) deleteAnswersFromDevice: (NSArray *) answers{
    NSMutableArray *serverObjects = [NSMutableArray new];
    //Разбиваем пришедшие с сервера вопросы по id
    [answers enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        [serverObjects addObject:object[@"id"]];
    }];
    
    //Находим вопросы, которых нет на сервере, но есть на устройстве, и удаляем их
    NSPredicate *questionFilter = [NSPredicate predicateWithFormat:@"NOT (object_id IN %@)", serverObjects];
//    NSArray *deletedQuestions = [Question MR_findAllWithPredicate:questionFilter];
//    for(Answer *answer in deletedQuestions){
//        [[answer MR_inThreadContext] destroy];
//    }
}

#pragma mark - Question
- (Question *) getAnswerQuestion{
    __block Question *question;
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *context){
//        question = [Question MR_findFirstByAttribute:@"object_id" withValue:self.question_id inContext:context];
    }];
    return question;
}

#pragma mark - User
+ (void) setAnswersToUser: (User *) user{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
//        NSArray *questions = [Question MR_findAllInContext:localContext];
//        for(Question *q in questions){
//            NSArray *arr = [Answer MR_findByAttribute:@"question_id" withValue:q.object_id inContext:localContext];
//            [q setValue:[NSMutableSet setWithArray:arr] forKey:@"answers"];
//            [localContext MR_save];
//        }
//        NSArray *answersList = [Answer MR_findAllInContext:localContext];
//        NSArray *answers = [Answer MR_findByAttribute:@"user_id" withValue:user.object_id inContext:localContext];
//        [[user MR_inContext:localContext] setValue:[NSMutableSet setWithArray:answers] forKey:@"answers"];
//        [localContext MR_save];
    }];
}
+ (void) setAnswersToUser: (User *) user inContext: (NSManagedObjectContext *) localContext{
//    NSArray *questions = [Question MR_findAllInContext:localContext];
//    for(Question *q in questions){
//        NSArray *arr = [Answer MR_findByAttribute:@"question_id" withValue:q.object_id inContext:localContext];
//        [q setValue:[NSMutableSet setWithArray:arr] forKey:@"answers"];
//        [localContext MR_save];
//    }
//    NSArray *answersList = [Answer MR_findAllInContext:localContext];
//    NSArray *answers = [Answer MR_findByAttribute:@"user_id" withValue:user.object_id inContext:localContext];
//    [[user MR_inContext:localContext] setValue:[NSMutableSet setWithArray:answers] forKey:@"answers"];
//    [localContext MR_save];
}
#pragma mark - CRUD
+ (void) create: (NSDictionary *) params{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        Answer *answer = [self defineAnswerWithId:params[@"id"] andContext:localContext];
        [self setParams:params toAnswer:answer];
        [localContext MR_save];
    }];
}
+ (void) create: (NSDictionary *) params inContext:(NSManagedObjectContext *) localContext{
    Answer *answer = [self defineAnswerWithId:params[@"id"] andContext:localContext];
    [self setParams:params toAnswer:answer];
    [localContext MR_save];
}

+ (Question *) defineAnswerWithId: (id) object_id andContext: (NSManagedObjectContext *) context{
    Answer *a;
    Answer *current_a = [Answer MR_findFirstByAttribute:@"object_id" withValue:object_id];
    if(current_a){
        a = current_a;
    } else {
        a = [Answer MR_createInContext:context];
    }
    return a;
}

+ (void) setParams:(NSDictionary *)params toAnswer:(Answer *) answer{
    answer.object_id = params[@"id"];
    answer.user_id = params[@"user_id"];
    answer.user_name = params[@"user_name"];
    answer.question_id = params[@"question_id"];
//    answer.created_at = [Question correctConvertOfDate:params[@"created_at"]];
    answer.text = params[@"text"];
    answer.rate = params[@"rate"];
    answer.comments_count = params[@"comments_count"];
    answer.is_helpfull = (BOOL)[params[@"is_helpfull"] boolValue];
    
}
- (void) update: (NSDictionary *)params{
    NSArray *answer = [Answer MR_findByAttribute:@"object_id" withValue:self.object_id];
    if([answer count] > 1){
        for(Answer *ans in answer){
            [ans MR_deleteEntity];
        }
        [Answer create:params];
    } else {
        [Answer setParams:params toAnswer:self];
    }
}
- (void) destroy {
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext){
        [self MR_deleteEntity];
        [localContext MR_save];
    }];
}
//+ (NSArray *) answersForQuestion:(Question *)question{
//////    NSPredicate *answersFilter = [NSPredicate predicateWithFormat:@"question_id = %@", question.object_id];
////    NSArray *questionAnswers = [Answer MR_findAllWithPredicate:answersFilter];
////    return questionAnswers;
//}
@end
