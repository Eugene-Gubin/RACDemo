//
//  GeoCodingViewModel.h
//  RACDemo
//
//  Created by Евгений Губин on 11.11.14.
//  Copyright (c) 2014 simbirsoft.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReactiveCocoa.h"
#import "Waypoint.h"

@interface GeoCodingViewModel : NSObject
@property (nonatomic, strong) NSString* searchText;
@property (nonatomic, copy) NSArray* lastResult;
@property (nonatomic, strong) Waypoint* selectedWaypoint;

@property (nonatomic, strong) RACCommand* performSearch;
@property (nonatomic, strong) RACCommand* selectWaypoint;

+ (instancetype)sharedViewModel;

@end
