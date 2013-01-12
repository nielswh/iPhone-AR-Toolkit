//
//  ARViewController.h
//  ARKitDemo
//
//  Modified by Niels W Hansen on 12/31/11.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARLocationDelegate.h"
#import "ARViewProtocol.h"


@class AugmentedRealityController;

@interface ARViewController : UIViewController<ARMarkerDelegate, ARDelegate>

@property (nonatomic, retain) AugmentedRealityController *agController;
@property (nonatomic, assign) id<ARLocationDelegate> delegate;

-(id)initWithDelegate:(id<ARLocationDelegate>) aDelegate;




@end

