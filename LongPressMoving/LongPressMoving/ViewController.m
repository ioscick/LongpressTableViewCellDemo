//
//  ViewController.m
//  LongPressMoving
//
//  Created by shenliping on 16/3/11.
//  Copyright © 2016年 shenliping. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithObjects:@"shenliping", @"hello", @"somtimes", @"case", @"goodBye", @"HOHOHOHO", nil];
    }
    return _dataArray;
}

- (UITableView *)tableView
{
    if (_tableView == nil)
    {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] init];
        [_tableView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(panItem:)]];
    }
    return _tableView;
}

- (void)panItem:(UILongPressGestureRecognizer *)longPress
{
    CGPoint locatin = [longPress locationInView:_tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:locatin];

    NSLog(@"第几行：%ld",(long)indexPath.row);
    
    static UIView *snapshot = nil; ///< A snapshot of the row user is moving.
    static NSIndexPath *sourceIndexPath = nil; ///< Initial index path, where gesture begins.
    
    if (longPress.state == UIGestureRecognizerStateBegan) {
        sourceIndexPath = indexPath;
        
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        snapshot = [self customSnapshotFromView:cell];
        
        __block CGPoint center = cell.center;
        snapshot.center = center;
        snapshot.alpha = 0.0;
        [self.tableView addSubview:snapshot];
        
        [UIView animateWithDuration:0.3 animations:^{
            center.y = locatin.y;
            snapshot.center = center;
            snapshot.alpha = 0.98;
            snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
            cell.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            
        }];
    }
    else if (longPress.state == UIGestureRecognizerStateChanged){
        CGPoint center = snapshot.center;
        center.y = locatin.y;
        snapshot.center = center;
        
        if (indexPath && ![indexPath isEqual:sourceIndexPath]) {
            [self.dataArray exchangeObjectAtIndex:indexPath.row withObjectAtIndex:sourceIndexPath.row];
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:sourceIndexPath];
            sourceIndexPath = indexPath;
        }
    }
    else if (longPress.state == UIGestureRecognizerStateEnded){
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:sourceIndexPath];
        [UIView animateWithDuration:0.3 animations:^{
            snapshot.center = cell.center;
            snapshot.transform = CGAffineTransformIdentity;
            snapshot.alpha = 0.0;
            
            cell.backgroundColor = [UIColor whiteColor];
        } completion:^(BOOL finished) {
            [snapshot removeFromSuperview];
            snapshot = nil;
        }];
        sourceIndexPath = nil;
    }
}

- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    UIView *snapshot = [inputView snapshotViewAfterScreenUpdates:YES];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
