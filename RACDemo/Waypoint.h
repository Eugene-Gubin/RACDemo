//
//  Waypoint.h
//  RACDemo
//
//  Created by Евгений Губин on 11.11.14.
//  Copyright (c) 2014 simbirsoft.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
//#import <MapKit/MapKit.h>

@interface Waypoint : NSObject
@property (nonatomic, strong) CLLocation* coordinate;
@property (nonatomic, strong) NSString* title;
@end
