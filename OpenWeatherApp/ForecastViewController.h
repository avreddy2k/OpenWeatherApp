//
//  ForecastViewController.h
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 16/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WeatherDataManager.h"
#import "WeatherDataModel.h"

/*!
 
 @file: ForecastViewController.h
 @author: Anand V Reddy
 @copyright: 2016 Anand V Reddy.
 
 @brief:Forecast view controller which is displayed when user selects any item forecast table vew in main viewcntroller
 Confirm to ForecastDataManagerDelegate delegate to update UI once Data manager gets data from OpenWeatherApp
 Confirm to UiTableViewDataSource and UITableViewDelegate of table view for creating and updating cells
 
 @version: 0.1
 */


@interface ForecastViewController : UIViewController<ForecastDataManagerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *forecastDetailTable;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) ForecastDataModel *forecastData;

-(void)setDate:(NSString*)day andSelection:(int)selCount;

@end
