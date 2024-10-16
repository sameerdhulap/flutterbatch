package com.marketingconnector.batchconnector;

import android.app.Application;
import android.content.IntentFilter;

public class MainApplication extends Application {
    private GeofencingEventsReceiver geofencingEventsReceiver;
    @Override
    public void onCreate() {
        super.onCreate();
        geofencingEventsReceiver = new GeofencingEventsReceiver();
        IntentFilter filter = new IntentFilter("com.woosmap.action.GEOFENCE_TRIGGERED");
        registerReceiver(geofencingEventsReceiver, filter, RECEIVER_EXPORTED);
    }
}
