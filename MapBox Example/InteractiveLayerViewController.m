//
//  InteractiveLayerViewController.m
//  MapBox Example
//
//  Created by Justin Miller on 4/5/12.
//  Copyright (c) 2012 MapBox / Development Seed. All rights reserved.
//

#import "InteractiveLayerViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "NSData+Base64.h"

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
        NSString *formattedOutput = [source formattedOutputOfType:RMInteractiveSourceOutputTypeTeaser
                                                         forPoint:point 
                                                        inMapView:mapView];

        if (formattedOutput && [formattedOutput length])
        {
            // parse the country name out of the content
            //
            NSUInteger startOfCountryName = [formattedOutput rangeOfString:@"<strong>"].location + [@"<strong>" length];
            NSUInteger endOfCountryName   = [formattedOutput rangeOfString:@"</strong>"].location;

            NSString *countryName = [formattedOutput substringWithRange:NSMakeRange(startOfCountryName, endOfCountryName - startOfCountryName)];

            // parse the flag image out of the content
            //
            NSUInteger startOfFlagImage = [formattedOutput rangeOfString:@"base64,"].location + [@"base64," length];
            NSUInteger endOfFlagImage   = [formattedOutput rangeOfString:@"\" style"].location;

            UIImage *flagImage = [UIImage imageWithData:[NSData dataFromBase64String:[formattedOutput substringWithRange:NSMakeRange(startOfFlagImage, endOfFlagImage)]]];

            RMAnnotation *annotation = [RMAnnotation annotationWithMapView:mapView coordinate:[mapView pixelToCoordinate:point] andTitle:countryName];

            annotation.userInfo = flagImage;

            [mapView addAnnotation:annotation];

            [mapView selectAnnotation:annotation animated:YES];
        }
    }
}

- (RMMapLayer *)mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    RMMarker *marker = [[RMMarker alloc] initWithMapBoxMarkerImage:@"embassy"];

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 32)];

    imageView.contentMode = UIViewContentModeScaleAspectFit;

    imageView.image = annotation.userInfo;

    marker.leftCalloutAccessoryView = imageView;

    marker.canShowCallout = YES;

    return marker;
}

@end