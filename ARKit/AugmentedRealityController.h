//
//  AugmentedRealityController.h
//  AR Kit
//
//  Modified by Niels W Hansen on 12/31/11.
//  Copyright 2011 Agilite Software All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "ARViewController.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ARCoordinate;

@interface AugmentedRealityController : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {

	
@private
	double	latestHeading;
	double  degreeRange;
	
   
    float	viewAngle;
	float   prevHeading;
    int     cameraOrientation;
    
	NSMutableArray	*coordinates;
    
    UILabel				*debugView;
    AVCaptureSession    *captureSession;
    AVCaptureVideoPreviewLayer *previewLayer;
    
    UIAccelerometer		*accelerometerManager;
	CLLocation			*centerLocation;
	UIView				*displayView;

}

@property BOOL scaleViewsBasedOnDistance;
@property BOOL rotateViewsBasedOnPerspective;
@property BOOL debugMode;

@property double maximumScaleDistance;
@property double minimumScaleFactor;
@property double maximumRotationAngle;

@property (nonatomic, retain) UIAccelerometer           *accelerometerManager;
@property (nonatomic, retain) CLLocationManager         *locationManager;
@property (nonatomic, retain) ARCoordinate              *centerCoordinate;
@property (nonatomic, retain) CLLocation                *centerLocation;
@property (nonatomic, retain) UIView                    *displayView;
@property (nonatomic, retain) UIView                    *cameraView;
@property (nonatomic, retain) UIViewController          *rootViewController;
@property (nonatomic, retain) AVCaptureSession          *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, assign) id<ARDelegate> delegate;


@property (retain) UILabel  *debugView;

@property (nonatomic,retain) NSMutableArray		*coordinates;

- (id)initWithViewController:(UIViewController *)theView withDelgate:(id<ARDelegate>) aDelegate;

- (void) setupDebugPostion;
- (void) updateLocations;
- (void) stopListening;

// Adding coordinates to the underlying data model.
- (void)addCoordinate:(ARGeoCoordinate *)coordinate;

// Removing coordinates
- (void)removeCoordinate:(ARGeoCoordinate *)coordinate;
- (void)removeCoordinates:(NSArray *)coordinateArray;
- (void) updateDebugMode:(BOOL) flag;


@end
