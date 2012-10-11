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

    RMMapBoxSource *interactiveSource = [[RMMapBoxSource alloc] initWithReferenceURL:[NSURL URLWithString:@"http://a.tiles.mapbox.com/v3/mapbox.geography-class.json"]];

    RMMapView *mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:interactiveSource];

    mapView.delegate = self;
    
    mapView.zoom = 2;
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    mapView.adjustTilesForRetinaDisplay = YES;
    
    mapView.viewControllerPresentingAttribution = self;

    [self.view addSubview:mapView];
}

#pragma mark -

- (void)singleTapOnMap:(RMMapView *)mapView at:(CGPoint)point
{
    if ([self.view.subviews count] == 1)
    {
        id source = mapView.tileSource;

        if ([source conformsToProtocol:@protocol(RMInteractiveSource)] && [(id <RMInteractiveSource>)source supportsInteractivity])
        {
            source = (id <RMInteractiveSource>)source;

            NSString *formattedOutput = [source formattedOutputOfType:RMInteractiveSourceOutputTypeFull 
                                                             forPoint:point 
                                                            inMapView:mapView];

            if ( ! formattedOutput || ! [formattedOutput length])
                formattedOutput = [source formattedOutputOfType:RMInteractiveSourceOutputTypeTeaser 
                                                       forPoint:point 
                                                      inMapView:mapView];

            if (formattedOutput && [formattedOutput length])
            {
                mapView.userInteractionEnabled = NO;

                CGRect frame = CGRectMake(0, 0, 200, 140);

                UIWebView *webView = [[UIWebView alloc] initWithFrame:frame];

                [webView loadHTMLString:formattedOutput baseURL:nil];

                webView.layer.borderColor = [[UIColor blackColor] CGColor];
                webView.layer.borderWidth = 2.0;

                webView.userInteractionEnabled = NO;

                [self.view addSubview:webView];

                webView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                webView.center    = point;
                webView.alpha     = 0.0;

                [UIView animateWithDuration:0.5
                                 animations:^(void)
                                 {
                                     webView.transform = CGAffineTransformIdentity;
                                     webView.center    = mapView.center;
                                     webView.alpha     = 1.0;
                                 }
                                 completion:^(BOOL finished)
                                 {
                                     [UIView animateWithDuration:0.5
                                                           delay:2.0
                                                         options:UIViewAnimationCurveEaseInOut
                                                      animations:^(void)
                                                      {
                                                          webView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                                                          webView.center    = point;
                                                          webView.alpha     = 0.0;
                                                      }
                                                      completion:^(BOOL finished)
                                                      {
                                                          [webView removeFromSuperview];

                                                          mapView.userInteractionEnabled = YES;
                                                      }];
                                 }];
            }
        }
    }
}

@end