## Flutter Integration: Send Braze Custom events from `geofencing_flutter_plugin`

[Flutter Example project](/assets/archive/connector_braze_flutter.zip)

#### Braze Integration

Follow the [Flutter Braze Implementation](https://www.braze.com/docs/developer_guide/platform_integration_guides/flutter/flutter_sdk_integration) guide to add the Braze plugin to your project.

#### Receiving Woosmap Geofencing Region events using iOS Notification

Follow the steps below to capture events of geofence SDK

***&#x31;.*** Add a new Swift class file, GeofencingEventsReceiver.swift, in the iOS folder and include it in your iOS workspace with the following code in it.

 

  ``` swift
  import Foundation
  import WoosmapGeofencing

  extension Notification.Name {
    static let updateRegions = Notification.Name("updateRegions")
    static let didEventPOIRegion = Notification.Name("didEventPOIRegion")
  }

  @objc(GeofencingEventsReceiver)
  class GeofencingEventsReceiver: NSObject {
    @objc public func startReceivingEvent() {
      NotificationCenter.default.addObserver(self, selector: #selector(POIRegionReceivedNotification),
                                            name: .didEventPOIRegion,
                                            object: nil)
    }
    @objc func POIRegionReceivedNotification(notification: Notification) {
      if let POIregion = notification.userInfo?["Region"] as? Region{
        // YOUR CODE HERE
        if POIregion.didEnter {
          NSLog("didEnter")
          
          // check first if the POIregion.origin is equal to "POI"
          if POIregion.origin == "POI"
          {
            if let POI = POIs.getPOIbyIdStore(idstore: POIregion.identifier) as POI? {
              AppDelegate.braze?.logCustomEvent(
                name: "woos_geofence_entered_event",
                properties: [
                  "identifier": POI.idstore,
                  "name": POI.name
                ]
              )
            }
            else {
              // error: Related POI doesn't exist
            }
          }
        }
      }
    }
    // Stop receiving notification
    @objc public func stopReceivingEvent() {
      NotificationCenter.default.removeObserver(self, name: .didEventPOIRegion, object: nil)
    }
    
  }
  ```



***&#x32;.*** Integrate `AppDelegate.swift` to receive SDK events

  
  ``` swift
  import BrazeKit
  import braze_plugin


  @objc class AppDelegate: FlutterAppDelegate {
      let objreciver:GeofencingEventsReceiver = GeofencingEventsReceiver()
      static var braze: Braze? = nil
    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

      // Setup Braze
      let configuration = Braze.Configuration(
        apiKey: "<BRAZE_API_KEY>",
        endpoint: "<BRAZE_ENDPOINT>"
      )
        // - Enable logging or customize configuration here
      configuration.logger.level = .info
      let braze = BrazePlugin.initBraze(configuration)
      AppDelegate.braze = braze

      GeneratedPluginRegistrant.register(with: self)
      ...
      ...
    }
  }
  ```


#### Receiving Woosmap Geofencing Region events using Android Broadcasts

Geofencing SDK triggers an action `com.woosmap.action.GEOFENCE_TRIGGERED` and broadcasts `regionLog` in the intent extra.

Follow the steps below in order to listen to the broadcasts sent by the Woosmap Geofencing Plugin.

***&#x31;.*** Add the following dependencies in the `build.gradle` file of your main project.
   
  {% tabs flutter android/build.gradle %}

  ``` java
    repositories {
            ...
            ....
            maven { url 'https://jitpack.io' }
        }
  ```


***&#x32;.*** Add the following dependencies in the `app/build.gradle` file of your main project.

  {% tabs flutter android/app/build.gradle %}

  ``` java
    dependencies {
        ...
        ...
        implementation "woosmap:geofencing-core-android-sdk:core_geofence_2.+"
        implementation "com.webgeoservices.woosmapgeofencing:woosmap-mobile-sdk:4.+"
    }
  ```


***&#x33;.*** Add a new class GeofencingEventsReceiver.java/kt, and include the following code in it.

  

  ``` kotlin
  import android.content.BroadcastReceiver
  import android.content.Context
  import android.content.Intent
  import android.util.Log
  import com.webgeoservices.woosmapgeofencingcore.database.WoosmapDb
  import org.json.JSONObject
  import java.util.concurrent.ExecutorService
  import java.util.concurrent.Executors
  import com.braze.Braze;
  import com.braze.models.outgoing.BrazeProperties;

  class GeofencingBroadcastReceiver: BroadcastReceiver() {
      val TAG: String = "GeofencingReceiver"
      private val executorService: ExecutorService = Executors.newSingleThreadExecutor()

      override fun onReceive(context: Context?, intent: Intent?) {
          Log.d(TAG, "Received broadcast")
          executorService.execute {
              try {
                  // Get region data from the intent
                  val regionData = intent?.getStringExtra("regionLog")?.let { JSONObject(it) }
                  // Fetch the POI from the db based on the identifier
                  val poi = WoosmapDb.getInstance(context).poIsDAO.getPOIbyStoreId(regionData!!.getString("identifier"))

                  if (poi != null) { //poi could be null if the entered/exited region is a custom region.
                    Braze.getInstance(context).logCustomEvent(regionData.getString("eventname"),
                        BrazeProperties(JSONObject()
                            .put("identifier", poi.idStore)
                            .put("name", poi.name)
                    ))
                  }
              } catch (ex: Exception) {
                  Log.e(TAG, ex.toString())
              }
          }
      }
  }
  ```

  ```java
  import android.content.BroadcastReceiver;
  import android.content.Context;
  import android.content.Intent;
  import android.util.Log;

  import com.webgeoservices.woosmapgeofencingcore.database.POI;
  import com.webgeoservices.woosmapgeofencingcore.database.WoosmapDb;

  import org.json.JSONObject;

  import java.util.concurrent.ExecutorService;
  import java.util.concurrent.Executors;

  import com.braze.Braze;
  import com.braze.models.outgoing.BrazeProperties;

  public class GeofencingEventsReceiver extends BroadcastReceiver {
      private static final String TAG = "GeofencingReceiver";
      private final ExecutorService executorService = Executors.newSingleThreadExecutor();
      @Override
      public void onReceive(Context context, Intent intent) {
          Log.d(TAG, "Received broadcast");
          executorService.execute(() -> {
              try{
                  // Get region data from the intent
                  JSONObject regionData = new JSONObject(intent.getStringExtra("regionLog"));
                  // Fetch the POI from the db based on the identifier
                  POI poi;
                  poi = WoosmapDb.getInstance(context).getPOIsDAO().getPOIbyStoreId(regionData.getString("identifier"));
                  if (poi != null){ //poi could be null if the entered/exited region is a custom region.
                    Braze.getInstance(context).logCustomEvent(regionData.getString("eventname"),
                        new BrazeProperties(new JSONObject()
                            .put("identifier", poi.idStore)
                            .put("name", poi.name)
                    ));
                  }
              }
              catch (Exception ex){
                  Log.e(TAG, ex.toString());
              }
          });
      }
  }
  ```



***&#x34;.*** If you already have a custom `android.app.Application` subclass registered, you can skip this step.
  
  Open your project's Android folder in Android Studio. Create a new class that subclasses `android.app.Application`. It can be named however you want, but we will call it `MainApplication` for the sake of this example.Place it in your root package.
  
  Then, add an onCreate() override. The class should look like this:


 ``` kotlin
  import android.app.Application
  class MainApplication: Application() {
      override fun onCreate() {
          super.onCreate()
      }
  }
  ```

  ``` java
  import android.app.Application;
  public class MainApplication extends Application {
      @Override
      public void onCreate() {
          super.onCreate();
      }
  }
  ```


***&#x35;.*** Register the newly created Broadcast Receiver in Application class.


  ``` kotlin
    class MainApplication : Application() {
      lateinit var geofencingEventsReceiver: GeofencingEventsReceiver
      
      override fun onCreate() {
        super.onCreate()
          // Register the receiver with the filter
          geofencingEventsReceiver = GeofencingEventsReceiver()
          val filter = IntentFilter("com.woosmap.action.GEOFENCE_TRIGGERED")
          registerReceiver(geofencingEventsReceiver, filter, RECEIVER_EXPORTED)
      }
    }
  ```

  ``` java
    public class MainApplication extends Application {
        private GeofencingEventsReceiver geofencingEventsReceiver;

        @Override
        public void onCreate() {
            super.onCreate();
            // Register the receiver with the filter
            geofencingEventsReceiver = new GeofencingEventsReceiver();
            IntentFilter filter = new IntentFilter("com.woosmap.action.GEOFENCE_TRIGGERED");
            registerReceiver(geofencingEventsReceiver, filter, RECEIVER_EXPORTED);
        }
    }
  ```