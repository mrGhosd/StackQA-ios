//
//  AnswersViewController.m
//  StackQA
//
//  Created by vsokoltsov on 23.03.15.
//  Copyright (c) 2015 vsokoltsov. All rights reserved.
//

#import "AnswersViewController.h"
#import "Api.h"
#import "AnswerTableViewCell.h"
#import <MBProgressHUD.h>

@interface AnswersViewController (){
    int selectedIndex;
    Api *api;
    float currentCellHeight;
    NSManagedObjectContext *localContext;
    NSMutableArray *answersList;
}

@end

@implementation AnswersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    selectedIndex = -1;
    self.sendButton.layer.cornerRadius = 5;
    self.settingsButton.layer.cornerRadius = 5;
    [self setActionViewBorder];
    [self setActionViewTextBorder];
    self.tableView.delegate = self;
    [self loadAnswersList];
    
    // Do any additional setup after loading the view.
}

- (void) loadAnswersList{
    api = [Api sharedManager];
    [MBProgressHUD showHUDAddedTo:self.view
                         animated:YES];
    [api getData:[NSString stringWithFormat:@"/questions/%@/answers", self.question.object_id ]
     andComplition:^(id data, BOOL success){
         if(success){
             [self parseAnswerData:data];
         } else {
             
         }
     }];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
//        [self.tableView reloadData];
}
- (void)keyboardWillShow:(NSNotification*)notification {
    /*[self.actionView addConstraint:[NSLayoutConstraint
                                 constraintWithItem:self.actionView
                                 attribute:NSLayoutAttributeBottom
                                 relatedBy:NSLayoutRelationEqual
                                 toItem:self.view
                                 attribute:NSLayoutAttributeBottom
                                 multiplier:0.5
                                 constant:500.0]];*/
//    id keyboardFrameBegin = [notification valueForKey:@"UIKeyboardFrameEndUserInfoKey"];
    NSDictionary *keyboardValues = [notification userInfo];
    id keyboardSize = keyboardValues[@"UIKeyboardFrameEndUserInfoKey"];
    CGRect keyboardFrame = [keyboardSize CGRectValue];
    int orientation = (int)[[UIDevice currentDevice] orientation];
    float textViewConstraint;
    switch (orientation) {
        case 1:
            textViewConstraint = keyboardFrame.size.height;
            break;
            
        case 3:
            textViewConstraint = keyboardFrame.size.width;
            break;
            
        case 4:
            textViewConstraint = keyboardFrame.size.width;
            break;
        
        default:
            textViewConstraint = keyboardFrame.size.height;
            break;
    }
//    [self.tableView addConstraint:[NSLayoutConstraint constraintWithItem:self.actionView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.tableView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:textViewConstraint + 100.0]];
    self.tableViewBottom.constant = textViewConstraint + self.actionView.frame.size.height;
    self.textViewBottom.constant = textViewConstraint;
}
- (void) keyboardWillHide:(NSNotification *) notification{
    self.textViewBottom.constant = 0.0;
    self.tableViewBottom.constant = self.actionView.frame.size.height;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void) parseAnswerData:(id) data{
    answersList = data[@"answers"];
    [self.tableView reloadData];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    [self.tableView reloadData];

}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if(selectedIndex == indexPath.row){
        selectedIndex = -1;
        currentCellHeight = 30.0;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        return;
    }
    
    if(selectedIndex != -1){
        NSIndexPath *prevPath = [NSIndexPath indexPathForRow:selectedIndex inSection:0];
        selectedIndex = indexPath.row;
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:prevPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    selectedIndex = indexPath.row;
    [self changeAnswerTextHeightAt:indexPath];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) changeAnswerTextHeightAt:(NSIndexPath *)path{
    CGSize size = [answersList[path.row][@"text"] sizeWithAttributes:nil];
    currentCellHeight = size.width / 10;
    [self.tableView cellForRowAtIndexPath:path];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *answerItem = [answersList objectAtIndex:indexPath.row];
    static NSString *CellIdentifier = @"answerCell";
    AnswerTableViewCell *cell = (AnswerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell.answerText loadHTMLString: answerItem[@"text"] baseURL:nil];
    cell.userName.text = [NSString stringWithFormat:@"%@", answerItem[@"user_name"]];
    cell.answerRate.text = [NSString stringWithFormat:@"%@", answerItem[@"rate"]];
    if(currentCellHeight){
        cell.answerTextHeight.constant = currentCellHeight;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [answersList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(selectedIndex == indexPath.row){
        return currentCellHeight;
    } else {
        return 100;
    }
    
}
- (void) setActionViewBorder{
    CGSize mainViewSize = self.actionView.frame.size;
    CGFloat borderWidth = 1;
    UIColor *borderColor = [UIColor lightGrayColor];
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mainViewSize.width, borderWidth)];
    topView.opaque = YES;
    topView.backgroundColor = borderColor;
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.actionView addSubview:topView];
}


- (void) setActionViewTextBorder{
    [self.actionViewText.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [self.actionViewText.layer setBorderWidth:2.0];
    
    //The rounded corner part, where you specify your view's corner radius:
    self.actionViewText.layer.cornerRadius = 5;
    self.actionViewText.clipsToBounds = YES;
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
- (IBAction)createAnswer:(id)sender {
}
- (IBAction)showSettings:(id)sender {
}
@end
