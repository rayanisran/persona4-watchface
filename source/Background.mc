using Toybox.Background;
using Toybox.System as Sys;
using Toybox.Communications as Comm;
using Toybox.Application.Properties;
// The Service Delegate is the main entry point for background processes
// our onTemporalEvent() method will get run each time our periodic event
// is triggered by the system.

(:background)
class BgbgServiceDelegate extends Toybox.System.ServiceDelegate {
	
	var APIKEY = "REDACTED";
	var home_lat = Properties.getValue("Lat_u"); //24.825647;//38.8551;
	var home_lon = Properties.getValue("Lon_u"); //67.0387093;//-94.8001;
	
	var lat;
	var lon;
	
	var dict = {};
	
	var weatherCodes = {
		"01d" => "Sun",
		"01n" => "Sun",
		"02d" => "Few Clouds",
		"02n" => "Few Clouds",
		"03d" => "Broken Clouds",
		"03n" => "Broken Clouds",
		"04d" => "Overcast Clouds",
		"04n" => "Overcast Clouds",
		"09d" => "Shower Rain",
		"09n" => "Shower Rain",
		"10d" => "Rain",
		"10n" => "Rain",
		"11d" => "Thunderstorm",
		"11n" => "Thunderstorm",
		"13d" => "Snow",
		"13n" => "Snow",
		"50d" => "Fog",
		"50n" => "Fog"
		};	

	
	function initialize() {
		Sys.ServiceDelegate.initialize();
//		inBackground = true;
	}
	
    function onTemporalEvent() {
    
    Sys.println("TEST");
    
   // if (!Sys.getDeviceSettings().phoneConnected) { return; } // if the phone isn't connected, don't do an update
    
    		if (Activity.getActivityInfo().currentLocation == null)
    		{
    			//Sys.println("null coords");
    			//try to get the last saved value of gps
    			lat = Properties.getValue("lat");
    			lon = Properties.getValue("lon");
    			
    			//if last saved value is null, just use the user defined values
    			if (lat == 0)
    			{
    				//read fixed home coordinates
    				//Sys.println("MATE");
    				//Sys.println(Properties.getValue("Lat_u"));
    				lat = home_lat;
    				lon = home_lon;
    				//Sys.println("home coords");
    			}
    			//else
    			//{ Sys.println(lat); }
    		}
    		else
    		{
    			//Sys.println("got coords!");
				lat = Activity.getActivityInfo().currentLocation.toDegrees()[0];
				lon = Activity.getActivityInfo().currentLocation.toDegrees()[1];
    		}
    
	    	var UNITS = (Sys.getDeviceSettings().temperatureUnits==Sys.UNIT_STATUTE) ? "imperial" : "metric";
			var url = "https://api.openweathermap.org/data/2.5/weather";
	    	var param = {
	    		"lat" => lat.toFloat(),
	    		"lon" => lon.toFloat(),
	    		"appid" =>APIKEY,
	    		"units" => UNITS};
			var options = {
				:methods => Comm.HTTP_REQUEST_METHOD_GET,
				:headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
				:responseType => Comm.HTTP_RESPONSE_CONTENT_TYPE_JSON
			};
   	
			Comm.makeWebRequest(
	    	   	url,
	    	   	param,
	    	   	options,
	    	   	method(:receiveWeather));
    }
    
    function receiveWeather(responseCode, data) {
    	//var ret = (responseCode == 200) ? data : responseCode;
    	
    	if (responseCode == 200)// && data instanceof Dictionary)
    	{
	    	//if (data instanceof Dictionary && (data.get("error") == null || data.get("error") == false))
	    	//{  	
//	    	var weather = data.get("weather")[0]["icon"];//.get("icon");
//	    	var temperature = data.get("main")["temp"];//.get("temp");
//	    	var feels = data.get("main")["feels_like"];//.get("feels_like");
//	    	var humidity = data.get("main")["humidity"];//.get("humidity");

	    	var weather = data["weather"][0]["icon"];//.get("icon");
	    	var temperature = data["main"]["temp"];//.get("temp");
	    	var feels = data["main"]["feels_like"];//.get("feels_like");
	    	var humidity = data["main"]["humidity"];//.get("humidity");
	    	
	    	//Sys.println(weather);
	    	
	    	dict["temp"] = temperature;
	    	dict["code"] = weatherCodes[weather];//.get(weather);
	    	dict["feels"] = feels;
	    	dict["humidity"] = humidity;
	    	
//	    	Sys.print("initiate bg: ");
//	    	Sys.println(dict);	
	    	
			Background.exit(dict);
			//}
		}
		else
		{
		//	Sys.println("ERROR SIMULATED!");
			Background.exit(400); // send some number to indicate an error
		}
	}
}