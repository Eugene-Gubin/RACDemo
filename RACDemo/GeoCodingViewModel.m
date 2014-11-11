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
#import "Waypoint.h"
#import <CoreLocation/CoreLocation.h>

static NSString *const kSubscribeURL = @"http://nominatim.openstreetmap.org";

@implementation GeoCodingViewModel

@synthesize performSearch = _performSearch;
@synthesize selectWaypoint = _selectWaypoint;

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
                Waypoint* w = [Waypoint new];
                w.title = place[@"display_name"];
                NSString *lat = place[@"lat"];
                NSString *lon = place[@"lon"];
                w.coordinate = [[CLLocation alloc] initWithLatitude:lat.doubleValue longitude:lon.doubleValue];
                [result addObject:w];
            }
//            NSLog(@"result %@", result);
            self.lastResult = result;
        }];
    }
    return _performSearch;
}

- (RACCommand *)selectWaypoint {
    if (!_selectWaypoint) {
        @weakify(self);
        _selectWaypoint = [[RACCommand alloc] initWithEnabled:nil signalBlock:^RACSignal *(id input) {
            NSNumber *index = input;
            return [RACSignal startLazilyWithScheduler:[RACScheduler mainThreadScheduler] block:^(id<RACSubscriber> s) {
                @strongify(self);
                self.selectedWaypoint = self.lastResult[index.intValue];
                [s sendNext:nil];
                [s sendCompleted];
            }];
        }];
    }
    return _selectWaypoint;
}

- (RACSignal*) searchTextNotEmpty {
    RACSignal* searchTextSignal = RACObserve(self, searchText);
    return [searchTextSignal map:^id(NSString* text) {
        return @(text.length > 0);
    }];
}

+ (instancetype)sharedViewModel {
    static GeoCodingViewModel* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [GeoCodingViewModel new];
    });
    return sharedInstance;
}

@end

