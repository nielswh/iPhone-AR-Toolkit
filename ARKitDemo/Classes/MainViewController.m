//
//  MainViewController.m
//  ARKitDemo
//
//  Modified by Niels Hansen on 10/2/11.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import "ARKitDemoAppDelegate.h"
#import "MainViewController.h"
#import "ContentManager.h"
#import "AugmentedRealityController.h"
#import "GEOLocations.h"
#import "MarkerView.h"
#import "ContentManager.h"
#import "FullScreenARViewController.h"

@interface MainViewController  () {
   AugmentedRealityController  *arc;
}

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


-(NSMutableArray*) geoLocations
{
    
    NSMutableArray *locationArray = [[NSMutableArray alloc] init];
    ARGeoCoordinate *tempCoordinate;
    CLLocation        *tempLocation;
    
    tempLocation = [[CLLocation alloc] initWithLatitude:39.550051 longitude:-105.782067];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Denver"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:45.523875 longitude:-122.670399];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Portland"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:41.879535 longitude:-87.624333];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Chicago"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:30.268735 longitude:-97.745209];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Austin"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:51.500152 longitude:-0.126236];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"London"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:48.856667 longitude:2.350987];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Paris"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:55.676294 longitude:12.568116];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Copenhagen"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:52.373801 longitude:4.890935];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Amsterdam"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:19.611544 longitude:-155.665283];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Hawaii"];
    tempCoordinate.inclination = M_PI/30;
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:40.756054 longitude:-73.986951];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"New York City"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:42.35892 longitude:-71.05781];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Boston"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:49.817492 longitude:15.472962];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Czech Republic"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:53.41291 longitude:-8.24389];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Ireland"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:38.892091 longitude:-77.024055];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Washington, DC"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:45.545447 longitude:-73.639076];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Montreal"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:32.78 longitude:-117.15];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"San Diego"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:-40.900557 longitude:174.885971];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Munich"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:33.5033333 longitude:-117.126611];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Temecula"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:19.26 longitude:-99.8];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Mexico City"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:53.566667 longitude:-113.516667];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Edmonton"];
    [locationArray addObject:tempCoordinate];
    
    tempLocation = [[CLLocation alloc] initWithLatitude:47.620973 longitude:-122.347276];
    tempCoordinate = [ARGeoCoordinate coordinateWithLocation:tempLocation locationTitle:@"Seattle"];
    [locationArray addObject:tempCoordinate];
    
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