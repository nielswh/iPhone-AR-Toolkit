//
//  ARLocationDelegate.h
//  AR Kit
//
//  Created by Jared Crawford on 2/13/10.
//  Copyright 2013. All rights reserved.
//

#import "ARGeoCoordinate.h"

@protocol ARLocationDelegate

//returns an array of ARGeoCoordinates
-(NSMutableArray *)geoLocations;
-(void) locationClicked:(ARGeoCoordinate *) coordinate;

@end

