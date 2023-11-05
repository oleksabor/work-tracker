import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_tracker/classes/config_notify.dart';
import 'package:work_tracker/classes/config_ui.dart';
import 'package:work_tracker/classes/notify_model.dart';
import 'package:work_tracker/views/numeric_edit.dart';
import 'package:work_tracker/views/numeric_step_button.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'config_page_notification.dart';
part 'config_page_ui.dart';

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
  late Future<SimpleLogger> loggerF; // = getIt.getAsync<SimpleLogger>();
  SimpleLogger? logger;
  late NotifyModel notifyModel; // = getIt.get<NotifyModel>();
  double _fontSizeMulti = 0;

  @override
  void initState() {
    super.initState();

    loggerF = RepositoryProvider.of<Future<SimpleLogger>>(context);
    notifyModel = RepositoryProvider.of<NotifyModel>(context);
    configModel = RepositoryProvider.of<ConfigModel>(context);
    configRead = configModel.load().then((c) {
      initConfig(c);

      return c;
    });
  }

  void initConfig(Config c) {
    isPlaying = false;
    notifyModel.init(c, opc: (value) {
      if (kDebugMode) {
        logger?.fine('playing test sound $value');
      }
      setState(() {
        isPlaying = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);

    // here are tabs and tabs creation functions are defined
    var tabs = {
      t!.titleConfigChart: buildChartsTab,
      t.titleConfigNotify: buildNotifyTab,
      t.titleConfigLog: buildLogsTab,
      t.uiLabel: buildUITab,
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
                          title: Text(t.titleConfig),
                          bottom: TabBar(
                              tabs:
                                  tabs.keys.map((c) => Tab(text: c)).toList()),
                        ),
                        body: Column(children: [
                          Flexible(
                              flex: 9,
                              child: TabBarView(
                                  children: tabs.values
                                      .map((v) =>
                                          buildTab<Config>(configRead, v))
                                      .toList())),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              getVersionText(),
                              const SizedBox(width: 10),
                            ],
                          )
                        ])),
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

  Widget buildUITab(BuildContext context, Config? config) {
    var t = AppLocalizations.of(context)!;
    return Column(children: uiControls(t, config!.ui));
  }

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

  Future<String> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    return version;
  }

  FutureBuilder<String> getVersionText() {
    return FutureBuilder<String>(
        future: getAppVersion(),
        initialData: "version",
        builder: (context, snapshot) {
          return snapshot.hasData
              ? Text(snapshot.data!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary))
              : const Center(child: CircularProgressIndicator());
        });
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
                onChanged: setGraphWeightCoefficient,
                decrementContent: t.decrementLabel,
                incrementContent: t.incrementLabel),
          ])),
      Text(t.bodyWeightDescription,
          style: const TextStyle(fontStyle: FontStyle.italic))
    ]);
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
    super.dispose();
    notifyModel.dispose();
    if (kDebugMode) {
      logger?.fine('config state was disposed');
    }
  }
}
