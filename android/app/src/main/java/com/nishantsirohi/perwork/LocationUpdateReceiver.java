package com.nishantsirohi.perwork;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import io.flutter.plugin.common.EventChannel;

public class LocationUpdateReceiver extends BroadcastReceiver {
    private EventChannel.EventSink events;

    public LocationUpdateReceiver(EventChannel.EventSink events) {
        this.events = events;
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        double latitude = intent.getDoubleExtra("latitude", 0.0);
        double longitude = intent.getDoubleExtra("longitude", 0.0);

        if (events != null) {
            events.success(new LocationData(latitude, longitude));
        }
    }

    public static class LocationData {
        private double latitude;
        private double longitude;

        public LocationData(double latitude, double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }

        public double getLatitude() {
            return latitude;
        }

        public double getLongitude() {
            return longitude;
        }
    }
}
