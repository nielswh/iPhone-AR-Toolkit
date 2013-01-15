//
//  MainViewController.h
//  ARKitDemo
//
//  Created by Niels Hansen on 9/11/11.
//  Copyright 2013 Agilite Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ARKit.h"

@interface MainViewController : UIViewController<ARLocationDelegate,ARDelegate,ARMarkerDelegate>

-(IBAction) displayAR:(id) sender;
- (IBAction)displayARFullScreen:(id)sender;

@property (nonatomic, retain) UIViewController *infoViewController;
@property (retain, nonatomic) IBOutlet UISwitch *ScaleOnDistance;
@property (retain, nonatomic) IBOutlet UISwitch *DebugModeSwitch;

@property (weak, nonatomic) IBOutlet UIView *arView;
@end
