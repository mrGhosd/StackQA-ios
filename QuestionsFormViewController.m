//
//  QuestionsFormViewController.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionsFormViewController.h"
#import <CoreData+MagicalRecord.h>
@interface QuestionsFormViewController ()

@end

@implementation QuestionsFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if(self.question){
        self.questionTitle.text = self.question.title;
        self.questionText.text = self.question.text;
    }
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveQuestion:(id)sender {
    NSManagedObjectContext *localContext    = [NSManagedObjectContext MR_contextForCurrentThread];
    if (self.question) {
        Question *question = [Question MR_findFirstByAttribute:@"title" withValue:self.question.title inContext:localContext];
        question.title = self.questionTitle.text;
        question.text = self.questionText.text;
    }
    else {
        
        Question *question = [Question MR_createInContext:localContext];
        if([self.questionTitle.text isEqual: @""] || ![self.questionText.text  isEqual: @""]){
            question.title = self.questionTitle.text;
            question.created_at = [NSDate date];
            question.text = self.questionText.text;
        } else {
            NSLog(@"Error!");
        }
    }
    [localContext MR_save];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)hideForm:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
