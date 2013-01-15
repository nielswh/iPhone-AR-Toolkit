//
//  ARViewProtocol.h
//  AR Kit
//
//  Modified by Niels Hansen on 12/31/11.
//  Copyright 2013 Agilite Software. All rights reserved.
//

@class ARGeoCoordinate;

@protocol ARMarkerDelegate <NSObject>
-(void) didTapMarker:(ARGeoCoordinate *) coordinate;
@end

@protocol ARDelegate <NSObject>

-(void) didUpdateHeading:(CLHeading *)newHeading;
-(void) didUpdateLocation:(CLLocation *)newLocation;
-(void) didUpdateOrientation:(UIDeviceOrientation) orientation;

@end
