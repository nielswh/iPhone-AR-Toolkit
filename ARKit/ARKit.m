//
//  ARKit.m
//  AR Kit
//
//  Modifed by Niels Hansen 11/20/11.
//  Copyright 2013 Agilite Software. All rights reserved.
//

#import "ARKit.h"

@implementation ARKit

+(BOOL)deviceSupportsAR{
    
    // Go thru and see if the device supports Video Capture.
    NSArray *devices = [AVCaptureDevice devices];

    BOOL suportsVideo = NO;
    
    if (devices != nil && [devices count] > 0) {
        for (AVCaptureDevice *device in devices) {
            if ([device hasMediaType:AVMediaTypeVideo]) {
                suportsVideo = YES;
                break;
            }
        }
    }
    
    if (!suportsVideo)
        return NO;
   
	//TODO: Check to see if Device supports the Gyroscope (iPhone4 and higher)

	if(![CLLocationManager headingAvailable]){
		return NO;
	}
	
	return YES;
}
@end
