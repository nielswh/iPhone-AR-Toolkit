//
//  AugmentedRealityController.m
//  AR Kit
//
//  Modified by Niels W Hansen on 5/25/12.
//  Copyright 2013 Agilite Software. All rights reserved.
//

#import "AugmentedRealityController.h"

#define kFilteringFactor 0.05
#define degreesToRadian(x) (M_PI * (x) / 180.0)
#define radianToDegrees(x) ((x) * 180.0/M_PI)
#define M_2PI 2.0 * M_PI
#define BOX_WIDTH 150
#define BOX_HEIGHT 100
#define BOX_GAP 10
#define ADJUST_BY 30
#define DISTANCE_FILTER 2.0
#define HEADING_FILTER 1.0
#define INTERVAL_UPDATE 0.75
#define SCALE_FACTOR 1.0
#define HEADING_NOT_SET -1.0
#define DEGREE_TO_UPDATE 1

@interface AugmentedRealityController (Private)
- (void)updateCenterCoordinate;
- (void)startListening;
- (void)currentDeviceOrientation;

- (double)findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*) isBetweenNorth;
- (CGPoint)pointForCoordinate:(ARCoordinate *)coordinate;
- (BOOL)shouldDisplayCoordinate:(ARCoordinate *)coordinate;

@end

@implementation AugmentedRealityController

@synthesize locationManager;
@synthesize accelerometerManager;
@synthesize displayView;
@synthesize debugView;
@synthesize centerCoordinate;
@synthesize scaleViewsBasedOnDistance;
@synthesize rotateViewsBasedOnPerspective;
@synthesize maximumScaleDistance;
@synthesize minimumScaleFactor;
@synthesize maximumRotationAngle;
@synthesize centerLocation;
@synthesize coordinates;
@synthesize debugMode;
@synthesize captureSession;
@synthesize previewLayer;
@synthesize delegate;
@synthesize parentViewController;


- (id)initWithView:(UIView*)arView parentViewController:(UIViewController*)parentVC withDelgate:(id<ARDelegate>) aDelegate
{    
    if (!(self = [super init]))
		return nil;
    
    [self setParentViewController:parentVC];
    [self setDelegate:aDelegate];

    latestHeading   = HEADING_NOT_SET;
    prevHeading     = HEADING_NOT_SET;
    
    [self setMaximumScaleDistance: 0.0];
	[self setMinimumScaleFactor: SCALE_FACTOR];
	[self setScaleViewsBasedOnDistance: NO];
	[self setRotateViewsBasedOnPerspective: NO];
	[self setMaximumRotationAngle: M_PI / 6.0];
    [self setCoordinates:[NSMutableArray array]];
    [self currentDeviceOrientation];
	
	degreeRange = [arView frame].size.width / ADJUST_BY;

#if !TARGET_IPHONE_SIMULATOR
    
    NSError *error = nil;
    AVCaptureSession *avCaptureSession = [[AVCaptureSession alloc] init];
    AVCaptureDevice *videoCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoCaptureDevice error:&error];
    
    if (videoInput) {
        [avCaptureSession addInput:videoInput];
    }
    else {
        // Handle the failure.
    }
    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:avCaptureSession];

    [[arView layer] setMasksToBounds:YES];
    [newCaptureVideoPreviewLayer setFrame:[arView bounds]];
    [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    if ([[newCaptureVideoPreviewLayer connection] isVideoOrientationSupported])
        [[newCaptureVideoPreviewLayer connection] setVideoOrientation:cameraOrientation];
    
    [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [[arView layer] insertSublayer:newCaptureVideoPreviewLayer below:[[[arView layer] sublayers] objectAtIndex:0]];
    
    [self setPreviewLayer:newCaptureVideoPreviewLayer];
    
    [avCaptureSession setSessionPreset:AVCaptureSessionPresetHigh];
    [avCaptureSession startRunning];
    
    [self setCaptureSession:avCaptureSession];  
  
#endif

    CLLocation *newCenter = [[CLLocation alloc] initWithLatitude:37.41711 longitude:-122.02528]; //TODO: We should get the latest heading here.
	
	[self setCenterLocation: newCenter];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:)
                                                 name: UIDeviceOrientationDidChangeNotification object:nil];
    	
	[self startListening];
    [self setDisplayView:arView];
    
  	return self;
}

-(void)unloadAV
{
    [captureSession stopRunning];
    AVCaptureInput* input = [captureSession.inputs objectAtIndex:0];
    [captureSession removeInput:input];
    [[self previewLayer] removeFromSuperlayer];
    [self setCaptureSession:nil];
    [self setPreviewLayer:nil];
    [self setDisplayView:nil];
}

