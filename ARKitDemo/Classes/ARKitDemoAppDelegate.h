//
//  ARKitDemoAppDelegate.h
//  ARKitDemo using the iPhoneAugmentedRealityLib
//
//  Created by Niels Hansen on 1/21/2010.
//  Copyright Agilite Software 2013. All rights reserved.
//


@class MainViewController;

@interface ARKitDemoAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *viewController;

@end

