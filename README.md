# OpenWeatherApp
OpenWeatherApp uses "OpenWeatherMap API" for displaying current weather data and 5 day forecast data

On Application launch it checks for network and displays an alert view if not connected to network.
If connected to network, application connects to http://openweathermap.org/api to get current weather data for location of the device.
Launch screen displays current temperatature, min/max temp, humidity, weather, current day and time.

It also has the ability to display forecast data for next 5 days.
When user clicks on any day, corresponding weather forecast for that day is displayed in next screen.

Note: Currently in the application scheme, code has enabled location simulation, please uncheck it to get current location of the device.
