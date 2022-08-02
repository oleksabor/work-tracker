# work_tracker

Test Flutter project to track my workout notes.

Stores workout log data using Flutter [Hive Db](https://docs.hivedb.dev/#/) 

Uses the 
[AndroidAlarmManager](https://pub.dev/packages/android_alarm_manager_plus)
to create a next exercise notification.
However callbacks are executed in the alarm manager isolation. 
I've used 
[SharedPreferences](https://pub.dev/packages/shared_preferences)
 to save the notification configuration by the app and to load the config by the callback method.

The [sound generator](https://pub.dev/packages/sound_generator) 
produces notification sound.
