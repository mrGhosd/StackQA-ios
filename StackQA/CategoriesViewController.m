//
//  CategoriesViewController.m
//  StackQA
//
//  Created by vsokoltsov on 08.05.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "CategoriesViewController.h"
#import "QuestionsViewController.h"
#import "CategoryDetailViewController.h"
#import "SWRevealViewController.h"
#import "CategoryTableViewCell.h"
#import <CoreData+MagicalRecord.h>
#import "Api.h"
#import "SCategory.h"
#import <UIScrollView+InfiniteScroll.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface CategoriesViewController (){
    NSMutableArray *categoriesArray;
    SCategory *selectedCategory;
    NSNumber *pageNumber;
}

@end

@implementation CategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    pageNumber = @1;
    categoriesArray = [NSMutableArray new];
    [self defineNavigationPanel];
    self.tableView.infiniteScrollIndicatorStyle = UIActivityIndicatorViewStyleWhite;
    [self.tableView addInfiniteScrollWithHandler:^(UITableView* tableView) {
        pageNumber = [NSNumber numberWithInteger:[pageNumber integerValue] + 1];
        [self loadCategories];
        [tableView finishInfiniteScroll];
    }];
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
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [[Api sharedManager] sendDataToURL:@"/categories" parameters:@{@"page": pageNumber} requestType:@"GET" andComplition:^(id data, BOOL success){
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
    NSArray *answers = data[@"categories"];
    if(data[@"categories"] != [NSNull null]){
        for(NSMutableDictionary *serverCategory in answers){
            SCategory *category = [[SCategory alloc] initWithParams:serverCategory];
            [categoriesArray addObject:category];
        }
        [self.tableView reloadData];
    }
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return categoriesArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"categoryCell";
    SCategory *categoryItem = categoriesArray[indexPath.row];
    CategoryTableViewCell *cell = (CategoryTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell.imageView.image = [categoryItem categoryImage];
    cell.textLabel.text = categoryItem.title;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedCategory = categoriesArray[indexPath.row];
    [self performSegueWithIdentifier:@"categoryQuestions" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"categoryQuestions"]){
        QuestionsViewController *view = segue.destinationViewController;
        view.category = selectedCategory;
    }
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
