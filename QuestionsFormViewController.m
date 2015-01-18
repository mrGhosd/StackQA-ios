//
//  QuestionsFormViewController.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionsFormViewController.h"
#import <CoreData+MagicalRecord.h>
#import "Question.h"
#import "QuestionDetail.h"
@interface QuestionsFormViewController ()

@end

@implementation QuestionsFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    Question *question = [Question MR_createInContext:localContext];
    question.questionDetail = [QuestionDetail MR_createInContext:localContext];
    if(self.questionTitle.text != @"" || self.questionText.text != @""){
        question.title = self.questionTitle.text;
        question.created_at = [NSDate date];
        question.questionDetail.text = self.questionText.text;
        [localContext MR_save];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        NSLog(@"Error!");
    }
}

- (IBAction)hideForm:(id)sender {
}
@end
