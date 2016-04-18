//
//  ViewController.m
//  OpenWeatherApp
//
//  Created by Reddy, Anand V. on 14/04/16.
//  Copyright © 2016 Anand V Reddy. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"
#import "ForecastTableViewCell.h"
#import "ForecastViewController.h"

#define kTableViewNumberofRows 5

/*!

 @class: ViewController
 
 @brief: Main class used to display Weather data when the application is launched
 
 @discussion: After application launch this class does teh following
        1. Checks for network conectivity and displays alert view if not connected
        2. If network available then starts Location Manager services to get the current location of the dveice
        3. After getting location, sends requests for fetching weather data for that location
        4. After weather data is fetched updates the UI with current values
 
 @superclass: UiViewController
 
 @classdesign: Standard ViewController class which confirms to following delegates
        CLLocationManagerDelegate, 
        WeatherDataManagerDelegate, 
        UITableViewDataSource, 
        UITableViewDelegate
 */
@interface ViewController ()
{
    // Some instance variables which are not property
    UIAlertController* alert;
    BOOL isOnline;
    CLLocationManager *locationManager;
    BOOL fetchedLocation;
    NSDateFormatter *dateFormatter;
    ForecastViewController *forecastViewController;
}

- (IBAction)onRefresh:(id)sender;

@property (nonatomic) Reachability *hostReachability;
@property (nonatomic) NSString *curLogitute;
@property (nonatomic) NSString *curLatitude;
@property (nonatomic) WeatherDataModel* weatDataModel;

@property (weak, nonatomic) IBOutlet UILabel *tempLabel;
@property (weak, nonatomic) IBOutlet UILabel *tempMinMaxLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeStampLabel;
@property (weak, nonatomic) IBOutlet UILabel *weatherLabel;
@property (weak, nonatomic) IBOutlet UILabel *humidityLabel;
@property (weak, nonatomic) IBOutlet UITableView *forecastTable;

@end


@implementation ViewController

@synthesize curLatitude, curLogitute;
@synthesize weatDataModel;
@synthesize tempLabel, tempMinMaxLabel, cityLabel, timeStampLabel, weatherLabel, humidityLabel, forecastTable;


/*!
 
 @brief: Standard funtion used to initialise view controller and sets up needed properties and instance variable
 
 @discussion: Sets up Notification observer, Weatherdata Model, LocationManager & DateFormater
 
 @param: none
 
 @return: none
 
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Observer Pattern Implementation creation
    // Observe the kNetworkReachabilityChangedNotification. When that notification is posted, the method networkConnectivityChanged will be called.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkConnectivityChanged:) name:kReachabilityChangedNotification object:nil];
    
    NSString *remoteHostName = @"www.apple.com";
    self.hostReachability = [Reachability reachabilityWithHostName:remoteHostName];
    [self.hostReachability startNotifier];
    
    // Allocate WeatherDataModel and create instance of the same
    weatDataModel = [[WeatherDataModel alloc] init];
    [weatDataModel resetData];
    
    // Allocate locationManager, assign delegate to it and start receiving the location services
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer; // as don't need fine granined accuracy
    
    // Location manager keeps on posting data, which is not needed in our case
    fetchedLocation = FALSE;
    
    // Date formater for selecting a particluar format and using it whole view
    NSString *dateComponents = @"H:m yyMMMdd";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale] ];
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];

}

/*!
 
 @brief: Updates UI elements with data from data model
 
 @discussion:
 
 @param: none
 
 @return: none
 */
