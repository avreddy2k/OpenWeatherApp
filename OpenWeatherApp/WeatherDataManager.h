//
//  WeatherDataManager.h
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 15/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherDataModel.h"

/*!
 
 @@protocol: WeatherDataManagerDelegate
 
 @brief: This Protocol is used update main view controller with curren weather data
 
 @discussion:Protocol is used so that Data manager class does not include ViewController in it.
             By doing so we are avoid circlualr dependencies and this is iOS very good Design Pattern called Delegate Design Pattern
 
 @superclass: NSObject
 */
@protocol WeatherDataManagerDelegate<NSObject>

- (void)updateViewController;

@end


/*!
 @@protocol: ForecastDataManagerDelegate
 
 @brief: This Protocol is used update forecast view controller with curren weather forecast data
 
 @discussion:Protocol is used so that Data manager class does not include ViewController in it.
 By doing so we are avoid circlualr dependencies and this is iOS very good Design Pattern called Delegate Design Pattern
 
 @superclass: NSObject
 */
@protocol ForecastDataManagerDelegate<NSObject>

- (void)updateViewController;

@end


/*!
 
 @class: WeatherDataManager
 
 @brief: Main class used to fetch data from OpenWeatherMap.org
 
 @discussion: This class fetches current weather data and forecast weather data from OpenWeatherMap.org
 
 @superclass: NSObject
 
 @classdesign:  WeatherDataManager class follows Singleton Design pattern, where at any time only one instance of this class exits.
                Also this class conforms to delegates NSURLSessionDelegate and NSURLSessionDataDelegate for updating respective view controller
 */

@interface WeatherDataManager : NSObject <NSURLSessionDelegate, NSURLSessionDataDelegate>

@property (nonatomic, weak) id <WeatherDataManagerDelegate> weatherDelegate;
@property (nonatomic, weak) id <ForecastDataManagerDelegate> forecastDelegate;

+(WeatherDataManager*) sharedInstance;

// These are declared so that any class cannot instantiate WeatherDataManager class
- (instancetype) init __attribute__((unavailable("Use +[WeatherDataManager sharedInstance] instead")));
+ (instancetype) new __attribute__ ((unavailable("Use +[WeatherDataManager sharedInstance] instead")));

- (void)fetchWeatherDataForLatitude:(NSString*)lat Longitude:(NSString*)lon;
- (void)fetchForecasDataForFiveDays;
- (void)setWeatherDataModel:(WeatherDataModel*)dataModel;
- (void)setForecastDataModel:(ForecastDataModel*)dataModel;


@end
