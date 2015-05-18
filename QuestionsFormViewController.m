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
#import "ServerError.h"
#import <MBProgressHUD/MBProgressHUD.h>
@interface QuestionsFormViewController (){
    AuthorizationManager *auth;
    NSMutableArray *categories;
    NSDictionary *selectedCategory;
    UIPickerView *picker;
    ServerError *serverError;
    NSArray *importantFields;
}

@end

@implementation QuestionsFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    importantFields = @[self.questionTitle, self.questionText, self.questionCategory];
    auth = [AuthorizationManager sharedInstance];
    [self uploadCategoriesList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) uploadCategoriesList{
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [[Api sharedManager] getData:@"/categories" andComplition:^(id data, BOOL success){
        if(success){
            [self parseCategories:data];
        } else {
        
        }
    }];
}

- (void) parseCategories:(id)data{
    categories = [NSArray arrayWithArray:data[@"categories"]];
    [self initViewData];
}

- (void) initViewData{
    if(self.question){
        self.questionTitle.text = self.question.title;
        self.questionText.text = self.question.text;
        self.questionTags.text = self.question.tags;
        self.questionCategory.text = [self getCategoryFromMainList];
    }
    [self setupPickerView];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
}

- (void) setupPickerView{
    picker = [[UIPickerView alloc] init];
    picker.delegate = self;
    picker.dataSource = self;
    self.questionCategory.inputView = picker;
}
- (NSString *) getCategoryFromMainList{
    NSString *title;
    for(NSDictionary *category in categories){
        if([self.question.categoryId isEqualToNumber:category[@"id"]]){
            title = category[@"title"];
            selectedCategory = category;
        } else {
            selectedCategory = @{@"id": @""};
        }
    }
    return title;
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
    NSArray *importantFields = @[self.questionTitle, self.questionText, self.questionCategory];
    for(UITextField *field in importantFields){
        field.layer.borderWidth = 1.0f;
        field.layer.borderColor = [[UIColor clearColor] CGColor];
    }

    NSString *url;
    NSString *type;
    if(self.question){
        url = [NSString stringWithFormat:@"/questions/%@", self.question.objectId];
        type = @"PUT";
    } else {
        url = @"/questions";
        type = @"POST";
    }
    if([self.questionTitle.text isEqualToString:@""] || [self.questionText.text isEqualToString:@""] || [self.questionCategory.text isEqualToString:@""]){
        [self displayErrors];
    } else {
        [self sendQuestionToServerWithURL:url andType:type];
    }
}
- (void) displayErrors{
    NSArray *importantFields = @[self.questionTitle, self.questionText, self.questionCategory];
    for(UITextField *field in importantFields){
        if([field.text isEqualToString:@""]){
            field.placeholder = @"Не может быть пустым";
            field.layer.borderWidth = 1.0f;
            field.layer.borderColor = [[UIColor redColor] CGColor];
        }
    }
}
- (void) sendQuestionToServerWithURL:(NSString *) url andType: (NSString *) type{
        NSMutableDictionary *questionParams =[NSMutableDictionary dictionaryWithDictionary: @{@"title": self.questionTitle.text, @"text": self.questionText.text, @"user_id": auth.currentUser.objectId, @"category_id": selectedCategory[@"id"], @"tag_list": self.questionTags.text }];
    [[Api sharedManager] sendDataToURL:url parameters:@{@"question": questionParams} requestType:type
                         andComplition:^(id data, BOOL success){
        if(success){
            if(self.question){
                [self.question update:data];
            } else {
                Question *question = [[Question alloc] initWithParams:data];
                self.question = question;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
        } else{
            serverError = [[ServerError alloc] initWithData:data];
            serverError.delegate = self;
            [serverError handle];
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
- (void) handleServerFormErrorWithError: (id) error{
    
}
- (IBAction)hideForm:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
