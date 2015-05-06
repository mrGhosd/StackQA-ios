//
//  Comment.m
//  
//
//  Created by vsokoltsov on 04.05.15.
//
//

#import "Comment.h"
#import "Question.h"
#import "Answer.h"
#import <CoreData+MagicalRecord.h>

@implementation Comment{
    NSManagedObjectContext *localContext;
    id parentEntity;
}

@dynamic object_id;
@dynamic commentable_id;
@dynamic commentable_type;
@dynamic text;
@dynamic user_id;

+ (void) sync: (NSArray *) params{
    NSMutableArray *serverObjects = [NSMutableArray new];
    //Разбиваем пришедшие с сервера вопросы по id
    [params enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL *stop){
        [serverObjects addObject:object[@"id"]];
    }];
    
    //Находим вопросы, которых нет на сервере, но есть на устройстве, и удаляем их
    NSPredicate *commentFilter = [NSPredicate predicateWithFormat:@"NOT (object_id IN %@)", serverObjects];
    NSArray *deletedComments = [Comment MR_findAllWithPredicate:commentFilter];
    for(Comment *comment in deletedComments){
        [comment MR_deleteEntity];
    }
    
    //Создаем массив с id на устройстве и добавляем туда значения id всех вопросов
    NSMutableArray *deviceObjects = [NSMutableArray new];
    NSMutableArray *commentsList = [Comment MR_findAll];
    [commentsList enumerateObjectsUsingBlock:^(Comment *object, NSUInteger index, BOOL *stop){
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
        Comment *comment = [self defineCommentWithId:params[@"id"] andContext:localContext];
        [self setParams:params toComment:comment];
        [localContext MR_save];
    }];
}
+ (Comment *) defineCommentWithId: (id) object_id andContext: (NSManagedObjectContext *) context{
    Comment *com;
    Comment *current_c = [Comment MR_findFirstByAttribute:@"object_id" withValue:object_id];
    if(current_c){
        com = current_c;
    } else {
        com = [Comment MR_createInContext:context];
    }
    return com;
}

+ (void) setParams:(NSDictionary *)params toComment:(Comment *) answer{
    answer.object_id = params[@"id"];
    answer.user_id = params[@"user_id"];
    answer.commentable_type = params[@"commentable_type"];
    answer.commentable_id = params[@"commentable_id"];
    answer.text = params[@"text"];
    
    
}
+ (NSMutableArray *) commentsForCurrentEntity: (id) entity andID:(NSNumber *) objectID{
    NSMutableArray *comments;
    NSPredicate *commentPredicate = [NSPredicate predicateWithFormat:@"commentable_type = %@ AND commentable_id = %@", [NSString stringWithFormat:@"%@", [entity class] ], objectID];
    comments = [Comment MR_findAllWithPredicate:commentPredicate];
    return comments;
}
- (User *) getUserForComment{
    User *author = [User MR_findFirstByAttribute:@"object_id" withValue:self.user_id];
    return author;
}
@end