- text editing controller is created once
  [#123](https://github.com/oleksabor/work-tracker/issues/123) 

### 1.4.12
- debug page is refreshed when data are imported
- storage access permissions are checked twice 

### 1.4.10
- import|export buttons adjusted
- data are refreshed after debug page closes

### 1.4.9
- export import data as json
- editing numbers from keyboard
- two digits minutes value when is notified 
- notification result according to oneShot method
- UI notification from AlarmManager.oneShot
- Flutter 3.0.5
- AlarmManager 2.0.6

### 1.4.8
- back to AlarmManager 2.0.5

### 1.4.7
- back to Flutter 3.0.1

### 1.4.6
- back to android_alarm_manager_plus: 2.0.6

### 1.4.5 
- back to Flutter 3.0.5

### 1.4.2
- UI notification from AlarmManager.oneShot
- new Flutter 3.3.2 version

### 1.4.1
- notification result according to oneShot method

### 1.4.0
- export import data as json
- editing numbers from keyboard
- two digits minutes value when is notified 

### 1.3.5
- release build (no debug)
- notification settings expanded for text labels

### 1.3.4
- debuggable test build

### 1.3.3
- error notification
  [#99](https://github.com/oleksabor/work-tracker/issues/99) 

### 1.3.2
- config box is cleared on save

### 1.3.1
- old config reading fixed 
  [#97](https://github.com/oleksabor/work-tracker/issues/97) 

### 1.3.0
- body weight history is preserved (if adjusted)
- new item title fixed

### 1.2.0
- chart legend captions rows are calculated according screen width
- check for midnight adjusted in smart date to string

### 1.1.3
- notification volume 
- SET_ALARM permission

### 1.1.2
- showWhenLocked was added to manifest

### 1.1.1
- turnScreenOn was added to manifest

### 1.1.0
- group items by id on debug page
- showWhenLocked and turnScreenOn were removed from manifest

### 1.0.1
- upgrade db result fixed
- semantic labels on +- icons
- chart data ordered by date
- dummy data can be seed (for GooglePlay screens on tablet devices)

### 1.0.0
- application icon

### 0.14.2
- waking up the locked screen

### 0.14.1
- list view scrolling adjusted
- item is being removed when the whole kind is removed

### 0.14.0
- work kind CRUD
- notification sound when phone is locked

### 0.13.2
- sound after exercise fixed
- config notify serialization to json
- app start fixed
- item is not deleted if user does not click on popup item

### 0.13.0
- work item can be removed from history 
  [#35](https://github.com/oleksabor/work-tracker/issues/35)
- work items history browsing fixed
  [#33](https://github.com/oleksabor/work-tracker/issues/33)
- notification config controls were rearranged
  [#40](https://github.com/oleksabor/work-tracker/issues/40)

### 0.12.0
- ringnote player for notification
  [#29](https://github.com/oleksabor/work-tracker/issues/29)
- system notification sound is supported

### 0.11.1
- AudioPlayer for notification 
  [#20](https://github.com/oleksabor/work-tracker/issues/20) 
  [#22](https://github.com/oleksabor/work-tracker/issues/22)
- commit for notification config 
  [#19](https://github.com/oleksabor/work-tracker/issues/19)

### 0.11.0
- next exercise notification (using sound generator)

### 0.10.0
- old structure support (checking for field count when reading)
- chart data have exercise weight coefficient applied when configured [#10](https://github.com/oleksabor/work-tracker/issues/10)

### 0.9.1
- empty directories fixed [#8](https://github.com/oleksabor/work-tracker/issues/8)

### 0.9.0
- work items are linked by integer key
- debug page shows item kind and total items quantity
