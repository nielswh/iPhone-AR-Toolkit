//
//  CoordinateView.h
//  AR Kit
//
//  Created by Niels W Hansen on 12/31/11.
//  Copyright 2011 Agilite Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARViewProtocol.h"

@class ARGeoCoordinate;

@interface MarkerView : UIView

- (id)initForCoordinate:(ARGeoCoordinate *)coordinate withDelgate:(id<ARMarkerDelegate>) aDelegate;

@property (nonatomic,retain) ARGeoCoordinate *coordinateInfo;
@property (nonatomic, assign) id<ARMarkerDelegate> delegate;
@property (nonatomic, retain) UILabel *lblDistance;


@end
