//
//  SQACategory.m
//  StackQA
//
//  Created by vsokoltsov on 15.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "SQACategory.h"
#import <CoreData+MagicalRecord.h>
#import "Question.h"


@implementation SQACategory

@dynamic title;
@dynamic desc;
@dynamic image_url;
@dynamic questions;

+ (void) sync: (NSArray *) params{
    NSMutableArray *serverObjects = [NSMutableArray new];
    //Разбиваем пришедшие с сервера вопросы по id
    [params enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        [serverObjects addObject:object[@"id"]];
    }];
    
    //Находим вопросы, которых нет на сервере, но есть на устройстве, и удаляем их
    NSPredicate *commentFilter = [NSPredicate predicateWithFormat:@"NOT (object_id IN %@)", serverObjects];
    NSArray *deletedComments = [SQACategory MR_findAllWithPredicate:commentFilter];
    for(SQACategory *category in deletedComments){
        [category MR_deleteEntity];
    }
    
    //Создаем массив с id на устройстве и добавляем туда значения id всех вопросов
    NSMutableArray *deviceObjects = [NSMutableArray new];
    NSMutableArray *categoriesList = [SQACategory MR_findAll];
    [categoriesList enumerateObjectsUsingBlock:^(SQACategory *object, NSUInteger index, BOOL *stop){
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
        SQACategory *category = [self defineCategoryWithId:params[@"id"] andContext:localContext];
        [category setParams:params];
        [localContext MR_save];
    }];
}
+ (SQACategory *) defineCategoryWithId: (id) object_id andContext: (NSManagedObjectContext *) context{
    SQACategory *com;
    SQACategory *current_c = [SQACategory MR_findFirstByAttribute:@"object_id" withValue:object_id];
    if(current_c){
        com = current_c;
    } else {
        com = [SQACategory MR_createInContext:context];
    }
    return com;
}

- (void) setParams:(NSDictionary *)params{
    self.object_id = params[@"id"];
    self.title = params[@"title"];
    self.desc = params[@"description"];
    self.image_url = params[@"image"][@"url"];
}

- (UIImage *) categoryImage{
    UIImage *img  =  [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self fullUrlToUserImage]]]];
    return img;
}
- (NSString *) fullUrlToUserImage{
    NSString *url = [NSString stringWithFormat:@"http://localhost:3000%@", self.image_url];
    return url;
}
- (NSMutableArray *) questionsList{
    __block NSMutableArray *questions;
//    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContexnt){
//        questions = [Question MR_findByAttribute:@"category_id" withValue:self.object_id inContext:localContexnt];
//    }];
    questions = [Question MR_findByAttribute:@"category_id" withValue:self.object_id];
    return questions;
}

@end