- (void)updateViewContents
{
    // Set temperature with degree symbol in between
    NSString* tempValue = [NSString stringWithFormat:@"%d\u00B0C", isOnline ? [WeatherDataModel tempToCelcius:weatDataModel.temperature].intValue : 0 ];
    [tempLabel setText:tempValue];
    
    NSString* tempMinMax = [NSString stringWithFormat:@"%d Min/%d Max",
                            isOnline ? [WeatherDataModel tempToCelcius:weatDataModel.tempLow].intValue : 0,
                            isOnline ? [WeatherDataModel tempToCelcius:weatDataModel.tempHigh].intValue : 0];
    [tempMinMaxLabel setText:tempMinMax];
    
    [cityLabel setText:isOnline ? weatDataModel.cityName : @"City"];
    
    NSString *dateString = [dateFormatter stringFromDate:[WeatherDataModel convertToDate:weatDataModel.date]];
    [timeStampLabel setText:isOnline ? dateString : @"TimeStamp"];
    
    [weatherLabel setText:isOnline ? weatDataModel.condition : @"Weather"];
    
    [humidityLabel setText:isOnline ? [NSString stringWithFormat:@"Humidity %d",weatDataModel.humidity.intValue] : @"Humidity"];
    
    [forecastTable reloadData];
}

/*!
 
 @brief: Function returns next date from the count send to this function
 
 @discussion:
 
 @param: curDate: The date from which next day needs to be calculated
 @param: count: Number of day from which day needs to be calculated
 
 @return: Date in NSDate format incremented from curDate
 */
-(NSDate*)getDay:(NSDate*)curDate from:(int)count
{
    if (count == 0)
    {
        return curDate;
    }
    else
    {
        return [NSDate dateWithTimeInterval:count*(24*60*60) sinceDate:curDate];
    }
    
}


/*!
 
 @brief: Function returns next date from the count sent to this function in string format i,e YY MMM DD format. Example 16 April 31
 
 @discussion:
 
 @param: curDate: The date from which next day needs to be calculated
 @param: count: Number of day from which day needs to be calculated
 
 @return: Date in String format incremented from curDate
 */
-(NSString*)getDayInString:(NSDate*)curDate from:(int)count
{
    NSDate *nextDay = [self getDay:curDate from:count];
    NSString *dateString = [dateFormatter stringFromDate:nextDay];
    NSLog(@"Date String %@", dateString);
    return [dateString substringToIndex:10];
}

/*!
 
 @brief: Start receiving location co-ordinates
 
 @discussion:
 
 @param: none
 
 @return: none
 */
- (void) startLocationManager
{
    CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
    if (authorizationStatus == kCLAuthorizationStatusNotDetermined)
    {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Reachability methods

/*!
 
 @brief: Called by Reachability whenever status changes
 
 @discussion:
 
 @param:
 
 @return: none
 */

- (void)networkConnectivityChanged: (NSNotification* )note
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    
    switch (netStatus)
    {
        case ReachableViaWWAN:
        {
            NSLog(@"Network reachable via WWAN");
            isOnline = TRUE;
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"Network reachable via WiFi");
            isOnline = TRUE;
            break;
        }
        case NotReachable:
        {
            NSLog(@"Network Not reachable !");
            isOnline = FALSE;
            
            // To check if particluar class exist in current iOS version i,e use UIAlertViewController in older version of iOS
            // Disable the warning in iOS 9.x
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            if (![UIAlertController class])
            {
                UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:kReachabilityNoNetworkTitle message:kReachabilityNoNetworkNote delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alertView show];
            }
            else if (!alert)
            {
                alert = [UIAlertController alertControllerWithTitle:kReachabilityNoNetworkTitle
                                                            message:kReachabilityNoNetworkNote
                                                     preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {alert = nil;}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            break;
        }
    }
    
    if (isOnline)
    {
        [self startLocationManager];
    }
    else
    {
        // reset weather data and update UI
        [weatDataModel resetData];
        [self updateViewContents];
    }
    
#pragma clang diagnostic pop
}

/*!
 
 @brief: Called when view is about to deallocated
 
 @discussion:When view is deallocated remove Observer from Notification center
 
 @param:
 
 @return: none
 */

- (void)dealloc
{
    //** Observer Pattern Implementation deletion
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


#pragma mark - CLLocationManagerDelegate

/*!
 
 @brief: CLLocationManagerDelegate called when it encounters error
 
 @discussion: This function keeps on calling when trying to get location, so just return when error is kCLErrorLocationUnknown
 
 @param:
 
 @return: none
 */
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    
    if (error == kCLErrorLocationUnknown)
    {
        return;
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (![UIAlertController class])
    {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [errorAlert show];
    }
    else if (!alert)
    {
        alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                    message:@"Failed to Get Your Location"
                                             preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {alert = nil;}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    
    }
#pragma clang diagnostic pop
    
    
}

/*!
 
 @brief: LocationManager delegate gets called when new location is got
 
 @discussion: Creates weather manager class, sets current class as its delegate and calls function to fetch weather data
 
 @param:
 
 @return: none
 */

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (fetchedLocation)
        return;
        
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil)
    {
        curLogitute = [NSString stringWithFormat:@"%.2f", currentLocation.coordinate.longitude];
        curLatitude = [NSString stringWithFormat:@"%.2f", currentLocation.coordinate.latitude];
    }
    
    fetchedLocation = TRUE;
    
    // explicitly Stop Location Manager after we get location co-ordinates
    [locationManager stopUpdatingLocation];

    // Create WeatherDataManager singleton class instance, sends weatherdatamodel created here
    WeatherDataManager* weatherMgr = [WeatherDataManager sharedInstance];
    [weatherMgr setWeatherDataModel:weatDataModel];
    [weatherMgr setWeatherDelegate:self];
    
    // Function call to intiate getting data from OpenWeather App
    [weatherMgr fetchWeatherDataForLatitude:curLatitude Longitude:curLogitute];
}


