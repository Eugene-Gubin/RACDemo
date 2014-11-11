//
//  ViewController.m
//  RACDemo
//
//  Created by Евгений Губин on 10.11.14.
//  Copyright (c) 2014 simbirsoft.com. All rights reserved.
//

#import "GeoSearchViewController.h"
#import "GeoCodingViewModel.h"
#import "UISearchBar+RAC.h"
#import "ReactiveCocoa.h"
#import "EXTScope.h"
#import "Waypoint.h"

@interface GeoSearchViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) GeoCodingViewModel* viewModel;

@end

@implementation GeoSearchViewController

-(void)awakeFromNib {
    [super awakeFromNib];
    self.viewModel = [GeoCodingViewModel sharedViewModel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    RAC(self.viewModel, searchText) = self.searchBar.rac_textSignal;
    
    @weakify(self);
    [[[self.searchBar.rac_textSignal filter:^BOOL(NSString *text) {
        return text.length > 0;
    }] throttle:1.0] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel.performSearch execute:nil];
    }];
    
    [RACObserve(self.viewModel, lastResult) subscribeNext:^(id x) {
        @strongify(self);
        [self.tableView reloadData];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.lastResult.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchResultCell"];
    Waypoint* w = self.viewModel.lastResult[indexPath.row];
    cell.textLabel.text = w.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"selectWaypoint.enabled %@", self.viewModel.selectWaypoint.enabled.first);
    [self.viewModel.selectWaypoint execute:[NSNumber numberWithInt:indexPath.row]];
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
