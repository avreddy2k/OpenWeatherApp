//
//  WeatherDataManager.m
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 15/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import "WeatherDataManager.h"


@implementation WeatherDataManager
{
    NSURLSession* urlSession;
    WeatherDataModel* weatherDataModel;
    ForecastDataModel* forecastData;
}

@synthesize weatherDelegate, forecastDelegate;

- (instancetype)initPrivate
{
    if (self = [super init])
    {
    }
    return self;
}

- (void)setWeatherDataModel:(WeatherDataModel*)dataModel
{
    weatherDataModel = dataModel;
}

- (void)setForecastDataModel:(ForecastDataModel*)dataModel
{
    forecastData = dataModel;
}


/*!
 
 @brief: Static funcion for creating single instance of the Data manager class
 
 @discussion:
 
 @param: None
 
 @return: Single instance of WeatherDataManager
 
 */
+ (WeatherDataManager*)sharedInstance
{
    static WeatherDataManager* instance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate,
    ^{
        instance = [[WeatherDataManager alloc]initPrivate];
    }
                  );
    return instance;
}


/*!
 
 @brief: Function for getting current weather values from OpenWeatherApp.org
 
 @discussion:This function uses OpenWeatherMap API for getting current weather data using geographic co-ordinates.
             Function application is making use of NSURLSession and NSURLSessionDataTask.
             NSURLSessionDataTask's completionHandler gets called inside other worker thread once the data is succesfully got from server.
             Error value is populated in case of any error
             Response has its corresponing response code
 
 @param: lat: Latitude of location
 @param: lon: Longitute of location
 
 @return: none
 
 */
- (void)fetchWeatherDataForLatitude:(NSString*)lat Longitude:(NSString*)lon
{
    if (!urlSession)
    {
        urlSession = [NSURLSession sharedSession];
    }
    
    
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/weather?lat=%@&lon=%@", kOpenWeatherMapBaseURL, kOpenWeatherMapVersion,lat,lon];
    NSLog(@"OpenWeatherURL %@", urlString);
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url
                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
    {
        
        // This code does not exceute in main UI thread
        if ([response respondsToSelector:@selector(statusCode)])
        {
            NSInteger errorCode = [(NSHTTPURLResponse *) response statusCode];
            if (errorCode != 200)
            {
                NSLog(@"Error returned %lu", (long)errorCode);
                return;
            }
        }

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSLog(@"test weather %@", json);
        
        [self setWeatherDataValues:json];

    }];
    
    [dataTask setTaskDescription:@"weatherDataDownload"];
    [dataTask resume];

    
}

/*!
 
 @brief: From the NSDictionary populate all the weatherData model
 
 @discussion: After popluating weatherData model, call weatherDelegate function in main thread to update the UI in respective view controller
 
 @param: jsonD: NSDictionary containg JSON data from sever
 
 @return: none
 
 */
-(void)setWeatherDataValues:(NSDictionary*)jsonD
{
    // Get data related to city
    [weatherDataModel setCityName:[jsonD objectForKey:@"name"]];
    [weatherDataModel setCityId:[jsonD objectForKey:@"id"]];
    
    
    NSDictionary* cordDist = [jsonD objectForKey:@"coord"];
    [weatherDataModel setLat:[cordDist objectForKey:@"lat"]];
    [weatherDataModel setLon:[cordDist objectForKey:@"lon"]];
 
    NSDictionary* sysDict = [jsonD objectForKey:@"sys"];
    [weatherDataModel setCountry:[sysDict objectForKey:@"country"]];
 
    // Get data related to temp
    NSDictionary* tempData = [jsonD objectForKey:@"main"];
    [weatherDataModel setTemperature:[tempData objectForKey:@"temp"]];
    [weatherDataModel setTempHigh:[tempData objectForKey:@"temp_max"]];
    [weatherDataModel setTempLow:[tempData objectForKey:@"temp_min"]];
    [weatherDataModel setHumidity:[tempData objectForKey:@"humidity"]];

    NSArray *results = [jsonD objectForKey:@"weather"];
    if (results.count > 0)
    {
        NSDictionary* weather = results[0];
        [weatherDataModel setIcon:[weather objectForKey:@"icon"]];
        [weatherDataModel setCondition:[weather objectForKey:@"main"]];        
    }

    // Get data related to date
    [weatherDataModel setDate:[jsonD objectForKey:@"dt"]];
    
    // display the values in the view in UI Main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [weatherDelegate updateViewController];
    });


}

