//
//  ViewController.m
//  WeatherForecast-iOS
//
//  Created by Amarnath on 10/27/15.
//  Copyright (c) 2015 tcs. All rights reserved.
//

#import "ViewController.h"
#define Weather_Forecast_Url @"https://api.forecast.io/forecast/ad410f5d718dd45892a7db3ea91da4c4/"

@interface ViewController ()

@property (strong,nonatomic) NSString *locationName;
@property (nonatomic,strong) CLLocationManager *locationManager;
@property (weak, nonatomic)  IBOutlet UIImageView *weatherImageView;
@property (weak, nonatomic)  IBOutlet UILabel *titleLabel;
@property (weak, nonatomic)  IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic)  IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation ViewController

/**************************************************************
 Method Name : ViewDidLoad
 Description : Life Cycle method.
 
 **************************************************************/

#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /* Added for getting the current location */
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**************************************************************
 Method Name : GetWeatherResponse
 Description : Asynchronous API call will happen to get the weather information.
 Parameters  : The parameters we should pass here are BaseUrl,API key,latitude and longititude.
 
 **************************************************************/

#pragma mark - WebService Call

-(void)getWeatherResponse: (NSString *)urlStr success : (void (^)(NSDictionary *responseDict))success failure:(void(^)(NSError* error))failure{
    
    NSURLSession * session = [NSURLSession sharedSession];
    NSURL * url = [NSURL URLWithString: urlStr];
    
    // Asynchronously API call
    NSURLSessionDataTask * dataTask = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                       {
                                           if (error!=nil) {
                                               failure(error);
                                               
                                           } else {
                                               NSDictionary * json  = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                               NSLog(@"%@",json);
                                               success(json);
                                           }
                                       }];
    
    [dataTask resume] ;
}


/**************************************************************
 
 Method Name : Location Manager DidUpdate Location
 Description : Used to get the current location

 **************************************************************/

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    
    //CLLocation *location1=[[CLLocation alloc]initWithLatitude:-33.8830555556 longitude:151.216666667];
    
    /* Used to get the location name */
    
    [self getAddressFromLatitudeLongitude:location];
    
    NSString *coordinates = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    NSString *urlString=[NSString stringWithFormat:@"%@%@",Weather_Forecast_Url,coordinates];
    
    /* Service Call for getting the weather information based on the user location*/
    
    [self getWeatherResponse:urlString success:^(NSDictionary *responseDict) {
        NSLog(@"");
        
        _titleLabel.text=_locationName;
        
        NSDictionary *currentlyDict = [responseDict objectForKey:@"currently"];
        NSString *temperature = [[currentlyDict valueForKey:@"apparentTemperature"] stringValue];
        NSString *weatherDescription = [currentlyDict valueForKey:@"summary"];
        NSString *weatherStatus = [currentlyDict valueForKey:@"icon"];
        
        _temperatureLabel.text= [NSString stringWithFormat:@"%.2f °C / %@",[[self farenheitToCelsius:temperature] floatValue], weatherDescription];
        
        /* Note: I could have used Switch case here but the Switch is not allowed for String comparison*/
        
        if ([weatherStatus isEqualToString:kClearDayStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"ClearDay"];
        }else if ([weatherStatus isEqualToString:kClearNightStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"ClearNight"];
        }else if ([weatherStatus isEqualToString:kRainyStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"Rainy"];
        }else if ([weatherStatus isEqualToString:kSnowStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"Snow"];
        }else if ([weatherStatus isEqualToString:kSleetStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"Sleet"];
        }else if ([weatherStatus isEqualToString:kWindStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"wind"];
        }else if ([weatherStatus isEqualToString:kFogStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"Fog"];
        }else if ([weatherStatus isEqualToString:kCloudyStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"Cloudy"];
        }else if ([weatherStatus isEqualToString:kPartlyCloudyDayStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"PartlyCloudy"];
        }else if ([weatherStatus isEqualToString:kPartlyCloudyNightStr]) {
            _weatherImageView.image = [UIImage imageNamed:@"PartlyCloudyNight"];
        }
        
        
        [_activityIndicator stopAnimating];
    } failure:^(NSError *error) {
        [_activityIndicator stopAnimating];
        UIAlertView *alertView= [[UIAlertView alloc] initWithTitle:@"" message:@"Please try again later" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
        
    }];
    [self.locationManager stopUpdatingLocation];
    
}

/**************************************************************
 
 Method Name : Location Manager DidChangeAuthorizationStatus
 Description : Used to get the permission from user to get the location access.
 
 **************************************************************/
- (void)locationManager:(CLLocationManager*)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusNotDetermined: {
            NSLog(@"User still thinking..");
        } break;
        case kCLAuthorizationStatusDenied: {
            NSLog(@"User denied you");
        } break;
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways: {
            [_locationManager startUpdatingLocation]; //Will update location immediately
        } break;
        default:
            break;
    }
}

/**************************************************************
 
 Method Name :GetAddressFromLatitudeAndLongitude
 Description :Used to get the location address.
 Parameters  :Current Location
 
 **************************************************************/

#pragma mark - GeoCoding

- (void) getAddressFromLatitudeLongitude:(CLLocation *)bestLocation
{
    NSLog(@"%f %f", bestLocation.coordinate.latitude, bestLocation.coordinate.longitude);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:bestLocation
                   completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error){
             NSLog(@"Geocode failed with error: %@", error);
             return;
         }
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSLog(@"placemark.ISOcountryCode %@",placemark.ISOcountryCode);
         NSLog(@"locality %@",placemark.locality);
         NSLog(@"postalCode %@",placemark.postalCode);
         NSLog(@"region %@ subAdministrativeArea =%@",placemark.region, placemark.subAdministrativeArea);
         _locationName=[NSString stringWithFormat:@"%@, %@",placemark.locality,placemark.ISOcountryCode];
         
     }];
    
}

/**************************************************************
 
 Method Name :FarenheitToCelsius
 Description :Used to Convert the temperature from farenheit to celsius
 Parameters  :Temperature
 
 **************************************************************/

#pragma mark - Converting Methods

-(NSString *)farenheitToCelsius:(NSString*)farenheit{
    double farenheitValue = [farenheit doubleValue];
    double celsiusValue = (farenheitValue-32)/1.8;
    NSString *celsius = [NSString stringWithFormat:@"%f", celsiusValue];
    return celsius;
}

/**************************************************************
 
 Method Name :Refresh
 Description :Refresh the current location weather information
 
 **************************************************************/

#pragma mark - Refresh Method

- (IBAction)clickToRefresh:(id)sender {
    [_activityIndicator startAnimating];
    [_locationManager startUpdatingLocation];
}

@end
