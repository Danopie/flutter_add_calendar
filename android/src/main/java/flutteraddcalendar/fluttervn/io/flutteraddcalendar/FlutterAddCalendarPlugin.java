package flutteraddcalendar.fluttervn.io.flutteraddcalendar;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.database.Cursor;
import android.net.Uri;
import android.provider.CalendarContract;
import android.util.Log;

import androidx.annotation.NonNull;

import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;


/**
 * FlutterAddCalendarPlugin
 */
public class FlutterAddCalendarPlugin implements FlutterPlugin, MethodCallHandler{
    private Context context;
    static MethodChannel channel;

    /**
     * Plugin registration.
     */
    public static void registerWith(Registrar registrar) {
        FlutterAddCalendarPlugin plugin = new FlutterAddCalendarPlugin();
        plugin.context = registrar.context();

        channel = new MethodChannel(registrar.messenger(), "flutter_add_calendar/native");
        channel.setMethodCallHandler(plugin);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding binding) {
        channel = new MethodChannel(binding.getBinaryMessenger(), "flutter_add_calendar/native");
        context = binding.getApplicationContext();
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {

    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("setEventToCalendar")) {
            final Boolean silently = Boolean.valueOf(String.valueOf(call.argument("silently")));
            if(!silently){
                addEventToCalendar(String.valueOf(call.argument("title")), String.valueOf(call.argument("desc")),String.valueOf(call.argument("location")), Long.valueOf(String.valueOf(call.argument("startDate"))), Long.valueOf(String.valueOf(call.argument("endDate"))));
//                result.success("Android " + android.os.Build.VERSION.RELEASE);
            } else {
                addSilentEventToCalendar(String.valueOf(call.argument("title")), String.valueOf(call.argument("desc")),String.valueOf(call.argument("location")), Long.valueOf(String.valueOf(call.argument("startDate"))), Long.valueOf(String.valueOf(call.argument("endDate"))));
            }
        } else {
            result.notImplemented();
        }
    }



    private void addEventToCalendar(String title, String desc, String location, Long startDate, Long endDate) {
        Intent intent = new Intent(Intent.ACTION_INSERT)
                .setData(CalendarContract.Events.CONTENT_URI)
                .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, startDate)
                .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, endDate)
                .putExtra(CalendarContract.Events.TITLE, title)
                .putExtra(CalendarContract.Events.DESCRIPTION, desc)
                .putExtra(CalendarContract.Events.EVENT_LOCATION, location);
        //.putExtra(CalendarContract.Events.AVAILABILITY, CalendarContract.Events.AVAILABILITY_BUSY)
        //.putExtra(Intent.EXTRA_EMAIL, "rowan@example.com,trevor@example.com");
        if(intent.resolveActivity(context.getPackageManager()) != null){
            context.startActivity(intent);
        } else {
            Map<String, Object> data = new HashMap<>();
            data.put("code", "2");
            data.put("message", "Fail to resolve calendar information");
            channel.invokeMethod("receiveStatus", data);
        }
    }

    private void addSilentEventToCalendar(String title, String desc, String location, Long startDate, Long endDate) {
        System.out.println("FlutterAddCalendarPlugin.addSilentEventToCalendar");
        ContentResolver cr = context.getContentResolver();
        ContentValues values = new ContentValues();

        values.put(CalendarContract.Events.DTSTART, startDate);
        values.put(CalendarContract.Events.DTSTART, endDate);
        values.put(CalendarContract.Events.TITLE, title);
        values.put(CalendarContract.Events.DESCRIPTION, desc);
        values.put(CalendarContract.Events.EVENT_LOCATION, location);

        TimeZone timeZone = TimeZone.getDefault();
        values.put(CalendarContract.Events.EVENT_TIMEZONE, timeZone.getID());

// Default calendar
        values.put(CalendarContract.Events.CALENDAR_ID, getCalendarId());

// Set Period for 1 Hour
        values.put(CalendarContract.Events.DURATION, "+P1H");

        values.put(CalendarContract.Events.HAS_ALARM, 1);

// Insert event to calendar
        Uri uri = cr.insert(CalendarContract.Events.CONTENT_URI, values);
    }

    private int getCalendarId(){
        Cursor cursor = null;
        ContentResolver contentResolver = context.getContentResolver();
        Uri calendars = CalendarContract.Calendars.CONTENT_URI;

        String[] EVENT_PROJECTION = new String[] {
                CalendarContract.Calendars._ID,                           // 0
                CalendarContract.Calendars.ACCOUNT_NAME,                  // 1
                CalendarContract.Calendars.CALENDAR_DISPLAY_NAME,         // 2
                CalendarContract.Calendars.OWNER_ACCOUNT,                 // 3
                CalendarContract.Calendars.IS_PRIMARY                     // 4
        };

        int PROJECTION_ID_INDEX = 0;
        int PROJECTION_ACCOUNT_NAME_INDEX = 1;
        int PROJECTION_DISPLAY_NAME_INDEX = 2;
        int PROJECTION_OWNER_ACCOUNT_INDEX = 3;
        int PROJECTION_VISIBLE = 4;

        cursor = contentResolver.query(calendars, EVENT_PROJECTION, null, null, null);

        if (cursor.moveToFirst()) {
            String calName;
            long calId = 0;
            String visible;

            do {
                calName = cursor.getString(PROJECTION_DISPLAY_NAME_INDEX);
                calId = cursor.getLong(PROJECTION_ID_INDEX);
                visible = cursor.getString(PROJECTION_VISIBLE);
                if(visible.equals("1")){
                    return (int)calId;
                }
                Log.e("Calendar Id : ", "" + calId + " : " + calName + " : " + visible);
            } while (cursor.moveToNext());
            return (int)calId;
        }
        return 1;
    }


}
