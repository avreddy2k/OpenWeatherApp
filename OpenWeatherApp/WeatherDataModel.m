//
//  WeatherDataModel.m
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 15/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import "WeatherDataModel.h"


@implementation WeatherDataModel

@synthesize cityName, lon, lat, country, cityId, temperature, tempHigh, tempLow, humidity, icon, condition, date;

/*!
 
 @brief: Function to convert temperature into celcius
 
 @discussion:
 
 @param: Temperatire in Kelvin
 
 @return: Temperature in Celcius
 
 */
+ (NSNumber *) tempToCelcius:(NSNumber *) tempKelvin
{
    return @(tempKelvin.floatValue - 273.15);
}

/*!
 
 @brief: Function to convert temperature into Fahrenheit
 
 @discussion:
 
 @param: Temperatire in Kelvin
 
 @return: Temperature in Fahrenheit
 
 */
+ (NSNumber *) tempToFahrenheit:(NSNumber *) tempKelvin
{
    return @((tempKelvin.floatValue * 9/5) - 459.67);
}

/*!
 
 @brief: Function to convert date from number to NSdate
 
 @discussion:
 
 @param: num: seconds since 1970
 
 @return: Date returned in NSDate format
 
 */
+ (NSDate *) convertToDate:(NSNumber *) num
{
    return [NSDate dateWithTimeIntervalSince1970:num.intValue];
}

- (void)resetData
{
    cityName = nil;
    lon = nil;
    lat = nil;
    country = nil;
    cityId = nil;
    temperature = nil;
    tempHigh = nil;
    tempLow = nil;
    humidity = nil;
    icon = nil;
    condition = nil;
    date = nil;
}

@end


@implementation ForecastDataModel : NSObject

@synthesize hourlyTempData, hourlyWeatherData, dateData, hourlyHumidityData, firstDayItemsCount;

- (void)initialiseArrayData
{
    dateData = [[NSMutableArray alloc]init];
    hourlyTempData = [[NSMutableArray alloc]init];
    hourlyWeatherData = [[NSMutableArray alloc]init];
    hourlyHumidityData = [[NSMutableArray alloc]init];
}

@end