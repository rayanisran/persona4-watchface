using Toybox.Application as App;
using Toybox.Activity as Activity;
using Toybox.Background;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Time as Time;
// info about whats happening with the background process
//var counter=0;
//var bgdata="none";
//var weather;
//var canDoBG=false;
//var inBackground=false;			//new 8-27
// keys to the object store data
//var OSCOUNTER="oscounter";
//var OSDATA="osdata";

//var app_dict = {};

var app_code;
var app_feels;
var app_temp;
var app_humidity;

(:background)
class TestApp extends App.AppBase {

    function initialize() {

    
        AppBase.initialize();
        
//    	var now=Sys.getClockTime();
//    	var ts=now.hour+":"+now.min.format("%02d");
//    	//you'll see this gets called in both the foreground and background        
//        Sys.println("App initialize "+ts);
//        var temp=App.Storage.getProperty(OSCOUNTER);
//        //var temp=null;
//        if(temp!=null && temp instanceof Number) {counter=temp;}
//        Sys.println("Counter in App initialize: "+counter);        
    }

    // onStart() is called on application start up
    // function onStart(state as Dictionary?) as Void {
    // }

	    function onStart(state) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    	//moved from onHide() - using the "is this background" trick
//    	if(!inBackground) {
//	    	var now=Sys.getClockTime();
//    		var ts=now.hour+":"+now.min.format("%02d");        
//        	Sys.println("onStop counter="+counter+" "+ts);    
//    		App.Storage.setProperty(OSCOUNTER, counter);     
//    	} else {
//    		Sys.println("onStop");
//    	}
    }
    
        // Return the initial view of your application here
    function getInitialView() {
		//register for temporal events if they are supported
    	//if(Toybox.System has :ServiceDelegate) {
    	//	canDoBG=true;
              
        
    	//Sys.println("OK");
    		Background.registerForTemporalEvent(new Time.Duration(60 * 60));
    	//} else {
    	//	Sys.println("****background not available on this device****");
    	//}
        return [ new TestView() ];
    }

//    // Return the initial view of your application here
//    function getInitialView() as Array<Views or InputDelegates>? {
//        return [ new TestView() ] as Array<Views or InputDelegates>;
//    }

    
    function onBackgroundData(data) {
    
		//save coordinates if we got them
		if (Activity.getActivityInfo().currentLocation != null)
		{
    		var lat = Activity.getActivityInfo().currentLocation.toDegrees()[0];
//				//var lon = Activity.getActivityInfo().currentLocation.toDegrees()[1];	    	
			App.Storage.setValue("lat", lat);	
//				
			lat = Activity.getActivityInfo().currentLocation.toDegrees()[1];
			App.Storage.setValue("lon", lat);
		}    

    	if (data != 400) 
    	{
    		//app_dict = data;
    		app_code = data["code"];
    		app_temp = data["temp"];
    		app_feels = data["feels"];
    		app_humidity = data["humidity"];
				
	        App.Storage.setValue("weatherCode", app_code);//app_dict["code"]);
	        App.Storage.setValue("temperature", app_temp);//app_dict["temp"]);
	        App.Storage.setValue("timestamp", Time.now().value());
	        App.Storage.setValue("feels", app_feels);//app_dict["feels"]);
	        App.Storage.setValue("humidity", app_humidity);//app_dict["feels"]);
	        Ui.requestUpdate();
    	}    
    	else
    	//we got some error
    	{
    		//see if we can retrieve the previously stored value, otherwise fill in an empty string
    		//reuse the prevCode variable to save space
	        var prevCode = Storage.getValue("weatherCode");
	        app_code = prevCode == null ? prevCode : null;
	        
	        prevCode = Storage.getValue("temperature");   
	        app_temp = prevCode == null ? prevCode : null; 		
	        
	        prevCode = Storage.getValue("feels");   
	        app_feels = prevCode == null ? prevCode : null; 
	        
	        prevCode = Storage.getValue("humidity");   
	        app_feels = prevCode == null ? prevCode : null; 	
    	}
    }

    function getServiceDelegate(){
//    	var now=Sys.getClockTime();
//    	var ts=now.hour+":"+now.min.format("%02d");    
//    	Sys.println("getServiceDelegate: "+ts);
        return [new BgbgServiceDelegate()];
    }

}

function getApp() as TestApp {
    return Application.getApp() as TestApp;
}