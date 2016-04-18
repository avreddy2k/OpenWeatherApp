//
//  ViewController.h
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 14/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "WeatherDataManager.h"
#import "WeatherDataModel.h"

/*!
 
 @file: ViewController.h
 @author: Anand V Reddy
 @copyright: 2016 Anand V Reddy.
 
 @brief:Main view controller which is displayed when application is launched
 Confirm to CLLocationManagerDelegate delegate to get location co-ordinates
 Confirm to WeatherDataManagerDelegate delegate to update UI once Data manager gets data from OpenWeatherApp
 Confirm to UiTableViewDataSource and UITableViewDelegate of table view for creating and updating cells
 
 @version: 0.1
 */

@interface ViewController : UIViewController <CLLocationManagerDelegate, WeatherDataManagerDelegate, UITableViewDataSource, UITableViewDelegate>

- (void)updateViewContents;

@end

