//
//  MapViewController.m
//  CoreData
//
//  Created by Stephen Whitfield on 3/2/16.
//  Copyright © 2016 ReduxNil. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import "Geolocation+CoreDataProperties.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *capitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *populationLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryNameLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self populateCountryData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupMapView];
}

- (void)setupMapView {
    CGFloat regionRadius = 300000;
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.geoLocation.latitude doubleValue], [self.geoLocation.longitude doubleValue]);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coord, regionRadius, regionRadius);
    [self.mapView setRegion:region animated:YES];
}

- (void)populateCountryData {
    self.countryNameLabel.text = self.geoLocation.toponymName;
    self.regionLabel.text = [NSString stringWithFormat:@"Region: %@", self.geoLocation.region];
    self.capitalLabel.text = [NSString stringWithFormat:@"Capital: %@", self.geoLocation.capital];
    self.populationLabel.text = [NSString stringWithFormat:@"Population: %@", self.geoLocation.population];
}

@end
