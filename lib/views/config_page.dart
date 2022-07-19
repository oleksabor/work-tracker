import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:work_tracker/classes/config.dart';
import 'package:work_tracker/classes/config_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ConfigPage extends StatelessWidget {
  final ConfigModel configModel = ConfigModel();

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context);

    return WillPopScope(
        onWillPop: () async {
          await saveConfig(context, configRead);
          return true;
        },
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
                  future: configModel.load(),
                  builder: (context, snapshot) => snapshot.hasData
                      ? buildChartsTab(context, snapshot.data)
                      : const CircularProgressIndicator(),
                )
              ]),
            )));
  }

  Config? configRead;

  saveConfig(BuildContext context, Config? config) async {
    await configModel.save(config);
  }

  Widget buildChartsTab(BuildContext context, Config? config) {
    var t = AppLocalizations.of(context);
    configRead = config;
    return Expanded(
        child: Column(children: [
      Row(children: [
        Text(t!.weight4graph),
        Switch(
          value: config!.graph.weight4graph,
          onChanged: (v) => config.graph.weight4graph = v,
        )
      ]),
      Row(children: [
        Text(t.weight4graphCoefficient),
        SizedBox(
            width: 40,
            child: TextField(
              controller: TextEditingController(
                  text:
                      config.graph.weight4graphCoefficient.toStringAsFixed(2)),
              keyboardType: const TextInputType.numberWithOptions(
                  decimal: true, signed: false),
              onChanged: (v) =>
                  config.graph.weight4graphCoefficient = double.parse(v),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r"[0-9.]")),
                TextInputFormatter.withFunction((oldValue, newValue) {
                  try {
                    final text = newValue.text;
                    if (text.isNotEmpty) double.parse(text);
                    return newValue;
                  } catch (e) {}
                  return oldValue;
                }),
              ],
            ))
      ])
    ]));
  }
}
