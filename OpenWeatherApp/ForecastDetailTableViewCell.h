//
//  ForecastDetailTableViewCell.h
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 16/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 
 @file: ForecastDetailTableViewCell.h
 @author: Anand V Reddy
 @copyright: 2016 Anand V Reddy.
 
 @brief:ForecastDetailTable's cell view
 
 @version: 0.1
 */

/*!
 
 @class: ForecastDetailTableViewCell
 
 @brief: Cell class for ForecastDetailTable
 
 @discussion:
 
 @superclass: UITableViewCell
 
 */

@interface ForecastDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;

@end
