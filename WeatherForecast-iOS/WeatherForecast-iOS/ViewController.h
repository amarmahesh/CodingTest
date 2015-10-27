//
//  ViewController.h
//  WeatherForecast-iOS
//
//  Created by Amarnath on 10/27/15.
//  Copyright (c) 2015 tcs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

static NSString *const kClearDayStr   = @"clear-day";
static NSString *const kClearNightStr = @"clear-night";
static NSString *const kRainyStr      = @"rain";
static NSString *const kSnowStr       = @"snow";
static NSString *const kSleetStr      = @"sleet";
static NSString *const kWindStr       = @"wind";
static NSString *const kFogStr        = @"fog";
static NSString *const kCloudyStr     = @"cloudy";
static NSString *const kPartlyCloudyDayStr     = @"partly-cloudy-day";
static NSString *const kPartlyCloudyNightStr   = @"partly-cloudy-night";

@interface ViewController : UIViewController<CLLocationManagerDelegate>


@end

