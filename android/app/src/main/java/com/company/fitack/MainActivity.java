package com.company.fit;

import android.app.AlarmManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.provider.Settings;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.company.fit/alarm_permission";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            if (call.method.equals("requestExactAlarmPermission")) {
                                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                                    AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
                                    if (alarmManager != null && !alarmManager.canScheduleExactAlarms()) {
                                        Intent intent = new Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM);
                                        startActivity(intent);
                                    }
                                    result.success(true);
                                } else {
                                    result.success(false);
                                }
                            } else {
                                result.notImplemented();
                            }
                        }
                );
    }
}
