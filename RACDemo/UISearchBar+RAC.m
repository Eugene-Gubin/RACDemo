//
//  UISearchBarRAC.m
//  RACDemo
//
//  Created by Евгений Губин on 11.11.14.
//  Copyright (c) 2014 simbirsoft.com. All rights reserved.
//

#import <objc/runtime.h>
#import "UISearchBar+RAC.h"

@interface UISearchBar ()<UISearchBarDelegate>

@end
@implementation UISearchBar (RAC)
-(RACSignal*)rac_textSignal {
    self.delegate = self;
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    signal = [[self rac_signalForSelector:@selector(searchBar:textDidChange:) fromProtocol:@protocol(UISearchBarDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}
@end
