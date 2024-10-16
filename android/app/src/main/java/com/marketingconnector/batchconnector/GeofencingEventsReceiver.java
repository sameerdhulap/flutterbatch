package com.marketingconnector.batchconnector;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.batch.android.Batch;
import com.batch.android.BatchEventAttributes;
import com.webgeoservices.woosmapgeofencingcore.database.POI;
import com.webgeoservices.woosmapgeofencingcore.database.WoosmapDb;

import org.json.JSONObject;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

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

                    // Event with custom attributes
                    BatchEventAttributes attributes = new BatchEventAttributes()
                            .put("identifier", poi.idStore)
                            .put("name", poi.name);
                    Batch.Profile.trackEvent(regionData.getString("eventname"), attributes);
                }
            }
            catch (Exception ex){
                Log.e(TAG, ex.toString());
            }
        });
    }
}
