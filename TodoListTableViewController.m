//
//  TodoListTableViewController.m
//  Done3
//
//  Created by Bruno Parrinello on 1/20/14.
//  Copyright (c) 2014 Bruno Parrinello. All rights reserved.
//


#import "TodoListTableViewController.h"
#import "EditableCell.h"

#import <objc/runtime.h>
static char indexPathKey;
static NSString *todoItemsList = @"todoItemsList";

@interface TodoListTableViewController ()

- (IBAction)onClickAdd:(id)sender;
- (BOOL) textFieldShouldReturn:(UITextField*) textField;
- (void) saveListInDefaults:(id) todoList withKey:(NSString *)key;
- (IBAction)onTap:(id)sender;

@end

@implementation TodoListTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Done3!";
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Test with dummy data
        //NSMutableArray *listOfTodos = [[NSMutableArray alloc] initWithArray:@[@"Todo1", @"Todo2"]];
        //[defaults setObject:listOfTodos forKey:@"todoItemsList"];
        //[defaults synchronize];
        
        // Initialize the array
        self.todoItemsArray = [NSMutableArray array];
        self.todoItemsArray = [defaults objectForKey:todoItemsList];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    UINib *editableCellNib = [UINib nibWithNibName:@"EditableCell" bundle:nil];
    [self.tableView registerNib:editableCellNib forCellReuseIdentifier:@"EditableCell"];
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStylePlain target:self action:@selector(onClickAdd:)];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.todoItemsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   // Reuse cell or create one if none available.
    static NSString *CellIdentifier = @"EditableCell";
    EditableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[EditableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.todoItemTextField.text = [self.todoItemsArray objectAtIndex:indexPath.row];
    
    objc_setAssociatedObject(cell.todoItemTextField, &indexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    cell.todoItemTextField.delegate = self;
    
    // Disable editing of cells when not in editing mode
    //[cell.todoItemTextField setUserInteractionEnabled:NO];
    
     NSLog(@"cellForRowAtIndexPath - content is: %@", cell.todoItemTextField.text);
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Action when button + or Add is clicked on.
- (IBAction)onClickAdd:(id)sender {
    NSLog(@"Button Add has been clicked");
/*
    static NSString *CellIdentifier = @"EditableCell";
    NSIndexPath *indexPath = 0;
    EditableCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [self.todoItemsArray insertObject:cell.todoItemTextField.text atIndex:indexPath.row];
    objc_setAssociatedObject(cell.todoItemTextField, &indexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
  
*/
    [self.todoItemsArray insertObject:@"" atIndex:0];
    [self.tableView reloadData];
    NSIndexPath *currPlace = [NSIndexPath indexPathForRow:0 inSection:0] ;
    [self tableView:self.tableView didSelectRowAtIndexPath:currPlace];
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
        EditableCell *cell = (EditableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        [cell.todoItemTextField setUserInteractionEnabled:YES];
        [cell.todoItemTextField becomeFirstResponder];

}

- (BOOL) textFieldShouldReturn :(UITextField*) textField {
    
    NSLog(@"textFieldShouldReturn");
    if (textField.text.length <= 0) {
        // Text is empty, nothing is added - removing empty object from array before it gets saved
        [self.todoItemsArray removeObjectAtIndex:0];
    } else {
        NSIndexPath *indexPath = objc_getAssociatedObject(textField, &indexPathKey);
        self.todoItemsArray[indexPath.row] = textField.text;
        
        [self saveListInDefaults:self.todoItemsArray withKey:todoItemsList];
    
    }
        [self.tableView reloadData];
    
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.todoItemsArray removeObjectAtIndex:indexPath.row];
        
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self saveListInDefaults:self.todoItemsArray withKey:todoItemsList];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Strore object to be moved in variable
    id originObj = [self.todoItemsArray objectAtIndex:fromIndexPath.row];
    
    // remove object to be moved from original location
    [self.todoItemsArray removeObjectAtIndex:fromIndexPath.row];
    
    [self.todoItemsArray insertObject:originObj atIndex:toIndexPath.row];
    
    // Save array end state in defaults settings
    [self saveListInDefaults:self.todoItemsArray withKey:todoItemsList];

    [self.tableView reloadData];
    
}

- (IBAction)onTap:(id)sender {
    NSLog(@"onTap");
    [self.view endEditing:YES];
    [self saveListInDefaults:self.todoItemsArray withKey:todoItemsList];
}

// Manage saving data into User Defaults
- (void) saveListInDefaults:(id)todoList withKey:(NSString *)key {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:todoList forKey:key];
    [defaults synchronize];
}


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
