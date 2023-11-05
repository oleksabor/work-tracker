part of 'config_page.dart';

extension ConfigPageUI on ConfigPageState {
// those controls are arranged in a column
  List<Widget> uiControls(AppLocalizations t, ConfigUI config) {
    if (_fontSizeMulti == 0) _fontSizeMulti = config.qtyFontMulti;
    if (_fontSizeMulti == 0) _fontSizeMulti = 1;

    List<Widget> res = [
      const SizedBox(height: 25),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text(t.fontSizeLabel),
        Slider(
          value: _fontSizeMulti,
          min: 1,
          max: 4,
          divisions: 6,
          label: _fontSizeMulti.toString(),
          onChanged: (double value) {
            setState(() {
              _fontSizeMulti = value;
            });
          },
        ),
      ]),
      NumericEdit(t.sampleLabel, _fontSizeMulti)
        ..fontSizeMulti = _fontSizeMulti
        ..fraction = 1,
    ];
    return res;
  }
}
