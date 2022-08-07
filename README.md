# work_tracker

Test Flutter project to track my workout notes.

## Features
* stores log of exercises.
  Data stored: kind, quantity, additional weight (optional), date and time.
* shows graph for recent six month.
* additional weight can be used as quantity multiplication coeficient according to the body weight value.

## Programming

### Data storage

Stores workout log data using Flutter [Hive Db](https://docs.hivedb.dev/#/) 

#### old structure
I've to modify the generated Hive adapters source code in order to support old database structure.

My first attempt was to check how many fields have a data record and to read from data source if there are column for the current row. 
Like  `if (numOfFields > 3) value = data[3]`

Then I changed it like `value = data[3] == null ? 0 : data[3] as int`

### Notification
Uses the 
[AndroidAlarmManager](https://pub.dev/packages/android_alarm_manager_plus)
to create a next exercise notification.
However callbacks are executed in the alarm manager isolation. 
I've used 
[SharedPreferences](https://pub.dev/packages/shared_preferences)
 to save the notification configuration by the app and to load the config by the callback method.
 The notification config instance is serialized as Json string and stored as shared preference value.

The [audio players](https://pub.dev/packages/audioplayers) 
produces notification sound.

