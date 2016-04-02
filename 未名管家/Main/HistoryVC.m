//
//  HistoryVC.m
//  未名管家
//
//  Created by apple on 15/11/20.
//  Copyright (c) 2015年 eight. All rights reserved.
//

#import "HistoryVC.h"
#import "HistoryCell.h"

#import <BmobQuery.h>
#import <BmobUser.h>

@interface HistoryVC ()

@property (nonatomic, strong) NSMutableArray *myArray;

@end

@implementation HistoryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"预订历史";
    self.tableView.rowHeight = 80;
    [self getDataFromBmob];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editClicked:)];
    
}

#pragma mark - actions
- (void)editClicked:(UIBarButtonItem *)item {
    if ([item.title isEqualToString:@"完成"]) {
        item.title = @"编辑";
        self.tableView.editing = NO;
    } else {
        item.title = @"完成";
        self.tableView.editing = YES;
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.myArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryCell *cell = [HistoryCell cellWithTableView:tableView];
    
    cell.dict = self.myArray[indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

//删除一行的代理方法
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //获取当前数组对应的objectId
        NSString *objectId = [self.myArray[indexPath.row] objectForKey:@"objectId"];
        [self deleteDataWithObjectId:objectId];
        [self.myArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }   
}


//从数据库查询
- (void)getDataFromBmob {
    BmobUser *bUser = [BmobUser getCurrentUser];
    
    BmobQuery *bquery = [BmobQuery queryWithClassName:@"Time"];
    [bquery whereKey:@"userName" equalTo:bUser.username];
    //按预定的时间降序排列
    [bquery orderByDescending:@"time"];
    //查找GameScore表的数据
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error) {
            NSLog(@"error is:%@",error);
        } else{
            self.myArray = (NSMutableArray *)array;
            [self.tableView reloadData];
        }
    }];
}

//从数据库中删除
- (void)deleteDataWithObjectId:(NSString *)objectId {
    BmobObject *bmobObject = [BmobObject objectWithoutDatatWithClassName:@"Time"  objectId:objectId];
    [bmobObject deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            //删除成功后的动作
            NSLog(@"successful");
        } else if (error){
            NSLog(@"%@",error);
        } else {
            NSLog(@"UnKnow error");
        }
    }];
}

@end
