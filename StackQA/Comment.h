//
//  Comment.h
//  
//
//  Created by vsokoltsov on 04.05.15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Comment : NSManagedObject

@property (nonatomic, retain) NSNumber * object_id;
@property (nonatomic, retain) NSString * commentable_id;
@property (nonatomic, retain) NSNumber * commentable_type;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSNumber * user_id;

@end
