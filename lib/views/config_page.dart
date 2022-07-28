import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_tracker/classes/init_get.dart';
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

  @override
  void initState() {
    super.initState();
    configModel = getIt<ConfigModel>();
    configRead = configModel.load();
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);

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
                      length: 2,
                      child: Scaffold(
                        appBar: AppBar(
                          title: Text(t!.titleConfig),
                          bottom: TabBar(
                            tabs: [
                              Tab(text: t.titleConfigChart),
                              Tab(text: t.titleConfigLog),
                            ],
                          ),
                        ),
                        body: TabBarView(children: [
                          FutureBuilder<Config>(
                            future: configRead,
                            builder: (context, snapshot) => snapshot.hasData
                                ? buildChartsTab(context, snapshot.data)
                                : const CircularProgressIndicator(),
                          ),
                          FutureBuilder<Config>(
                            future: configRead,
                            builder: (context, snapshot) => snapshot.hasData
                                ? buildLogsTab(context, snapshot.data)
                                : const CircularProgressIndicator(),
                          ),
                        ]),
                      ));
                })));
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
          ignoring: !config!.graph.weight4graph,
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text(t.bodyWeight),
            NumericStepButton(
                value: config.graph.bodyWeight.toInt(),
                minValue: 30,
                onChanged: setGraphWeightCoefficient)
          ])),
      Text(t.bodyWeightDescription,
          style: const TextStyle(fontStyle: FontStyle.italic))
    ]);
  }

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
}
