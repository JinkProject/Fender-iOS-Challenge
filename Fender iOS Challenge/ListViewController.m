//
//  ViewController.m
//  CoreDataIssue
//
//  Created by Ruben Perez on 2/23/16.
//  Copyright © 2016 ReduxNil. All rights reserved.
//

#import "ListViewController.h"
#import "MapViewController.h"

#import <MapKit/MapKit.h>

#import "Geolocation.h"
#import "CoreDataStack.h"
#import "Checkbox.h"

#define kLocationLatitudeLongitude  @"latlng"
#define kLocationCountryName        @"name"
#define kLocationLatitude           @"latitude"
#define kLocationLongitude          @"longitude"
#define kLocationRegion             @"region"
#define kLocationPopulation         @"population"
#define kLocationCapital            @"capital"

#define kActivityIndicatorFadeDuration 0.1

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate> {
    __weak IBOutlet UITableView *_tableView;
    __weak IBOutlet UIActivityIndicatorView *activityIndicator;
    NSFetchedResultsController *_frc;
    NSManagedObjectContext *_managedObject;
}

@end

@implementation ViewController

static NSString * const CoreDataSyncFailureCellIdentifier = @"CoreDataSyncFailureCellIdentifier";
static NSString * const CellIdentifier = @"reuseIdentifier";
static NSString * const WebServiceURLString = @"https://restcountries.eu/rest/v1/region/europe";
static NSString * const ShowMapSegueIdentifier = @"ShowMapSegueIdentifier";

#pragma mark - Lifecycle

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _managedObject = [[CoreDataStack sharedStack] managedObjectContext];
    NSError * fetchResultsControllerError = nil;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([Geolocation class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"self.toponymName != \"\""];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"toponymName" ascending:YES]];
    
    _frc = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                               managedObjectContext:_managedObject
                                                 sectionNameKeyPath:nil
                                                          cacheName:nil];
    
    _frc.delegate = self;
    
    [_frc performFetch:&fetchResultsControllerError];
    
    if (fetchResultsControllerError) {
        NSLog(@"%@", fetchResultsControllerError.localizedDescription);
        return;
    }
    
    
    // We'll only fetch data from server if we have no location objects stored in memory... Only for this example though, since we are assuming the data won't change anytime soon
    if (_frc.fetchedObjects.count == 0) {
        [self fetchRemoteData];
    } else {
        [self syncUI];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - Networking

- (void)fetchRemoteData {
    
    // We'll only show the loader when fetching data since the response time is unknown
    [self showLoader];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:WebServiceURLString]];
    
    void (^completionHandler)(NSData *, NSURLResponse *, NSError *) = ^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self hideLoader];
        });
        
        if (error) {
            NSLog(@"Error in network response, not loading data");
            return;
        }
        
        NSError *jsonSerializationError = nil;
        NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&jsonSerializationError];
        
        if (jsonSerializationError) {
            NSLog(@"%@", jsonSerializationError.localizedDescription);
            return;
        }
        
        for (NSDictionary *location in JSON) {
            
            NSString *countryName = location[kLocationCountryName];
            NSArray *coordinates = location[kLocationLatitudeLongitude];
            NSString *region = location[kLocationRegion];
            NSString *capital = location[kLocationCapital];
            NSString *population = [location[kLocationPopulation] stringValue];
            
            if (!countryName || coordinates.count != 2) {
                continue;
            }
            
            [self processLocation:countryName
                  withData:@{
                             kLocationLatitude : coordinates.firstObject,
                             kLocationLongitude : coordinates.lastObject,
                             kLocationRegion : region,
                             kLocationPopulation : population,
                             kLocationCapital : capital,
                                    }];
        }
        
        NSError *saveError = nil;
        if (![_managedObject save:&saveError]) {
            NSLog(@"Error: %@", error.localizedDescription);
        }
    };
    
    NSURLSessionTask *task = [session dataTaskWithRequest:urlRequest
                                        completionHandler:completionHandler];
    
    [task resume];
    
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self syncUI];
}

#pragma mark - Helper methods

- (void)processLocation:(NSString*)locationName withData:(NSDictionary*)data {
    //Implement me!!
    Geolocation *geoLocation = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Geolocation class]) inManagedObjectContext:_managedObject];
    
    if (!geoLocation) {
        return;
    }
    
    geoLocation.latitude = [data[kLocationLatitude] stringValue];
    geoLocation.longitude = [data[kLocationLongitude] stringValue];
    geoLocation.toponymName = locationName;
    geoLocation.capital = data[kLocationCapital];
    geoLocation.region = data[kLocationRegion];
    geoLocation.population = data[kLocationPopulation];
}

#pragma mark - Table View Datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //no need to look into sections, there is only one section
    if (_frc.fetchedObjects == nil) {
        return 1;
    }
    
    return _frc.fetchedObjects.count;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_frc.fetchedObjects == nil) {
        UITableViewCell *failureCell = [tableView dequeueReusableCellWithIdentifier:CoreDataSyncFailureCellIdentifier];
        return failureCell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = ((Geolocation*)[_frc objectAtIndexPath:indexPath]).toponymName;
    return cell;
    
}

#pragma mark - UI

- (void)syncUI {
    [_tableView reloadData];
}

- (void)showLoader {
    [activityIndicator startAnimating];
}

- (void)hideLoader {
    if (!activityIndicator.isHidden) {
        [UIView animateWithDuration:UINavigationControllerHideShowBarDuration animations:^{
            activityIndicator.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                [activityIndicator stopAnimating];
                activityIndicator.alpha = 1; // reset alpha
            }
        }];
    }
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self performSegueWithIdentifier:ShowMapSegueIdentifier sender:cell];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ShowMapSegueIdentifier]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath *indexPath = [_tableView indexPathForCell:sender];
            Geolocation *geoLocation = (Geolocation *)[_frc objectAtIndexPath:indexPath];
            MapViewController *mapViewController = (MapViewController *)segue.destinationViewController;
            mapViewController.geoLocation = geoLocation;
        }
    }
}

#pragma mark - Custom Checkbox control action

- (IBAction)checkboxTouched:(Checkbox *)sender {
    sender.controlState = !sender.controlState;
}


@end
