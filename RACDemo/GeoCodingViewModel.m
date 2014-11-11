//
//  GeoCodingViewModel.m
//  RACDemo
//
//  Created by Евгений Губин on 11.11.14.
//  Copyright (c) 2014 simbirsoft.com. All rights reserved.
//

#import "GeoCodingViewModel.h"
#import "ReactiveCocoa.h"
#import "AFNetworking.h"
#import "RACAFNetworking.h"
#import "EXTScope.h"

static NSString *const kSubscribeURL = @"http://nominatim.openstreetmap.org";

@implementation GeoCodingViewModel

@synthesize performSearch = _performSearch;

+ (RACSignal *)doSearch:(NSString *)query {
    NSLog(@"doSearch for query: %@", query);
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *body = @{
                           @"q": query ?: @"",
                           @"format": @"json"
                           };
    
    return [[[manager rac_GET:kSubscribeURL parameters:body] logError] replayLazily];
}

- (RACCommand *)performSearch {
    if (!_performSearch) {
        @weakify(self);
        _performSearch = [[RACCommand alloc] initWithEnabled:[self searchTextNotEmpty] signalBlock:^RACSignal *(id input) {
            @strongify(self);
            return [GeoCodingViewModel doSearch:self.searchText];
        }];
        [[_performSearch.executionSignals flatten] subscribeNext:^(RACTuple* x) {
            @strongify(self);
//            NSLog(@"%@", x.second);
            NSMutableArray *result = [NSMutableArray new];
            NSArray* json = x.second;
            for (NSDictionary* place in json) {
                [result addObject:place[@"display_name"]];
            }
//            NSLog(@"result %@", result);
            self.lastResult = result;
        }];
    }
    return _performSearch;
}

- (RACSignal*) searchTextNotEmpty {
    RACSignal* searchTextSignal = RACObserve(self, searchText);
    return [searchTextSignal map:^id(NSString* text) {
        return @(text.length > 0);
    }];
}

@end

