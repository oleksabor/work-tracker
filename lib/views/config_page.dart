import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:work_tracker/views/numeric_step_button.dart';
import 'numeric_edit.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return ConfigPageState();
  }
}

class ConfigPageState extends State<ConfigPage> {
  final ConfigModel configModel = ConfigModel();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
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
            child: DefaultTabController(
                length: 1,
                child: Scaffold(
                  appBar: AppBar(
                    title: Text(t!.titleConfig),
                    bottom: TabBar(
                      tabs: [
                        Tab(text: t.titleConfigChart),
                      ],
                    ),
                  ),
                  body: TabBarView(children: [
                    FutureBuilder<Config>(
                      future: configRead,
                      builder: (context, snapshot) => snapshot.hasData
                          ? buildChartsTab(context, snapshot.data)
                          : const CircularProgressIndicator(),
                    )
                  ]),
                ))));
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

  Widget buildChartsTab(BuildContext context, Config? config) {
    var t = AppLocalizations.of(context)!;

    if (kDebugMode) {
      print('weight coefficient ${config!.graph.bodyWeight}');
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
          child: NumericStepButton(
              value: config.graph.bodyWeight.toInt(),
              minValue: 30,
              onChanged: setGraphWeightCoefficient))
    ]);
  }
}
