//
//  DetailViewController.m
//  RACDemo
//
//  Created by Евгений Губин on 10.11.14.
//  Copyright (c) 2014 simbirsoft.com. All rights reserved.
//

#import "DetailViewController.h"
#import "GeoCodingViewModel.h"
#import "ReactiveCocoa.h"
#import <MapKit/MapKit.h>

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) GeoCodingViewModel* viewModel;
@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    self.viewModel = [GeoCodingViewModel sharedViewModel];
    
    [self rac_liftSelector:@selector(setMapWaypoint:) withSignals:RACObserve(self.viewModel, selectedWaypoint), nil];
}

- (void)setMapWaypoint:(Waypoint*)waypoint {
    NSLog(@"setWP %@", waypoint);
    
    if (waypoint == nil) return;
    
    MKPointAnnotation* a = [MKPointAnnotation new];
    a.coordinate = waypoint.coordinate.coordinate;
    a.title = waypoint.title;
    
    [self.mapView setCenterCoordinate:a.coordinate];
    [self.mapView addAnnotation:a];
}

@end
