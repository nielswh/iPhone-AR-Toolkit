//
//  ARKit.h
//  AR Kit
//
//  Modified by Niels Hansen on 11/20/11.
//  Copyright 2013 Agilite Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ARGeoCoordinate.h"
#import "ARLocationDelegate.h"
#import "ARViewProtocol.h"
#import "GEOLocations.h"
#import "AugmentedRealityController.h"


@interface ARKit : NSObject

+(BOOL)deviceSupportsAR;

@end
