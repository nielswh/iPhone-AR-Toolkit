//
//  ARKitDemoAppDelegate.m
//  ARKitDemo using the ARKit
//
//  Created by Niels Hansen on 9/11/2011.
//  Copyright Agilite Software 2013. All rights reserved.
//

#import "ARKitDemoAppDelegate.h"
#import "MainViewController.h"

@implementation ARKitDemoAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	
	MainViewController *vc = [[MainViewController alloc] init];
    [self setViewController:vc];
        
     [self.window setRootViewController:vc];
    [window makeKeyAndVisible];
}

- (void)dealloc
{
    
}



@end
