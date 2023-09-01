using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;

using Toybox.Time.Gregorian as Date;
using Toybox.Application.Storage;

using Toybox.ActivityMonitor as Mon;

using Toybox.Background;

var _animationInProg = false;
var _animation = null;	

class TestView extends Ui.WatchFace {

	var inLowPower = true;

	var _playing = false;
	
	var clockTime;
	var hour;
//	var min;
//	var sec;
//	var clockMode;

	var background;
	var time_info;
	
	var img_steps;
	var img_heart;
	var img_battery;
	var img_distance;
	
//	var dist;
//	var hr;
//	var battery;
	
	//var weatherCode;
	var weatherHUD;
	
//	var icons = {
//	          "Snow" => Rez.Drawables.hud_snow,
//	          "Sun"  => Rez.Drawables.hud_sunny,
//	          "Few Clouds" => Rez.Drawables.hud_partlycloudy,
//	          "Broken Clouds"  => Rez.Drawables.hud_cloudy,
//	          "Overcast Clouds"  => Rez.Drawables.hud_cloudy,
//	          "Rain" => Rez.Drawables.hud_rain,
//	          "Shower Rain"  => Rez.Drawables.hud_rain,
//	          "Thunderstorm" => Rez.Drawables.hud_thunder,
//	          "Fog" => Rez.Drawables.hud_fog
//	        }; 

	var BG_state = -1;
	var bit;
	
	//var temp_current_state;
	//var temp_weather_state;
	//var temp_BG_state;	
	
    function initialize() {
        WatchFace.initialize(); 
        
       // Sys.println(Storage.getValue("Lat_u"));
              
        refreshWeather(); 
    }	
    
    ////////////////////// refresh weather
    
    function refreshWeather()
    {    
//    	if (!Sys.getDeviceSettings().phoneConnected) {
//    		return;
//    		}
    		
        //var now = Time.now().value();
        var timeLastGPS = Storage.getValue("timestamp"); // get timestamp of the last time we saved
        var dur = Sys.getDeviceSettings().phoneConnected ? 900 : 3600;
        
       // Sys.println(dur);
        
        //Sys.println(dur);
        
        if (timeLastGPS != null)
        {        
        	//if (Time.now().value() - timeLastGPS < 900 && Sys.getDeviceSettings().phoneConnected) // load recent GPS data if it hasn't been more than X min
        	if (Time.now().value() - timeLastGPS < dur)
        	{
		        if (Storage.getValue("temperature") != null)
		        {
		        	app_temp = Storage.getValue("temperature");
		        	app_feels = Storage.getValue("feels");
		        	app_code = Storage.getValue("weatherCode");
		        	app_humidity = Storage.getValue("humidity");
		        }     
		    }
		    else
		    {
		    	// fire up GPS event
				var lastTime = Background.getLastTemporalEventTime();
				if (lastTime != null) {
				    // Events scheduled for a time in the past trigger immediately
				    //var nextTime = lastTime.add(new Time.Duration(5 * 60));
				    Background.registerForTemporalEvent(lastTime.add(new Time.Duration(5 * 60)));
				} else {
				    Background.registerForTemporalEvent(Time.now());
				}    
		    }  
	    } 
    }
    
    //////////////////////
    
/// ANIMATION CLASSES *************************************************************

	function play() {
	    if(!_playing) {
	        _animation.play({
	            :delegate => new DanceDanceAnimationDelegate(self)
	            });
	        _playing = true;
	    }
	}
	
	function stop() {
	    if(_playing) {
	        _animation.stop();
	        _playing = false;
	        View.removeLayer(_animation);
	        _animation = null;
	    }
	}


    function doAnimation() {
      if( _animation == null ) {
      
		_animation = new WatchUi.AnimationLayer(
		    Rez.Drawables.darkhour,
		    {
		        :locX=>0,
		        :locY=>0,
		    }
		);
          
          View.addLayer(_animation);
      }
      play();
    }
    
/// *******************************************************************************

