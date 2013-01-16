//
//  InteractiveLayerViewController.m
//  MapBox Example
//
//  Created by Justin Miller on 4/5/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "InteractiveLayerViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation InteractiveLayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    RMMapBoxSource *interactiveSource = [[RMMapBoxSource alloc] initWithMapID:@"examples.map-zmy97flj"];

    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:interactiveSource];

    mapView.delegate = self;
    
    mapView.zoom = 2;
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    mapView.adjustTilesForRetinaDisplay = YES; // these tiles aren't designed specifically for retina, so make them legible
    
    [self.view addSubview:mapView];
}

#pragma mark -

- (void)singleTapOnMap:(RMMapView *)mapView at:(CGPoint)point
{
    [mapView removeAllAnnotations];

    RMMBTilesSource *source = (RMMBTilesSource *)mapView.tileSource;

    if ([source conformsToProtocol:@protocol(RMInteractiveSource)] && [source supportsInteractivity])
    {
        NSString *formattedOutput = [source formattedOutputOfType:RMInteractiveSourceOutputTypeFull // try for full-length first
                                                         forPoint:point 
                                                        inMapView:mapView];

        if ( ! formattedOutput || ! [formattedOutput length])
        {
            formattedOutput = [source formattedOutputOfType:RMInteractiveSourceOutputTypeTeaser // else try for a teaser
                                                   forPoint:point
                                                  inMapView:mapView];
        }

        if (formattedOutput && [formattedOutput length])
        {
            NSUInteger startOfCountryName = ([formattedOutput rangeOfString:@"<strong>"].location + [@"<strong>" length]);
            NSUInteger endOfCountryName   = [formattedOutput rangeOfString:@"</strong>"].location;

            NSRange rangeOfCountryName = NSMakeRange(startOfCountryName, endOfCountryName - startOfCountryName);

            NSString *countryName = [formattedOutput substringWithRange:rangeOfCountryName];

            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:[mapView pixelToCoordinate:point] andTitle:countryName];

            [mapView addAnnotation:annotation];

            [mapView selectAnnotation:annotation animated:YES];
        }
    }
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    return [[RMMarker alloc] initWithMapBoxMarkerImage:@"embassy"];
}

@end