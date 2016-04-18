//
//  ForecastViewController.m
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 16/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import "ForecastViewController.h"
#import "ForecastDetailTableViewCell.h"


/*!
 
 @class: ForecastViewController.m
 
 @brief: Main class used to display Forecast Weather data when user selects any day(row) from forecast table in main view controller
 
 @discussion:
 @superclass: UiViewController
 
 @classdesign: Standard ViewController class which confirms to following delegates
 ForecastDataManagerDelegate,
 UITableViewDataSource,
 UITableViewDelegate
 */

@implementation ForecastViewController
{
    NSString* curDate;
    int curDaySelection;
    NSDateFormatter* dateFormatter;
}

@synthesize forecastDetailTable, activityIndicator;
@synthesize forecastData;

/*!
 
 @brief: Standard funtion used to initialise view controller and sets up needed properties and instance variable
 
 @discussion: Sets up Forecastdata Model & DateFormater
 
 @param: none
 
 @return: none
 
 */

- (void)viewDidLoad
{
    [self.activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    
    forecastData = [[ForecastDataModel alloc]init];
    [forecastData initialiseArrayData];

    WeatherDataManager* weatherMgr = [WeatherDataManager sharedInstance];
    [weatherMgr setForecastDataModel:forecastData];
    [weatherMgr setForecastDelegate:self];
    [weatherMgr fetchForecasDataForFiveDays];
    
    
    NSString *dateComponents = @"H:m yyMMMdd";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale] ];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
}

/*!
 
 @brief: Function sets current day string instance variable which is used to display forecast detail table header.
         It also gets the current selection made by the user in main view controller
 
 @discussion:
 
 @param: day: Current day in string
 
 @return: selCOunt: Current selection on main table view controller
 
 */
-(void)setDate:(NSString*)day andSelection:(int)selCount
{
    curDate = day;
    curDaySelection = selCount;
}


/*!
 
 @brief: Delegate function called from WeatherDataManager to update view controller
 
 @discussion: Stops activity indicator and reloads the table view
 
 @param: none
 
 @return: none
 
 */
-(void) updateViewController
{
    [self.activityIndicator stopAnimating];
    activityIndicator.hidden = YES;

    [forecastDetailTable reloadData];
}


#pragma mark - tableview delegate
/*!
 
 @brief: Delegate function called from table view controller to return number of sections
 
 @discussion:
 
 @param: none
 
 @return: none
 
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*!
 
 @brief: Delegate function called from table view controller to return header for the table
 
 @discussion:
 
 @param: none
 
 @return: none
 
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Detailed Forecast for the day %@", curDate];
}

/*!
 
 @brief: Delegate function called from table view controller to return number of rows
 
 @discussion:
 
 @param: none
 
 @return: none
 
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!forecastData.hourlyWeatherData.count)
    {
        return 0;
    }
        
    if (curDaySelection == 0)
    {
        return forecastData.firstDayItemsCount;
    }
    else
    {
        return 8;
    }
}

/*!
 
 @brief: Delegate function called from table view controller for creating each row of the table
 
 @discussion: Use CellIdentifier to check if cell is already created, use it instead of creating new cell everytime.
              Assumption here is that each day has 8 entries, except the current day.
              Depending on this assumtion we generate the index for the forecastData which has all data from server
 
 @param: tableView: Table view instance
 @param: indexPath: index for which row needs to be created
 
 @return: none
 
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ForecastDetailCell";
    
    ForecastDetailTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ForecastDetailTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Assumption here is each day has 8 entries of data except firt day
    int itemInArray;
    if (curDaySelection == 0)
    {
        itemInArray = (int)indexPath.row;
    }
    else
    {
        itemInArray = forecastData.firstDayItemsCount + ((curDaySelection-1)*8) + (int)indexPath.row;
    }
    
    NSNumber* temperature = [WeatherDataModel tempToCelcius:[forecastData.hourlyTempData objectAtIndex:itemInArray]];
    NSString* tempValue = [NSString stringWithFormat:@"%d\u00B0C", temperature.intValue];
    [cell.tempLabel setText:tempValue];
    
    [cell.weatherLabel setText:[forecastData.hourlyWeatherData objectAtIndex:itemInArray]];
    
    NSNumber* humidityNumber = [forecastData.hourlyHumidityData objectAtIndex:itemInArray];
    NSString* humidityString = [NSString stringWithFormat:@"Humidity %d", humidityNumber.intValue];
    [cell.humidityLabel setText:humidityString];

    NSNumber *curDayTime = [forecastData.dateData objectAtIndex:itemInArray];
    NSString *dateString = [dateFormatter stringFromDate:[WeatherDataModel convertToDate:curDayTime]];
    [cell.timeLabel setText:[NSString stringWithFormat:@"At time %@", [dateString substringFromIndex:10]]];
    

    return cell;
    
}


@end