#pragma mark - ViewController Actions

/*!
 
 @brief: This functionalty gets current temp data for the given location explicitly
 
 @discussion:
 
 @param:
 
 @return: none
 */

- (IBAction)onRefresh:(id)sender
{
    fetchedLocation = FALSE;
    if (isOnline)
    {
        [self startLocationManager];
    }
}


#pragma mark - WeatherDataManagerDelegate method
/*!
 
 @brief: Delegate function implemnted to update the UI
 
 @discussion:
 
 @param:
 
 @return: none
 */
- (void)updateViewController
{
    [self updateViewContents];
}


#pragma mark - tableview delegate

/*!
 @brief: Table view delegate to get number of sections
 
 @discussion:
 
 @param:
 
 @return: none
 */
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*!
 @brief: Table view delegate to update header
 
 @discussion:
 
 @param:
 
 @return: none
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Forcast for Next 5 days";
}

/*!
 @brief: Table view delegate to get number of rows which is constant in our case
 
 @discussion:
 
 @param:
 
 @return: none
 */

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kTableViewNumberofRows;
}

/*!
 @brief: Table view delegate to get create new row
 
 @discussion:
 
 @param:
 
 @return: none
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ForecastCell";
    ForecastTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[ForecastTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (indexPath.row == 0)
    {
        cell.dayLabel.text = @"Current Day";
    }
    else
    {
        if (![weatDataModel cityId])
        {
            cell.dayLabel.text = @"Next Day";
        }
        else
        {
            cell.dayLabel.text = [self getDayInString:[WeatherDataModel convertToDate:weatDataModel.date] from:(int)indexPath.row];
        }
    }
    
    cell.dayLabel.textAlignment = NSTextAlignmentLeft;
    
    cell.arrowImageView.image = [UIImage imageNamed:@"arrow_gray"];
    
    
    return cell;

}

/*!
 @brief: Table view delegate gets called when a row is selected
 
 @discussion: On click of row(selected day), new view controller(ForecastViewController) is created passing into it the day.
                This ForecastViewController is pushed on to the current navigation controller stack
 
 @param:
 
 @return: none
 */

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Weather data is not there then don't do anything
    if (![weatDataModel cityId])
    {
        return;
    }
    
    forecastViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ForecastViewContID"];

    // set the date for displaying in next view controller table header
    [forecastViewController setDate:[self getDayInString:[WeatherDataModel convertToDate:weatDataModel.date] from:(int)indexPath.row] andSelection:(int)indexPath.row];
    
    [self.navigationController pushViewController:forecastViewController animated:YES];
}


@end
