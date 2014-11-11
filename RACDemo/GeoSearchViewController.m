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

@interface GeoSearchViewController ()
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) GeoCodingViewModel* viewModel;

@end

@implementation GeoSearchViewController

- (id)init {
    self = [super init];
    if (self) {
        self.viewModel = [GeoCodingViewModel new];
    }
    return self;
}

-(void)awakeFromNib {
    self.viewModel = [GeoCodingViewModel new];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.dataSource = self;
    
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
    cell.textLabel.text = self.viewModel.lastResult[indexPath.row];
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
