//
//  CheckBoxControl.m
//  CoreData
//
//  Created by Stephen Whitfield on 3/2/16.
//  Copyright © 2016 ReduxNil. All rights reserved.
//

#import "Checkbox.h"

@interface Checkbox() {
    UIImageView *imageView;
}

@end

@implementation Checkbox

- (void)setControlState:(ControlState)controlState {
    _controlState = controlState;
    
    if (!imageView) {
        imageView = [[UIImageView alloc] initWithFrame:(CGRect){ CGRectZero.origin, self.bounds.size }];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageView];
    }
    
    switch (_controlState) {
        case On:
            NSLog(@"Checkbox on");
            [imageView setImage:[UIImage imageNamed:@"Checkbox"]];
            break;
        case Off:
            [imageView setImage:[UIImage imageNamed:@"CheckboxOff"]];
            NSLog(@"Checkbox off");
            break;
    }
}

@end
