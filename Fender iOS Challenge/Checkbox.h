//
//  CheckBoxControl.h
//  CoreData
//
//  Created by Stephen Whitfield on 3/2/16.
//  Copyright © 2016 ReduxNil. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(BOOL, ControlState) {
    Off = NO,
    On
};

@interface Checkbox : UIControl

#if TARGET_INTERFACE_BUILDER
@property (nonatomic, assign) IBInspectable BOOL controlState;
#else
@property (nonatomic, assign) ControlState controlState;
#endif

@end
