part of 'config_page.dart';

extension ConfigPageNotification on ConfigPageState {
  void notificationKindChanged(ConfigNotify notify, NotificationKind? kind) {
    if (kind != null) {
      notify.kind = kind;
    }
  }

  List<Widget> notificationControls(AppLocalizations t, ConfigNotify notify) {
    List<Widget> res = [
      ListTile(
          title: Text(t.sysNotificationLabel),
          leading: Radio<NotificationKind>(
            value: NotificationKind.system,
            groupValue: notify.kind,
            onChanged: (v) =>
                setState(() => notificationKindChanged(notify, v)),
          )),
      ListTile(
          title: Text(t.inbuiltNotificationLabel),
          leading: Radio<NotificationKind>(
            value: NotificationKind.inbuilt,
            groupValue: notify.kind,
            onChanged: (v) =>
                setState(() => notificationKindChanged(notify, v)),
          )),
    ];
    var volumeInt = (notify.volume * 100).toInt();
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
          const SizedBox(height: 5),
          Row(children: [Text(t.volumeLabel)]),
          sliderContainer('$volumeInt %', notify.volume, (v) {
            notify.volume = v.toDouble();
          }),
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
                          }),
                    ),
                  ])),
        ]);
    }
    var click = onPlayClick(notify);
    res.addAll([
      const SizedBox(height: 5),
      CircleAvatar(
          radius: 30,
          backgroundColor: Colors.lightBlueAccent,
          child: IconButton(
              icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
              // null onPressed causes button to be disabled
              onPressed: click)),
    ]);
    return res;
  }

  void Function()? onPlayClick(ConfigNotify config) {
    onClick() {
      setState(
          () => isPlaying ? notifyModel.stop() : notifyModel.playTest(config));
    }

    switch (config.kind) {
      case NotificationKind.system:
        return onClick;
      case NotificationKind.inbuilt:
        return config.notification.isEmpty ? null : onClick;
    }
  }

  //COPIED FROM https://pub.dev/packages/sound_generator/example
  Widget buildNotifyTab(BuildContext context, Config? config) {
    var t = AppLocalizations.of(context)!;
    var notify = config!.notify;
    List<Widget> children = [
      const SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t!.playSoundLabel),
        Switch(
          value: notify.playAfterNewResult,
          onChanged: (v) {
            setState(() => notify.playAfterNewResult = v);
          },
        )
      ]),
      const SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t.playAsAlarmLabel),
        Switch(
          value: notify.asAlarm,
          onChanged: (v) {
            setState(() => notify.asAlarm = v);
          },
        )
      ]),
    ];
    children.addAll(notificationControls(t, config.notify));
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
