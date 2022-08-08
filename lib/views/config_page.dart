import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_tracker/classes/config_notify.dart';
import 'package:work_tracker/classes/init_get.dart';
import 'package:work_tracker/classes/notify_model.dart';
import 'package:work_tracker/views/numeric_step_button.dart';
import 'package:simple_logger/simple_logger.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return ConfigPageState();
  }
}

class ConfigPageState extends State<ConfigPage> {
  late ConfigModel configModel;
  final _formKey = GlobalKey<FormState>();
  final loggerF = getIt.getAsync<SimpleLogger>();
  SimpleLogger? logger;
  final notifyModel = getIt.get<NotifyModel>();

  @override
  void initState() {
    super.initState();
    configModel = getIt<ConfigModel>();
    configRead = configModel.load().then((c) {
      initConfig(c);

      return c;
    });
  }

  void initConfig(Config c) {
    isPlaying = false;
    notifyModel.init(c, opc: (value) {
      if (kDebugMode) {
        logger?.fine('notification sound $value');
      }
      setState(() {
        isPlaying = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);

    var tabs = {
      t!.titleConfigChart: buildChartsTab,
      t.titleConfigNotify: buildNotifyTab,
      t.titleConfigLog: buildLogsTab,
    };
    return WillPopScope(
        onWillPop: () async {
          if (_formKey.currentState == null ||
              _formKey.currentState!.validate()) {
            await saveConfig(context);
            return true;
          }
          return false;
        },
        child: Form(
            key: _formKey,
            child: FutureBuilder<SimpleLogger>(
                future: loggerF,
                builder: (c, s) {
                  logger = s.hasData ? s.data : null;
                  return DefaultTabController(
                    length: tabs.length,
                    child: Scaffold(
                        appBar: AppBar(
                          title: Text(t!.titleConfig),
                          bottom: TabBar(
                              tabs:
                                  tabs.keys.map((c) => Tab(text: c)).toList()),
                        ),
                        body: TabBarView(
                            children: tabs.values
                                .map((v) => buildTab<Config>(configRead, v))
                                .toList())),
                  );
                })));
  }

  FutureBuilder<T> buildTab<T>(
      Future<T>? value, Function(BuildContext, T?) buildFunction) {
    return FutureBuilder<T>(
      future: value,
      builder: (context, snapshot) => snapshot.hasData
          ? buildFunction(context, snapshot.data)
          : const CircularProgressIndicator(),
    );
  }

  Future<Config>? configRead;
  Config? config; // is initialized by [buildChartsTab] method

  saveConfig(BuildContext context) async {
    await configModel.save(await configRead);
  }

  setGraphWeight(bool v) {
    if (configRead != null) {
      config!.graph.weight4graph = v;
    }
  }

  setGraphWeightCoefficient(int v) {
    if (configRead != null) {
      config!.graph.bodyWeight = v.toDouble();
    }
  }

  late IgnorePointer weightPointer;

  Widget buildLogsTab(BuildContext context, Config? config) {
    var t = AppLocalizations.of(context)!;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(t.logCallerInfo),
        Switch(
          value: config!.log.includeCallerInfo,
          onChanged: (v) => setState(() => setLogCaller(v)),
        )
      ]),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(t.logLevel),
        DropdownButton<String>(
          value: config.log.logLevel,
          items: getLogLevelItems(config.log.getAll()),
          onChanged: (l) => setState(() => changedLevelItem(l)),
        )
      ]),
    ]);
  }

  Widget buildChartsTab(BuildContext context, Config? config) {
    var t = AppLocalizations.of(context)!;

    if (kDebugMode) {
      logger?.fine('weight coefficient ${config!.graph.bodyWeight}');
    }
    this.config = config;
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(t.weight4graph),
        Switch(
          value: config!.graph.weight4graph,
          onChanged: (v) {
            setState(() => setGraphWeight(v));
          },
        )
      ]),
      IgnorePointer(
          ignoring: !config.graph.weight4graph,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text(t.bodyWeight),
            NumericStepButton(
                value: config.graph.bodyWeight.toInt(),
                minValue: 30,
                onChanged: setGraphWeightCoefficient),
          ])),
      Text(t.bodyWeightDescription,
          style: const TextStyle(fontStyle: FontStyle.italic))
    ]);
  }

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
          SizedBox(height: 5),
          Row(children: [Text(t.volumeLabel)]),
          sliderContainer('$volumeInt %', notify.volume, (v) {
            notify.volume = v.toDouble();
          }),
          SizedBox(height: 5),
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
      SizedBox(height: 5),
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
      SizedBox(height: 5),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(t!.playSoundLabel),
        Switch(
          value: notify.playAfterNewResult,
          onChanged: (v) {
            setState(() => notify.playAfterNewResult = v);
          },
        )
      ]),
      SizedBox(height: 5),
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

  bool isPlaying = false;

  setLogCaller(bool v) {
    if (configRead != null) {
      config!.log.includeCallerInfo = v;
    }
  }

  void changedLevelItem(String? v) {
    if (configRead != null) {
      config!.log.logLevel = v ?? config!.log.defaultLevel();
    }
  }

  List<DropdownMenuItem<String>> getLogLevelItems(List<String> levels) {
    return levels
        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
        .toList();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    notifyModel.dispose();
    if (kDebugMode) {
      logger?.fine('config state was disposed');
    }
  }
}
