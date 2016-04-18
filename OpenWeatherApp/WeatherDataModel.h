//
//  WeatherDataModel.h
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 15/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 
 @file: WeatherDataModel.h
 @author: Anand V Reddy
 @copyright: 2016 Anand V Reddy.
 
 @brief:Data model class which helps in achiving Model-View-Controller Design pattern
 
 @version: 0.1
 */

#define kOpenWeatherMapBaseURL @"http://api.openweathermap.org/data"
#define kOpenWeatherMapVersion @"2.5"

/*!
 
 @class: WeatherDataModel
 
 @brief: Main class used to store all weather related data
 
 @discussion: 
 
 @superclass: NSObject
 
 @classdesign: Model class of Model-View-Controller
 */


@interface WeatherDataModel : NSObject

@property (nonatomic) NSString *cityName;
@property (nonatomic) NSString *lon;
@property (nonatomic) NSString *lat;
@property (nonatomic) NSString *country;
@property (nonatomic) NSString *cityId;

@property (nonatomic) NSNumber *temperature;
@property (nonatomic) NSNumber *tempHigh;
@property (nonatomic) NSNumber *tempLow;
@property (nonatomic) NSNumber *humidity;

@property (nonatomic) NSString *icon;
@property (nonatomic) NSString *condition;

@property (nonatomic) NSNumber *date;

+ (NSNumber *) tempToCelcius:(NSNumber *) tempKelvin;
+ (NSNumber *) tempToFahrenheit:(NSNumber *) tempKelvin;
+ (NSDate *) convertToDate:(NSNumber *) num;

- (void)resetData;

@end

/*!
 
 @class: ForecastDataModel
 
 @brief: Main class used to store all weather forecast data
 
 @discussion:
 
 @superclass: NSObject
 
 @classdesign: Model class of Model-View-Controller
 */


@interface ForecastDataModel : NSObject

// NSMutableArray of NSDictionary of TempData, Weatherdata, DateTime & Humidity
@property (nonatomic) NSMutableArray* dateData;
@property (nonatomic) NSMutableArray* hourlyTempData;
@property (nonatomic) NSMutableArray* hourlyWeatherData;
@property (nonatomic) NSMutableArray* hourlyHumidityData;

@property (nonatomic) int firstDayItemsCount;

- (void)initialiseArrayData;

@end