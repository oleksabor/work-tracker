part of 'config_page.dart';

extension ConfigPageUI on ConfigPageState {
// those controls are arranged in a column
  List<Widget> uiControls(AppLocalizations t, ConfigUI config) {
    var qtyFontMulti = config.qtyFontMulti;
    if (qtyFontMulti == 0) qtyFontMulti = 1.0;

    List<Widget> res = [
      const SizedBox(height: 25),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(t.fontSizeLabel),
        Slider(
          value: qtyFontMulti,
          min: 1,
          max: 4,
          divisions: 6,
          label: qtyFontMulti.toString(),
          onChanged: (double value) {
            setState(() {
              qtyFontMulti = config.qtyFontMulti = value;
            });
          },
        ),
      ]),
      NumericEdit(t.sampleLabel, qtyFontMulti)
        ..fontSizeMulti = qtyFontMulti
        ..fraction = 1,
    ];
    return res;
  }
}