- (void)dealloc
{
    [self stopListening];
    [self unloadAV];
    locationManager.delegate = nil;
    [UIAccelerometer sharedAccelerometer].delegate = nil;
}

#pragma mark -	
#pragma mark Location Manager methods
- (void)startListening
{
	// start our heading readings and our accelerometer readings.
	if (![self locationManager]) {
		CLLocationManager *newLocationManager = [[CLLocationManager alloc] init];

        [newLocationManager setHeadingFilter: HEADING_FILTER];
        [newLocationManager setDistanceFilter:DISTANCE_FILTER];
		[newLocationManager setDesiredAccuracy: kCLLocationAccuracyNearestTenMeters];
		[newLocationManager startUpdatingHeading];
		[newLocationManager startUpdatingLocation];
		[newLocationManager setDelegate: self];
        
        [self setLocationManager: newLocationManager];
	}
			
	if (![self accelerometerManager]) {
		[self setAccelerometerManager: [UIAccelerometer sharedAccelerometer]];
		[[self accelerometerManager] setUpdateInterval: INTERVAL_UPDATE];
		[[self accelerometerManager] setDelegate: self];
	}
	
	if (![self centerCoordinate]) 
		[self setCenterCoordinate:[ARCoordinate coordinateWithRadialDistance:1.0 inclination:0 azimuth:0]];
}

