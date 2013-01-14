//
//  ARKitDemoAppDelegate.h
//  ARKitDemo using the iPhoneAugmentedRealityLib
//
//  Created by Niels Hansen on 1/21/2010.
//  Copyright Niels Hansen 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARKit.h"

@class MainViewController;

@interface ARKitDemoAppDelegate : NSObject <UIApplicationDelegate> {

}


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *viewController;

@end