    // Load your resources here
    function onLayout(dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
 
        img_heart = Ui.loadResource(Rez.Drawables.heart);
        img_battery = Ui.loadResource(Rez.Drawables.battery);     
        img_distance = Ui.loadResource(Rez.Drawables.distance);
        img_steps = Ui.loadResource(Rez.Drawables.steps);
    }
    
    hidden function drawBackground(dc)
    {
    	bit = null; background = null;
	    	if (app_code == null)
	    	{
				drawBG(dc);
			    weatherHUD = null;
	    		weatherHUD = Ui.loadResource(Rez.Drawables.hud_none); 
	    	}
	    	else
	    	{
	    		//different BG for snow and rain
	    		
	    		if (app_code.equals("Rain"))
	    		{
	    			//draw bg and rain
		    		//if (BG_state != 3)
					//{ 
					//background = null; 
					background = Ui.loadResource(Rez.Drawables.map_rain);
					bit = Ui.loadResource(Rez.Drawables.bit_rain);
					//BG_state = 3; 
					//}
	    		}
	    		else if (app_code.equals("Snow"))
	    		{
	    			//draw snow and rain
		    		//if (BG_state != 4)
					//{ 
					//background = null; 
					background = Ui.loadResource(Rez.Drawables.map_snow); 
					bit = Ui.loadResource(Rez.Drawables.bit_snow);
					//BG_state = 4; 
					//}
	    		}
	    		else
	    		{
	    			//draw regular BG
	    			drawBG(dc);
	    		}

		    		getWeatherIcon(dc);
	    		//}
	    	}	
	    	
	    	dc.drawBitmap(0, 0, background);
	    	dc.drawBitmap(116, -2, weatherHUD);
//	    }
    }
    
    hidden function drawBG(dc)
    {   			
    	//if (background != null) { background = null; }
    	//background = null;
    	
	    	if (hour < 6 || hour >= 20) // <6am or > 8pm
	    	{
	    		//if (BG_state != 2 || BG_state == 6)
				//{ 
				background = Ui.loadResource(Rez.Drawables.map_night);
				bit = Ui.loadResource(Rez.Drawables.bit_night);
				//bit = null; bit = Ui.loadResource(Rez.Drawables.bit);
				//}
			}
			else if (hour < 20 && hour > 12) // before 8pm, but >= 1pm
			{
	    		//if (BG_state != 1)
				//{ 
				background = Ui.loadResource(Rez.Drawables.map_afternoon); 
				bit = Ui.loadResource(Rez.Drawables.bit_afternoon);
				//}		
			}		
			else// if (hour <= 12 && hour >= 6) // before 1pm, but after >= 6am
			{
	    		//if (BG_state != 0)
				//{ 
				background = Ui.loadResource(Rez.Drawables.map_day);
				bit = Ui.loadResource(Rez.Drawables.bit_day);
				//}			
			}
    
    }