- (void)stopListening
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
   
    if ([self locationManager]) {
       [[self locationManager] setDelegate: nil];
    }
    
    if ([self accelerometerManager]) {
       [[self accelerometerManager] setDelegate: nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{    
    latestHeading = degreesToRadian(newHeading.magneticHeading);
    
    //Let's only update the Center Coordinate when we have adjusted by more than X degrees
    if (fabs(latestHeading-prevHeading) >= degreesToRadian(DEGREE_TO_UPDATE) || prevHeading == HEADING_NOT_SET) {
        prevHeading = latestHeading;
        [self updateCenterCoordinate];
        [[self delegate] didUpdateHeading:newHeading];
    }
}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
	return YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [self setCenterLocation:newLocation];
    NSLog(@"Location of phone changed!");
    [[self delegate] didUpdateLocation:newLocation];
    
}

- (void)updateCenterCoordinate
{
	double adjustment = 0;

    switch (cameraOrientation) {
        case UIDeviceOrientationLandscapeLeft:
            adjustment = degreesToRadian(270); 
            break;
        case UIDeviceOrientationLandscapeRight:    
            adjustment = degreesToRadian(90);
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            adjustment = degreesToRadian(180);
            break;
        default:
            adjustment = 0;
            break;
    }
	
	[[self centerCoordinate] setAzimuth: latestHeading - adjustment];
	[self updateLocations];
}

- (void)setCenterLocation:(CLLocation *)newLocation
{
	centerLocation = newLocation;
	
	for (ARGeoCoordinate *geoLocation in [self coordinates]) {
		
		if ([geoLocation isKindOfClass:[ARGeoCoordinate class]]) {
			[geoLocation calibrateUsingOrigin:centerLocation];
			
			if ([geoLocation radialDistance] > [self maximumScaleDistance]) 
				[self setMaximumScaleDistance:[geoLocation radialDistance]];
		}
	}
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{	
	switch (cameraOrientation) {
		case UIDeviceOrientationLandscapeLeft:
			viewAngle = atan2(acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationLandscapeRight:
			viewAngle = atan2(-acceleration.x, acceleration.z);
			break;
		case UIDeviceOrientationPortrait:
			viewAngle = atan2(acceleration.y, acceleration.z);
			break;
		case UIDeviceOrientationPortraitUpsideDown:
			viewAngle = atan2(-acceleration.y, acceleration.z);
			break;	
		default:
			break;
	}
}

#pragma mark -	
#pragma mark Coordinate methods

- (void)addCoordinate:(ARGeoCoordinate *)coordinate
{	
	[[self coordinates] addObject:coordinate];
	
	if ([coordinate radialDistance] > [self maximumScaleDistance]) 
		[self setMaximumScaleDistance: [coordinate radialDistance]];
}

- (void)removeCoordinate:(ARGeoCoordinate *)coordinate
{
	[[self coordinates] removeObject:coordinate];
}

- (void)removeCoordinates:(NSArray *)coordinateArray
{
	for (ARGeoCoordinate *coordinateToRemove in coordinateArray) {
		NSUInteger indexToRemove = [[self coordinates] indexOfObject:coordinateToRemove];
		
		//TODO: Error checking in here.
		[[self coordinates] removeObjectAtIndex:indexToRemove];
	}
}

#pragma mark -	
#pragma mark Location methods

-(double) findDeltaOfRadianCenter:(double*)centerAzimuth coordinateAzimuth:(double)pointAzimuth betweenNorth:(BOOL*) isBetweenNorth
{
	if (*centerAzimuth < 0.0) 
		*centerAzimuth = M_2PI + *centerAzimuth;
	
	if (*centerAzimuth > M_2PI) 
		*centerAzimuth = *centerAzimuth - M_2PI;
	
	double deltaAzimuth = ABS(pointAzimuth - *centerAzimuth);
	*isBetweenNorth		= NO;

	// If values are on either side of the Azimuth of North we need to adjust it.  Only check the degree range
	if (*centerAzimuth < degreesToRadian(degreeRange) && pointAzimuth > degreesToRadian(360-degreeRange)) {
		deltaAzimuth	= (*centerAzimuth + (M_2PI - pointAzimuth));
		*isBetweenNorth = YES;
	}
	else if (pointAzimuth < degreesToRadian(degreeRange) && *centerAzimuth > degreesToRadian(360-degreeRange)) {
		deltaAzimuth	= (pointAzimuth + (M_2PI - *centerAzimuth));
		*isBetweenNorth = YES;
	}
			
	return deltaAzimuth;
}

- (BOOL)shouldDisplayCoordinate:(ARCoordinate *)coordinate
{
	
	double currentAzimuth = [[self centerCoordinate] azimuth];
	double pointAzimuth	  = [coordinate azimuth];
	BOOL isBetweenNorth	  = NO;
	double deltaAzimuth	  = [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	BOOL result			  = NO;
	
  //  NSLog(@"Current %f, Item %f, delta %f, range %f",currentAzimuth,pointAzimuth,deltaAzimith,degreesToRadian([self degreeRange]));
    
	if (deltaAzimuth <= degreesToRadian(degreeRange))
		result = YES;

	return result;
}

- (CGPoint)pointForCoordinate:(ARCoordinate *)coordinate
{
	
	CGPoint point;
	CGRect realityBounds	= [[self displayView] bounds];
	double currentAzimuth	= [[self centerCoordinate] azimuth];
	double pointAzimuth		= [coordinate azimuth];
	BOOL isBetweenNorth		= NO;
	double deltaAzimith		= [self findDeltaOfRadianCenter: &currentAzimuth coordinateAzimuth:pointAzimuth betweenNorth:&isBetweenNorth];
	
	if ((pointAzimuth > currentAzimuth && !isBetweenNorth) || 
        (currentAzimuth > degreesToRadian(360- degreeRange) && pointAzimuth < degreesToRadian(degreeRange))) {
		point.x = (realityBounds.size.width / 2) + ((deltaAzimith / degreesToRadian(1)) * ADJUST_BY);  // Right side of Azimuth
    }
	else
		point.x = (realityBounds.size.width / 2) - ((deltaAzimith / degreesToRadian(1)) * ADJUST_BY);	// Left side of Azimuth
	
	point.y = (realityBounds.size.height / 2); // + (radianToDegrees(M_PI_2 + viewAngle)  * 2.0);
  	
	return point;
}

- (void)updateLocations
{
	
	[debugView setText: [NSString stringWithFormat:@"%.3f %.3f ", -radianToDegrees(viewAngle), radianToDegrees([[self centerCoordinate] azimuth])]];
	
	for (ARGeoCoordinate *item in [self coordinates]) {

        UIView *markerView = [item displayView];
        
		if ([self shouldDisplayCoordinate:item]) {
		
            CGPoint loc = [self pointForCoordinate:item];
            CGFloat scaleFactor = SCALE_FACTOR;
	
			if ([self scaleViewsBasedOnDistance]) 
				scaleFactor = scaleFactor - [self minimumScaleFactor]*([item radialDistance] / [self maximumScaleDistance]);

			float width	 = [markerView bounds].size.width  * scaleFactor;
			float height = [markerView bounds].size.height * scaleFactor;

			[markerView setFrame:CGRectMake(loc.x - width / 2.0, loc.y, width, height)];
            [markerView setNeedsDisplay];
			
			CATransform3D transform = CATransform3DIdentity;
			
			// Set the scale if it needs it. Scale the perspective transform if we have one.
			if ([self scaleViewsBasedOnDistance]) 
				transform = CATransform3DScale(transform, scaleFactor, scaleFactor, scaleFactor);
		
			if ([self rotateViewsBasedOnPerspective]) {
				transform.m34 = 1.0 / 300.0;
		/*		
				double itemAzimuth		= [item azimuth];
				double centerAzimuth	= [[self centerCoordinate] azimuth];
				
				if (itemAzimuth - centerAzimuth > M_PI) 
					centerAzimuth += M_2PI;
				
				if (itemAzimuth - centerAzimuth < -M_PI) 
					itemAzimuth  += M_2PI;
		*/		
		//		double angleDifference	= itemAzimuth - centerAzimuth;
		//		transform				= CATransform3DRotate(transform, [self maximumRotationAngle] * angleDifference / 0.3696f , 0, 1, 0);
			}
			[[markerView layer] setTransform:transform];
			
			//if marker is not already set then insert it
			if (!([markerView superview])) {
				[[self displayView] insertSubview:markerView atIndex:1];
			}
		} 
		else 
            if ([markerView superview])
                [markerView removeFromSuperview];

	}
}

-(NSComparisonResult) LocationSortClosestFirst:(ARCoordinate *) s1 secondCoord:(ARCoordinate*) s2
{    
	if ([s1 radialDistance] < [s2 radialDistance]) 
		return NSOrderedAscending;
	else if ([s1 radialDistance] > [s2 radialDistance]) 
		return NSOrderedDescending;
	else 
		return NSOrderedSame;
}

#pragma mark -	
#pragma mark Device Orientation

- (void)currentDeviceOrientation
{
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];

	if (orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationFaceUp && orientation != UIDeviceOrientationFaceDown) {
		switch (orientation) {
            case UIDeviceOrientationLandscapeLeft:
                cameraOrientation = AVCaptureVideoOrientationLandscapeRight;
                break;
            case UIDeviceOrientationLandscapeRight:
                cameraOrientation = AVCaptureVideoOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                cameraOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
                break;
            case UIDeviceOrientationPortrait:
                cameraOrientation = AVCaptureVideoOrientationPortrait;
                break;
            default:
                break;
        }
    }
}

- (void)deviceOrientationDidChange:(NSNotification *)notification
{	
	prevHeading = HEADING_NOT_SET; 
    
    [self currentDeviceOrientation];
	
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
    if (orientation != UIDeviceOrientationUnknown && orientation != UIDeviceOrientationFaceUp && orientation != UIDeviceOrientationFaceDown) {
        
        CGRect bounds = [[self displayView] bounds];
        
        if (![[self parentViewController] shouldAutorotate]) {
            
            CGAffineTransform transform = CGAffineTransformMakeRotation(degreesToRadian(0));
            
            switch (orientation) {
                case UIDeviceOrientationLandscapeLeft:
                    transform		   = CGAffineTransformMakeRotation(degreesToRadian(90));
                    break;
                case UIDeviceOrientationLandscapeRight:
                    transform		   = CGAffineTransformMakeRotation(degreesToRadian(-90));
                    break;
                case UIDeviceOrientationPortraitUpsideDown:
                    transform = CGAffineTransformMakeRotation(degreesToRadian(180));
                    break;
                default:
                    break;
            }
            
            [UIView beginAnimations:@"rotate" context:nil];
            [UIView setAnimationDuration:0.5];
            self.displayView.transform = transform;
            [UIView commitAnimations];
        }
     
        [[[self previewLayer] connection] setVideoOrientation:cameraOrientation];
        [[self previewLayer] setFrame:bounds];
  
        degreeRange = bounds.size.width / ADJUST_BY;
        [self updateDebugMode:YES];
        [[self delegate] didUpdateOrientation:orientation];
	}
}

#pragma mark -	
#pragma mark Debug features

- (void)updateDebugMode:(BOOL) flag
{
	if ([self debugMode] == flag) {
		CGRect debugRect = CGRectMake(0, [[self displayView] bounds].size.height -20, [[self displayView] bounds].size.width, 20);	
		[debugView setFrame: debugRect];
		return;
	}
	
	if ([self debugMode]) {
		debugView = [[UILabel alloc] initWithFrame:CGRectZero];
		[debugView setTextAlignment: NSTextAlignmentCenter];
		[debugView setText: @"Waiting..."];
		[displayView addSubview:debugView];
		[self setupDebugPostion];
	}
	else 
		[debugView removeFromSuperview];

}

-(void) setupDebugPostion
{
	if ([self debugMode]) {
		[debugView sizeToFit];
		CGRect displayRect = [[self displayView] bounds];
		
		[debugView setFrame:CGRectMake(0, displayRect.size.height - [debugView bounds].size.height,  
                                       displayRect.size.width, [debugView bounds].size.height)];
	}
}


@end
