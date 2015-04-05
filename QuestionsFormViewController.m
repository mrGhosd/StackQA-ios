//
//  QuestionsFormViewController.m
//  StackQA
//
//  Created by vsokoltsov on 18.01.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "QuestionsFormViewController.h"
#import <CoreData+MagicalRecord.h>
#import "Api.h"
#import "AuthorizationManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface QuestionsFormViewController (){
    AuthorizationManager *auth;
    NSMutableArray *categories;
    NSDictionary *selectedCategory;
    UIPickerView *picker;
}

@end

@implementation QuestionsFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    auth = [AuthorizationManager sharedInstance];
    if(self.question){
        self.questionTitle.text = self.question.title;
        self.questionText.text = self.question.text;
    }
    picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    self.questionCategory.inputView = picker;
    [self uploadCategoriesList];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) uploadCategoriesList{
    [[Api sharedManager] getData:@"/categories" andComplition:^(id data, BOOL success){
        if(success){
            [self parseCategories:data];
        } else {
        
        }
    }];
}

- (void) parseCategories:(id)data{
    categories = [NSArray arrayWithArray:data[@"categories"]];
}
- (void) setupPickerView{
    picker = [[UIPickerView alloc] init];
    [picker setDelegate:self];
    [picker setDataSource:self];
//    picker.showsSelectionIndicator = YES;
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
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
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
    
    NSMutableDictionary *questionParams = @{@"title": self.questionTitle.text, @"text": self.questionText.text,
        @"user_id": auth.currentUser.object_id,
        @"category_id": selectedCategory[@"id"], @"tag_list": self.questionTags.text };
    [[Api sharedManager] sendDataToURL:@"/questions" parameters:@{@"question": questionParams} requestType:@"POST" andComplition:^(id data, BOOL success){
        if(success){
                [self dismissViewControllerAnimated:YES completion:nil];
        } else{
            
        }
    }];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component{
    return categories.count;
}
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    return categories[row][@"title"];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component{
    selectedCategory = [NSDictionary dictionaryWithDictionary:categories[row]];
    self.questionCategory.text = categories[row][@"title"];
}
- (IBAction)hideForm:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
