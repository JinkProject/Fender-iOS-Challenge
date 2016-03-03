//
//  MapViewController.h
//  CoreData
//
//  Created by Stephen Whitfield on 3/2/16.
//  Copyright © 2016 ReduxNil. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Geolocation;

@interface MapViewController : UIViewController
@property (nonatomic, strong) Geolocation *geoLocation;
@end
