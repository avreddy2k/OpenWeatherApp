//
//  ForecastTableViewCell.h
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 16/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 
 @file: ForecastTableViewCell.h
 @author: Anand V Reddy
 @copyright: 2016 Anand V Reddy.
 
 @brief:ForecastTable's cell view
 
 @version: 0.1
 */

/*!
 
 @class: ForecastTableViewCell
 
 @brief: Cell class for ForecastTable
 
 @discussion:
 
 @superclass: UITableViewCell
 
 */


@interface ForecastTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;

@end
