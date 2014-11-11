//
//  UISearchBarRAC.h
//  RACDemo
//
//  Created by Евгений Губин on 11.11.14.
//  Copyright (c) 2014 simbirsoft.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ReactiveCocoa.h"

@interface UISearchBar (RAC)
-(RACSignal*)rac_textSignal;
@end