    function getWeatherIcon(dc)
    {
		weatherHUD = null; 
		if (app_code == null)
		{ weatherHUD = Ui.loadResource(Rez.Drawables.hud_none ); }
		
		else if (app_code.equals("Snow")) { weatherHUD = Ui.loadResource(Rez.Drawables.hud_snow); }
		else if (app_code.equals("Sun")) { weatherHUD = Ui.loadResource(Rez.Drawables.hud_sunny); }
		else if (app_code.equals("Few Clouds")) { weatherHUD = Ui.loadResource(Rez.Drawables.hud_partlycloudy); }
		else if (app_code.equals("Broken Clouds") || app_code.equals("Overcast Clouds")) 
		{ weatherHUD = Ui.loadResource(Rez.Drawables.hud_cloudy); }
		
		else if (app_code.equals("Rain") || app_code.equals("Shower Rain")) 
		{ weatherHUD = Ui.loadResource(Rez.Drawables.hud_rain); }
		
		else if (app_code.equals("Thunderstorm")) { weatherHUD = Ui.loadResource(Rez.Drawables.hud_thunder); }
		else if (app_code.equals("Fog")) { weatherHUD = Ui.loadResource(Rez.Drawables.hud_fog); }
		//else { weatherHUD = Ui.loadResource(Rez.Drawables.hud_none ); }
		//    		weatherHUD = Ui.loadResource(icons[app_code]);    	
    //	var icons = {
//	          "Snow" => Rez.Drawables.hud_snow,
//	          "Sun"  => Rez.Drawables.hud_sunny,
//	          "Few Clouds" => Rez.Drawables.hud_partlycloudy,
//	          "Broken Clouds"  => Rez.Drawables.hud_cloudy,
//	          "Overcast Clouds"  => Rez.Drawables.hud_cloudy,
//	          "Rain" => Rez.Drawables.hud_rain,
//	          "Shower Rain"  => Rez.Drawables.hud_rain,
//	          "Thunderstorm" => Rez.Drawables.hud_thunder,
//	          "Fog" => Rez.Drawables.hud_fog
//	        }; 
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc) as Void {

    dc.clearClip();
    
    clockTime = System.getClockTime();
    hour = clockTime.hour;
	var min = clockTime.min;
	var sec = clockTime.sec;    
	
    View.onUpdate(dc);  
    
   
//        if (Activity.getActivityInfo().currentLocation != null)
//        {
//        		var lat = Activity.getActivityInfo().currentLocation.toDegrees()[0];	
//				Application.getApp().setValue("lat", lat);
//				
//				lat = Activity.getActivityInfo().currentLocation.toDegrees()[1];
//				Application.getApp().setValue("lon", lat);
//        }
        
	//Sys.println(inLowPower);
        
   // Sys.println(sec);
        
    if (hour == 23 && min == 59 && sec >= 54) 
    {
       // if (BG_state != 5) //CHECK TODO
       // {
        	//temp_weather_state = weather_state;
        	//temp_BG_state = BG_state;
        	//temp_current_state = current_state;
        	
        	background = null;
        	weatherHUD = null;
        	time_info = null;
//        	img_steps = null;
//        	img_battery = null;
//        	img_heart = null;
//        	img_distance = null;
        	
        	BG_state = 5;
	  //  }
	  //  else  
	 //   {
			//if (_animationInProg != true) 
			//{
				_animationInProg = true;
        		doAnimation();
        	//}
      //  }
//        	//}
////			if (min == 59 && sec > 55) {
////				//if (BG_state != BG_DARKHOUR) {
////				//	BG_state = BG_DARKHOUR;
////					background = null;
////					dc.drawBitmap(0, 0, Ui.loadResource(Rez.Drawables.map_afternoon));	
////				//}
////			}
	}
	
    else if (_animationInProg == false)
    {  
		if (BG_state == 5) 
		{
	 		_animation = null; 
	 		
        	BG_state = 6; //temp_BG_state; 
        	
        	getWeatherIcon(dc);
        	
 //   		weatherHUD = null; 
//    		weatherHUD = Ui.loadResource(icons[app_code]);//(icons.get(app_code));
	 	}
	 	
    	//Sys.println("normal ");
        drawBackground(dc);

        dc.setColor(0xFFFFFF, -1);  //52, 76


		//dc.drawText(119, 55, 14, dc.getFontHeight(), 1);
		dc.drawText(100, 52, 14, hour.format("%02d"), 1);
        dc.drawText(128, 76, 14, min.format("%02d"), 1);

		//dc.drawText(100, 52, 14, hour.format("%02d") + "\n" + min.format("%02d"), 1);
		//dc.drawText(100, 52, 14, hour.format("%02d") + "\n             " + min.format("%02d"), 1);



      //  dc.drawText(129, 75, 14, min.format("%02d"), 1);
//        dc.drawText(156, 98, Gfx.FONT_SYSTEM_TINY , secString, 2);

        //dc.drawText(102, 52, Gfx.FONT_SYSTEM_NUMBER_MILD, hourString, 1);
        //dc.drawText(130, 75, Gfx.FONT_SYSTEM_NUMBER_MILD, minString, 1);
        //dc.drawText(144, 89, Gfx.FONT_SYSTEM_XTINY , secString, 2);

        var day_xpos = 92;
        
//        	var TIME_EARLY_MONRING = [6, 8]; //6-859
//	var TIME_MORNING = [9, 11]; //9-1159
//	var TIME_AFTERNOON = [12, 16]; //12 - 459
//	var TIME_EVENING = [17, 20]; //5 - 859
//	var TIME_NIGHT = [21, 23]; //9 - 2359
//	var TIME_LATE_NIGHT = [0, 5]; //0 - 559am
        
        //if (time_info != null)
        //{ 
        time_info = null; 
        //}
        
		if (hour >= 6 && hour <= 8)// && current_state != "EARLY_MORNING")
		{ time_info = Ui.loadResource(Rez.Drawables.time_earlymorning); day_xpos = 79; }
		
		else if (hour >= 8 && hour <= 11) // && current_state != "MORNING")
		{ time_info = Ui.loadResource(Rez.Drawables.time_morning); day_xpos = 90; }	
		
		else if (hour >= 12 && hour <= 16) //&& current_state != "AFTERNOON")
		{ time_info = Ui.loadResource(Rez.Drawables.time_afternoon); day_xpos = 88; }
		
		else if (hour >= 17 && hour <= 19) //&& current_state != "EVENING")
		{ time_info = Ui.loadResource(Rez.Drawables.time_evening); day_xpos = 92;}
				
		else if (hour >= 20 && hour <= 23) // && current_state != "NIGHT")
		{ time_info = Ui.loadResource(Rez.Drawables.time_night); day_xpos = 90; }
		
		else// if (hour >= 0 && hour <= 5 && current_state != "LATE_NIGHT")
		{ time_info = Ui.loadResource(Rez.Drawables.time_latenight); day_xpos = 89; }
		
    	dc.drawBitmap(day_xpos, 29, time_info);
    	    
        if (app_temp != null)// && app_feels != null && app_humidity != null) //203, 102
        {
       		dc.drawText(235, 106, 0, app_temp.format("%d") + "/" + 
       		app_feels.format("%d") + StringUtil.utf8ArrayToString([0xC2,0xB0]), 0);
       		
       		dc.drawText(236, 126, 0, app_humidity.format("%d") + "%", 0);
        }
        
    	var now = Time.now(); // this used to be "now"
    	
		//var getMonth = Date.info(now, Time.FORMAT_SHORT).month;
		var date = Date.info(now, Time.FORMAT_MEDIUM);
//		
		//var dayOfWeek = date.day_of_week;
		//var day = date.day;
		
//		//var dateString = Lang.format("$1$/$2$ $3$", [getMonth, date.day, date.day_of_week]); //date.year
//		
//		//stuff on the side yellow strip
//		//dc.drawBitmap(46, 25, img_tv);
//		dc.drawText(58, 50, Gfx.FONT_SMALL, date.day_of_week, 1);
//		dc.drawText(64, 73, Gfx.FONT_SMALL, date.day, 1);
//				
//		//dc.drawBitmap(33, 102, img_sunny);
//		
//		dc.drawBitmap(35, 142, img_month);
//		
//		dc.drawText(53, 176, Gfx.FONT_MEDIUM, date.year, 1);

		//THIS IS THE BORDER FOR THE DATE ************************************************
		dc.setColor(0x000000, -1);
		dc.fillRoundedRectangle(88, 6, 105, 23, 14);//************************************
		
		
		//var ds = Lang.format("$1$/$2$ $3$", [day.format("%02d"), getMonth.format("%02d"), dayOfWeek]); // 24/5 Mon
		
		//var ds = date.day.format("%02d") + "/" + Date.info(now, Time.FORMAT_SHORT).month.format("%02d") + " " + date.day_of_week;
		
		
		dc.setColor(0xFFFFFF, -1);
        dc.drawText(92, 3, 1, date.day.format("%02d") + "/" + Date.info(now, Time.FORMAT_SHORT).month.format("%02d") + " " + date.day_of_week, 2);  
        
        //battery   
    	//var xpos = 60; // we are using the day_xpos variable again, used to be "xpos"
    	day_xpos = 60;
    	//var xpos_perc = 77; //perc
    	date = System.getSystemStats().battery; // we are using the variable "date" for this one, it is battery 
    	
    	if (date > 99.9) { day_xpos = 55; }// xpos_perc = 72; }
    			
		dc.drawBitmap(day_xpos, 215, img_battery);
		dc.drawText(day_xpos + 17, 210, 1, date.format("%d")+"%", 2); //
		
        //heart rate
        // note: heartRate == day_xpos
        dc.drawBitmap(121, 215, img_heart); // always draw the heart
		day_xpos = Activity.getActivityInfo().currentHeartRate;
		if (day_xpos == null) 
		{
			//var HRH = Mon.getHeartRateHistory(1, true);
			var HRS = Mon.getHeartRateHistory(1, true).next();
		
			if (HRS != null && HRS.heartRate != Mon.INVALID_HR_SAMPLE)
			{
				day_xpos = HRS.heartRate;			
				//dc.drawText(142, 209, 1, day_xpos.format("%d"), 2);
			}
			else
			{
				day_xpos = "";
			}
		}
		else
		{	
			//dc.drawText(142, 209, 1, day_xpos.format("%d"), 2);
		}
		
		dc.drawText(142, 209, 1, day_xpos, 2); //.format("%d")
		
		setDistanceDisplay(dc);
		//setStepsDisplay(dc);
		
	    	//var steps = Mon.getInfo().steps;
    	dc.drawBitmap(121, 194, img_steps);
		dc.drawText(142, 189, 1, Mon.getInfo().steps, 2); // 
		
 	//dc.clearClip(S);
	//dc.clear();    
	
	
		//if (!inLowPower) {
        doTime(dc, sec.format("%02d"));	
        //}
	}
    }
    
