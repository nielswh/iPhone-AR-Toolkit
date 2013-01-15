//
//  MainViewController.m
//  ARKitDemo
//
//  Modified by Niels Hansen on 10/2/11.
//  Copyright 2013 Agilite Software. All rights reserved.
//

#import "ARKitDemoAppDelegate.h"
#import "MainViewController.h"
#import "ContentManager.h"
#import "MarkerView.h"
#import "ContentManager.h"
#import "FullScreenARViewController.h"

@interface MainViewController  () {
   AugmentedRealityController  *arc;
}

- (void)addGeoLocationtoArray:(NSMutableArray*)locArray withLatitude:(float)latitude Longitude:(float)longitude usingName:(NSString*)label;

@end

@implementation MainViewController

@synthesize infoViewController;
@synthesize ScaleOnDistance;
@synthesize DebugModeSwitch;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        
    }
    
    return self;
}

- (void)dealloc
{

}

- (BOOL)shouldAutorotate {
    return NO;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (IBAction)debugModeChanged:(id)sender {
    [[ContentManager sharedContentManager] setDebugMode:[[self DebugModeSwitch] isOn]];
}
- (IBAction)ScaleDistanceChanged:(id)sender {
    [[ContentManager sharedContentManager] setScaleOnDistance:[[self ScaleOnDistance] isOn]];
}

- (void)notSupportView
{
    ARKitDemoAppDelegate *appDelegate = (ARKitDemoAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    UIViewController *newInfoViewController = [[UIViewController alloc] init];
    [self setInfoViewController:newInfoViewController];
    
    UILabel *errorLabel = [[UILabel alloc] init];
    [errorLabel setNumberOfLines:0];
    [errorLabel setText: @"Augmented Reality is not supported on this device"];
    [errorLabel setFrame: [[infoViewController view] bounds]];
    [errorLabel setTextAlignment:NSTextAlignmentCenter];
    [[infoViewController view] addSubview:errorLabel];
    
    UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    [closeButton setTitle:@"Close" forState:UIControlStateNormal];
    
    [closeButton setBackgroundColor:[UIColor blueColor]];
    [closeButton addTarget:self action:@selector(closeNotSupportedView:) forControlEvents:UIControlEventTouchUpInside];
    [[infoViewController view] addSubview:closeButton];
    
    [[appDelegate window] addSubview:[infoViewController view]];
}

- (void)populateGeoLocations
{
    GEOLocations* locations = [[GEOLocations alloc] initWithDelegate:self];
    
    if ([[locations returnLocations] count] > 0) {
        for (ARGeoCoordinate *coordinate in [locations returnLocations]) {
            MarkerView *cv = [[MarkerView alloc] initForCoordinate:coordinate withDelgate:self] ;
            [coordinate setDisplayView:cv];
            
            [arc addCoordinate:coordinate];
        }
    }
}

- (IBAction)displayAR:(id)sender
{
    if ([ARKit deviceSupportsAR]) {
        arc = [[AugmentedRealityController alloc] initWithView:[self arView] parentViewController:self withDelgate:self];
        
        [arc setDebugMode:[[ContentManager sharedContentManager] debugMode]];
        [arc setScaleViewsBasedOnDistance:[[ContentManager sharedContentManager] scaleOnDistance]];
        [arc setMinimumScaleFactor:0.5];
        [arc setRotateViewsBasedOnPerspective:YES];
        [arc updateDebugMode:![arc debugMode]];
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        
        [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
        
        [closeBtn setBackgroundColor:[UIColor greenColor]];
        [closeBtn addTarget:self action:@selector(clearARView:) forControlEvents:UIControlEventTouchUpInside];
        [[self arView] addSubview:closeBtn];
        
        [self populateGeoLocations];
    }
    else
        [self notSupportView];
   
}

- (IBAction)displayARFullScreen:(id)sender
{
    if ([ARKit deviceSupportsAR]) {
    
        if (arc != nil)
            [self clearARView:self];
        
        FullScreenARViewController *fullScreenVC = [[FullScreenARViewController alloc] initWithNibName:@"FullScreenARViewController" bundle:nil];
        
        arc = [[AugmentedRealityController alloc] initWithView:[fullScreenVC view] parentViewController:fullScreenVC withDelgate:self];
        
        [arc setDebugMode:[[ContentManager sharedContentManager] debugMode]];
        [arc setScaleViewsBasedOnDistance:[[ContentManager sharedContentManager] scaleOnDistance]];
        [arc setMinimumScaleFactor:0.5];
        [arc setRotateViewsBasedOnPerspective:YES];
        [arc updateDebugMode:![arc debugMode]];
        
        UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
        
        [closeBtn setTitle:@"Close" forState:UIControlStateNormal];
        
        [closeBtn setBackgroundColor:[UIColor greenColor]];
        [closeBtn addTarget:self action:@selector(closeFullScreen:) forControlEvents:UIControlEventTouchUpInside];
        [[fullScreenVC view] addSubview:closeBtn];
       
        
        [fullScreenVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self presentViewController:fullScreenVC animated:YES completion:nil];
        
         [self populateGeoLocations];
    }
    else
        [self notSupportView];
}

- (IBAction)closeNotSupportedView:(id)sender
{
    [[[self infoViewController] view] removeFromSuperview];
    infoViewController = nil;
}

- (IBAction)closeButtonClicked:(id)sender
{
    [[[self infoViewController] view] removeFromSuperview];
    infoViewController = nil;
}

- (IBAction)clearARView:(id)sender {

    [arc unloadAV];
    [[[self arView] subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    arc = nil;
}

- (IBAction)closeFullScreen:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    [arc unloadAV];
    arc = nil;
}

-(void) locationClicked:(ARGeoCoordinate *) coordinate {
    
    if (coordinate != nil) {
        NSLog(@"Main View Controller received the click Event for: %@",[coordinate title]);
        
        ARKitDemoAppDelegate *appDelegate = (ARKitDemoAppDelegate*)[[UIApplication sharedApplication] delegate];
        UIViewController *infovc = [[UIViewController alloc] init];
        
        UILabel *errorLabel = [[UILabel alloc] init];
        [errorLabel setNumberOfLines:0];
        [errorLabel setText: [NSString stringWithFormat:@"You clicked on %@ and distance is %.2f km",[coordinate title], [coordinate distanceFromOrigin]/1000.0f]];
        [errorLabel setFrame: [[infovc view] bounds]];
        [errorLabel setTextAlignment:NSTextAlignmentCenter];
        [[infovc view] addSubview:errorLabel];
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 90, 30)];
        [closeButton setTitle:@"Close" forState:UIControlStateNormal];
        
        [closeButton setBackgroundColor:[UIColor blueColor]];
        [closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [[infovc view] addSubview:closeButton];
        
        [[appDelegate window] addSubview:[infovc view]];
        
        [self setInfoViewController:infovc];
    }
}

-(void) didTapMarker:(ARGeoCoordinate *) coordinate {
    NSLog(@"delegate worked click on %@", [coordinate title]);
    [self locationClicked:coordinate];
    
}

-(void) didUpdateHeading:(CLHeading *)newHeading {
 //   NSLog(@"Heading Updated");
 
}
-(void) didUpdateLocation:(CLLocation *)newLocation {
    NSLog(@"Location Updated");
    
}
-(void) didUpdateOrientation:(UIDeviceOrientation) orientation {
    NSLog(@"Orientation Updated");
    
    if (orientation == UIDeviceOrientationPortrait)
        NSLog(@"Protrait");
}


- (void)addGeoLocationtoArray:(NSMutableArray*)locArray withLatitude:(float)latitude Longitude:(float)longitude usingName:(NSString*)label {
    
    CLLocation *tempLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    ARGeoCoordinate *tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:label];
    [locArray addObject:tempCoordinate];
}

-(NSMutableArray*) geoLocations
{
    NSMutableArray *locationArray = [[NSMutableArray alloc] init];
    [self addGeoLocationtoArray:locationArray withLatitude:39.550051 Longitude:-105.782067 usingName:@"Denver"];
    [self addGeoLocationtoArray:locationArray withLatitude:45.523875 Longitude:-122.670399 usingName:@"Portland"];
    [self addGeoLocationtoArray:locationArray withLatitude:41.879535 Longitude:-87.624333 usingName:@"Chicago"];
    [self addGeoLocationtoArray:locationArray withLatitude:30.268735 Longitude:-97.745209 usingName:@"Austin"];
    [self addGeoLocationtoArray:locationArray withLatitude:51.500152 Longitude:-0.126236 usingName:@"London"];
    [self addGeoLocationtoArray:locationArray withLatitude:48.856667 Longitude:2.350987 usingName:@"Paris"];
    [self addGeoLocationtoArray:locationArray withLatitude:55.676294 Longitude:12.568116 usingName:@"Copenhagen"];
    [self addGeoLocationtoArray:locationArray withLatitude:52.373801 Longitude:4.890935 usingName:@"Amsterdam"];
    [self addGeoLocationtoArray:locationArray withLatitude:40.756054 Longitude:-73.986951 usingName:@"New York City"];
    [self addGeoLocationtoArray:locationArray withLatitude:45.545447 Longitude:-73.639076 usingName:@"Montreal"];
    [self addGeoLocationtoArray:locationArray withLatitude:32.78 Longitude:-117.15 usingName:@"San Diego"];
    [self addGeoLocationtoArray:locationArray withLatitude:53.566667 Longitude:-113.516667 usingName:@"Edmonton"];
    [self addGeoLocationtoArray:locationArray withLatitude:19.26 Longitude:-99.8 usingName:@"Mexico City"];
    [self addGeoLocationtoArray:locationArray withLatitude:47.620973 Longitude:-122.347276 usingName:@"Seattle"];
   
    return locationArray;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[self DebugModeSwitch] setOn:NO animated:YES];
    [[self ScaleOnDistance] setOn:YES animated:YES];
    [[ContentManager sharedContentManager] setDebugMode:[[self DebugModeSwitch] isOn]];
    [[ContentManager sharedContentManager] setScaleOnDistance:[[self ScaleOnDistance] isOn]];
}

- (void)viewDidUnload
{
    [self setDebugModeSwitch:nil];
    [self setScaleOnDistance:nil];

    [self setArView:nil];
    [super viewDidUnload];
    
    if (arc != nil)
        arc = nil;
    
    if ([self infoViewController] != nil) 
        [self setInfoViewController:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end