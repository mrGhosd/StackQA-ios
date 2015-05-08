//
//  CategoriesViewController.m
//  StackQA
//
//  Created by vsokoltsov on 08.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "CategoriesViewController.h"
#import "SWRevealViewController.h"
#import "CategoryTableViewCell.h"
#import <CoreData+MagicalRecord.h>
#import "Api.h"
#import "SQACategory.h"

@interface CategoriesViewController (){
    NSMutableArray *categoriesArray;
}

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    categoriesArray = [NSMutableArray new];
    [self defineNavigationPanel];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) defineNavigationPanel{
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController ){
        [self.sidebarButton setTarget: self.revealViewController];
        [self.sidebarButton setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
        revealViewController.rightViewController = nil;
    }
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self loadCategories];
}

- (void) loadCategories{
    [[Api sharedManager] sendDataToURL:@"/categories" parameters:@{} requestType:@"GET" andComplition:^(id data, BOOL success){
        if(success){
            [self parseCategoriesData:data];
        } else {
            
        }
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (void) parseCategoriesData:(id) data{
    [SQACategory sync:data[@"categories"]];
    categoriesArray = [NSMutableArray arrayWithArray:[SQACategory MR_findAll]];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return categoriesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"categoryCell";
    SQACategory *categoryItem = categoriesArray[indexPath.row];
    CategoryTableViewCell *cell = (CategoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.imageView.image = [categoryItem categoryImage];
    cell.textLabel.text = categoryItem.title;
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
