//
//  CoordinateView.m
//  ARKitDemo
//
//  Modified by Niels W Hansen on 12/31/11.
//  Copyright 2013 Agilite Software. All rights reserved.
//

#import "MarkerView.h"

#define BOX_WIDTH 150
#define BOX_HEIGHT 100
#define BOX_GAP 10
#define BOX_ALPHA 0.8
#define LABEL_HEIGHT 20.0

@implementation MarkerView

@synthesize coordinateInfo;
@synthesize delegate;
@synthesize lblDistance;

- (id)initForCoordinate:(ARGeoCoordinate *)coordinate withDelgate:(id<ARMarkerDelegate>) aDelegate
{
    
	[self setCoordinateInfo:coordinate];
    [self setDelegate:aDelegate];
    
	CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
	
	if ((self = [super initWithFrame:theFrame])) {
        
        [self setUserInteractionEnabled:YES]; // Allow for touches
        
		UILabel *titleLabel	= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, 20.0)];
		
		[titleLabel setBackgroundColor: [UIColor colorWithWhite:.3 alpha:BOX_ALPHA]];
		[titleLabel setTextColor:		[UIColor whiteColor]];
		[titleLabel setTextAlignment:	NSTextAlignmentCenter];
		[titleLabel setText:			[coordinate title]];
		[titleLabel sizeToFit];
 
		[titleLabel setFrame: CGRectMake(BOX_WIDTH / 2.0 - [titleLabel bounds].size.width / 2.0 - 4.0, 0, 
                                         [titleLabel bounds].size.width + 8.0, [titleLabel bounds].size.height + 8.0)];
        
        UILabel *distLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, BOX_WIDTH, LABEL_HEIGHT)];
		
		[distLbl setBackgroundColor: [UIColor colorWithWhite:.3 alpha:BOX_ALPHA]];
		[distLbl setTextColor:		[UIColor whiteColor]];
		[distLbl setTextAlignment:	NSTextAlignmentCenter];
		[distLbl setText:			[NSString stringWithFormat:@"%f", [coordinate distanceFromOrigin]]];
		[distLbl sizeToFit];
        
		[distLbl setFrame: CGRectMake(BOX_WIDTH / 2.0 - [titleLabel bounds].size.width / 2.0 - 4.0, 
                                      [distLbl bounds].size.height, 
                                      [titleLabel bounds].size.width + 8.0, 
                                      [distLbl bounds].size.height + 8.0)];
        
        
		UIImageView *pointView	= [[UIImageView alloc] initWithFrame:CGRectZero];
		[pointView setImage:[UIImage imageNamed:@"location.png"]];
        
		[pointView setFrame:	CGRectMake((int)(BOX_WIDTH / 2.0 - [pointView image].size.width / 2.0), 
                                           (int)(BOX_HEIGHT / 2.0 - [pointView image].size.height / 2.0), 
                                           [pointView image].size.width, 
                                           [pointView image].size.height)];
		
		[self addSubview:titleLabel];
        [self addSubview:distLbl];
        
        [self setLblDistance:distLbl];

		[self addSubview:pointView];
		[self setBackgroundColor:[UIColor clearColor]];
	}
	
    return self;
}

-(void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [[self lblDistance] setText:[NSString stringWithFormat:@"%.2f km", [[self coordinateInfo] distanceFromOrigin]/1000.0f]];
    
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%@ was touched!",[[self coordinateInfo] title]);
    [delegate didTapMarker:[self coordinateInfo]];

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    
    CGRect theFrame = CGRectMake(0, 0, BOX_WIDTH, BOX_HEIGHT);
    
    if(CGRectContainsPoint(theFrame, point))
        return YES; // touched the view;
    
    return NO;
}


- (void)dealloc
{

}


@end
