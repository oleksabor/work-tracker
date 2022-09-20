part of 'config_page.dart';

extension ConfigPageNotification on ConfigPageState {
  void notificationKindChanged(ConfigNotify notify, NotificationKind? kind) {
    if (kind != null) {
      notify.kind = kind;
    }
  }

// those controls are arranged in a column
  List<Widget> notificationControls(AppLocalizations t, ConfigNotify notify) {
    var volumeInt = (notify.volume * 100).toInt();
    List<Widget> res = [
      const SizedBox(height: 5),
      Row(children: [Text(t.pauseExerciseLabel)]),
      Container(
          width: double.infinity,
          height: 40,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Center(child: Text(t.secondsLabel)),
                ),
                Expanded(
                  flex: 8, // 60%
                  child: NumericStepButton(
                      value: notify.delay,
                      minValue: 1,
                      onChanged: (v) {
                        setState(() => notify.delay = v);
                      },
                      decrementContent: t.decrementLabel,
                      incrementContent: t.incrementLabel),
                ),
              ])),
      Row(children: [Text(t.volumeLabel)]),
      sliderContainer('$volumeInt %', notify.volume, (v) {
        notify.volume = v.toDouble();
      }),
      Row(children: [
        Expanded(
            child: RadioListTile<NotificationKind>(
                title: Text(t.sysNotificationLabel),
                value: NotificationKind.system,
                groupValue: notify.kind,
                onChanged: (v) =>
                    setState(() => notificationKindChanged(notify, v)),
                contentPadding: EdgeInsets.zero))
      ]),
      RadioListTile<NotificationKind>(
          title: Text(t.inbuiltNotificationLabel),
          value: NotificationKind.inbuilt,
          groupValue: notify.kind,
          onChanged: (v) => setState(() => notificationKindChanged(notify, v)),
          contentPadding: EdgeInsets.zero),
      const SizedBox(height: 5),
    ];
    switch (notify.kind) {
      case NotificationKind.system:
        break;
      case NotificationKind.inbuilt:
        res.addAll([
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(t.soundLabel),
            DropdownButton<String>(
                value: notify.notification,
                onChanged: (String? newValue) {
                  setState(() {
                    notify.notification = newValue!;
                  });
                },
                items: notifyModel
                    .getNotifications()
                    .map((String s) =>
                        DropdownMenuItem<String>(value: s, child: Text(s)))
                    .toList())
          ]),
        ]);
    }
    return res;
  }

  void playOrStop(bool isPlaying, ConfigNotify config) {
    isPlaying ? notifyModel.stop() : notifyModel.playTest(config);
  }

  void Function()? onPlayClick(ConfigNotify config) {
    onClick() {
      setState(() => playOrStop(isPlaying, config));
    }

    switch (config.kind) {
      case NotificationKind.system:
        return onClick;
      case NotificationKind.inbuilt:
        return config.notification.isEmpty ? null : onClick;
      default:
        return null;
    }
  }

  //COPIED FROM https://pub.dev/packages/sound_generator/example
  // sad and ugly code - too many controls
  Widget buildNotifyTab(BuildContext context, Config? config) {
    var t = AppLocalizations.of(context)!;
    var notify = config!.notify;
    List<Widget> children = [
      const SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(flex: 3, child: Text(t.playSoundLabel)),
        Expanded(
            flex: 1,
            child: Switch(
              value: notify.playAfterNewResult,
              onChanged: (v) {
                setState(() {
                  notify.playAfterNewResult = v;
                  logger?.fine("playing: $v");
                });
              },
            ))
      ]),
      const SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(flex: 3, child: Text(t.playAsAlarmLabel)),
        Expanded(
            flex: 1,
            child: Switch(
              value: notify.asAlarm,
              onChanged: (v) {
                setState(() => notify.asAlarm = v);
              },
            ))
      ]),
    ];
    children.addAll(notificationControls(t, config.notify));
    var click = onPlayClick(notify);
    children.addAll([
      const SizedBox(height: 5),
      CircleAvatar(
          radius: 30,
          backgroundColor: Colors.lightBlueAccent,
          child: IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              // null onPressed causes button to be disabled
              onPressed: click)),
    ]);
    return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 20,
        ),
        child: Column(children: children));
  }

  Widget sliderContainer(
      String caption, double value, void Function(double v) event,
      {double min = 0, double max = 1}) {
    if (value > max) value = max;
    if (value < min) value = min;
    return Container(
        width: double.infinity,
        height: 40,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Center(child: Text(caption)),
              ),
              Expanded(
                flex: 8, // 60%
                child: Slider(
                    min: min,
                    max: max,
                    value: value,
                    onChanged: (v) {
                      setState(() {
                        event(v);
                      });
                    }),
              ),
            ]));
  }
}