    hidden function setDistanceDisplay(dc)
    {	
    	//44,64 for >= 10.00 distance, otherwise 60,80
   		var xpos = 55;
        // get distance walked
//        dc.drawBitmap(103, 193, img_distance);
//        dist = Mon.getInfo().distance.toFloat() / (1000 * 100); //convert to km
//        dc.drawText(121, 188, Gfx.FONT_TINY, dist.format("%.2f"), 2);
        
        var dist = Mon.getInfo().distance.toFloat() / (1000 * 100); //convert to km
        
        if (dist > 9.99) 
        { xpos = 43; }
        
        //var xpos_value = xpos + 20; 
        
        dc.drawBitmap(xpos, 194, img_distance);
        //dist = Mon.getInfo().distance.toFloat() / (1000 * 100); //convert to km
        dc.drawText(xpos + 20, 189, 1, dist.format("%.2f"), 2); //dist.format("%.2f")
    }
    
    function doTime(dc, time)
    {
   		dc.setClip(143, 98, 22, 20); 
  		//dc.setColor(0x000000, 0x000000);
  		//dc.clear(); 

  		dc.drawBitmap(143, 98, bit);
  		
  		dc.setColor(0xFFFFFF, -1);		  		
  		dc.drawText(143, 93, 0, time, 2);    	
    }
    
    function onPartialUpdate(dc)
    {
    	//Sys.println("szklarz");
        //var secString = Sys.getClockTime().sec.format("%02d");
        doTime(dc, Sys.getClockTime().sec.format("%02d"));
//        Sys.println(dc.getFontWidth(Gfx.FONT_XTINY));
    }
    
    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    	inLowPower = false;
    	refreshWeather();
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    	inLowPower = true;
    }

}


// ************************ ANIMATION CLASS

class DanceDanceAnimationDelegate extends Ui.AnimationDelegate {
    var _controller;

    function initialize(controller) {
        AnimationDelegate.initialize();
        _controller = controller;
    }


    function onAnimationEvent(event, options) {
        switch(event) {
            case WatchUi.ANIMATION_EVENT_COMPLETE:
            	_animationInProg = false;
            case WatchUi.ANIMATION_EVENT_CANCELED:
                _controller.stop();
                break;
        }
    }
}


// ****************************************