//
//  AugmentedRealityController.h
//  AR Kit
//
//  Modified by Niels W Hansen on 12/31/11.
//  Copyright 2013 Agilite Software All rights reserved.
//

#import "ARKit.h"

@class ARCoordinate;

@interface AugmentedRealityController : NSObject <UIAccelerometerDelegate, CLLocationManagerDelegate> {
	
@private
	double	latestHeading;
	double  degreeRange;
    float	viewAngle;
	float   prevHeading;
    int     cameraOrientation;

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
@property (nonatomic, retain) UIViewController          *parentViewController;
@property (nonatomic, retain) AVCaptureSession          *captureSession;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, assign) id<ARDelegate> delegate;
@property (nonatomic, retain) UILabel  *debugView;
@property (nonatomic, retain) NSMutableArray	*coordinates;

- (id)initWithView:(UIView*)arView parentViewController:(UIViewController*)parentVC withDelgate:(id<ARDelegate>) aDelegate;
- (void)setupDebugPostion;
- (void)updateLocations;
- (void)stopListening;
- (void)unloadAV;

// Adding coordinates to the underlying data model.
- (void)addCoordinate:(ARGeoCoordinate *)coordinate;

// Removing coordinates
- (void)removeCoordinate:(ARGeoCoordinate *)coordinate;
- (void)removeCoordinates:(NSArray *)coordinateArray;
- (void)updateDebugMode:(BOOL) flag;


@end
