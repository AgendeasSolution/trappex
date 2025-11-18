package com.fgtp.trappex;

import android.os.Bundle;
import android.content.pm.PackageManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import com.facebook.FacebookSdk;
import com.facebook.appevents.AppEventsLogger;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "app_info";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("getVersion")) {
                    try {
                        String versionName = getPackageManager()
                            .getPackageInfo(getPackageName(), 0)
                            .versionName;
                        result.success(versionName);
                    } catch (PackageManager.NameNotFoundException e) {
                        result.error("UNAVAILABLE", "Version not available", null);
                    }
                } else if (call.method.equals("getPackageName")) {
                    result.success(getPackageName());
                } else {
                    result.notImplemented();
                }
            });
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        FacebookSdk.sdkInitialize(getApplicationContext());
        AppEventsLogger.activateApp(this);
    }
}
