//
//  Geolocation+CoreDataProperties.h
//  CoreData
//
//  Created by Stephen Whitfield on 3/2/16.
//  Copyright © 2016 ReduxNil. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Geolocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface Geolocation (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *latitude;
@property (nullable, nonatomic, retain) NSString *longitude;
@property (nullable, nonatomic, retain) NSString *toponymName;
@property (nullable, nonatomic, retain) NSString *population;
@property (nullable, nonatomic, retain) NSString *region;
@property (nullable, nonatomic, retain) NSString *capital;

@end

NS_ASSUME_NONNULL_END