/*!
 
 @brief: Function for getting 5 day weather forecast date from OpenWeatherApp.org
 
 @discussion:This function uses OpenWeatherMap API for getting 5 day weather data using geographic co-ordinates.
 Function application is making use of NSURLSession and NSURLSessionDataTask.
 NSURLSessionDataTask's completionHandler gets called inside other worker thread once the data is succesfully got from server.
 Error value is populated in case of any error
 Response has its corresponing response code
 
 @return: none
 
 */- (void)fetchForecasDataForFiveDays
{
    if (!urlSession)
    {
        urlSession = [NSURLSession sharedSession];
    }
    
    if (![weatherDataModel cityId])
    {
        return;
    }
    
    NSString* urlString = [NSString stringWithFormat:@"%@/%@/forecast?lat=%@&lon=%@", kOpenWeatherMapBaseURL, kOpenWeatherMapVersion,weatherDataModel.lat,weatherDataModel.lon];
    
    NSURL* url = [NSURL URLWithString:urlString];
    
    NSURLSessionDataTask *dataTask = [urlSession dataTaskWithURL:url
                                               completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                      {
                                          
                                          if ([response respondsToSelector:@selector(statusCode)])
                                          {
                                              NSInteger errorCode = [(NSHTTPURLResponse *) response statusCode];
                                              if (errorCode == 403)
                                              {
                                                  NSLog(@"Error returned %lu", (long)errorCode);
                                              }
                                          }

                                          NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                          NSLog(@"test forcast%@", json);
                                          
                                          [self setForcastDataValues:json];
                                          
                                      }];
    
    [dataTask setTaskDescription:@"weatherForecastDownload"];
    [dataTask resume];

}

/*!
 
 @brief: Function to calculate number of readings from current day in forecast data
 
 @discussion:
 
 @param: jsonD: NSDictionary containg JSON data from sever
 
 @return: int: number of entries in first day  forecorecast data
 
 */
-(int)calculateFirstDayValuesCount:(NSDictionary*)jsonD
{
    NSArray *results = [jsonD objectForKey:@"list"];
    int firstDayItemsCount = 0;
    NSString* curDateText = nil;
    
    for (NSDictionary *result in results)
    {
        if ((!firstDayItemsCount) || ([curDateText isEqualToString:[[result objectForKey:@"dt_txt"] substringToIndex:10]]))
        {
            firstDayItemsCount++;
            curDateText = [[result objectForKey:@"dt_txt"] substringToIndex:10];
        }
        else
        {
            break;
        }
    }
    
    return firstDayItemsCount;
    
}

/*!
 
 @brief: From the NSDictionary populate all the forecastData model
 
 @discussion: After popluating forecastData model, call forecastDelegate function in main thread to update the UI in respective view controller
 
 @param: jsonD: NSDictionary containg JSON data from sever
 
 @return: none
 
 */
-(void)setForcastDataValues:(NSDictionary*)jsonD
{
    [forecastData setFirstDayItemsCount:[self calculateFirstDayValuesCount:jsonD]];
    
    // first get array of dictionary
    NSArray *results = [jsonD objectForKey:@"list"];
    
    // from list array get the following
    for (NSDictionary *result in results)
    {
        // Append date data into date array
        [forecastData.dateData addObject:[result objectForKey:@"dt"]];
        
        // get temp and humidity from one more dictionary
        NSDictionary *mainDict = [result objectForKey:@"main"];
        [forecastData.hourlyTempData addObject:[mainDict objectForKey:@"temp"]];
        [forecastData.hourlyHumidityData addObject:[mainDict objectForKey:@"humidity"]];
        
        NSArray *weatherArray = [result objectForKey:@"weather"];
        if (weatherArray.count > 0)
        {
            NSDictionary* weather = weatherArray[0];
            [forecastData.hourlyWeatherData addObject:[weather objectForKey:@"main"]];
        }
    }
    
    // display the values in the view in UI Main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [forecastDelegate updateViewController];
    });

}

@end
