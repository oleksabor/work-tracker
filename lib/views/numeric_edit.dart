import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// contains Row with [title] and [value]
class NumericEdit extends StatefulWidget {
  final String? title;
  double value;
  int fraction = 2;
  Function(double)? onChanged;
  Function(double)? onSubmitted;
  final double? min;
  final double? max;

  NumericEdit(this.title, this.value,
      {this.onChanged, this.onSubmitted, this.min, this.max, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NumericEditState();
  }
}

class _NumericEditState extends State<NumericEdit> {
  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    textController = TextEditingController(
        text: widget.value.toStringAsFixed(widget.fraction));
    super.initState();
  }

  String? validateText(String? v) {
    if (v == null || v.isEmpty) {
      return 'no text value';
    }
    if (widget.min != null && widget.min! > widget.value) {
      return 'min value ${widget.min} violated';
    }
    if (widget.max != null && widget.max! < widget.value) {
      return 'max value ${widget.max} violated';
    }
    return null;
  }

  late TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    var children = <Widget>[
      SizedBox(
          width: 50,
          child: TextFormField(
            textAlign: TextAlign.center,
            controller: textController,
            validator: validateText,
            keyboardType: const TextInputType.numberWithOptions(
                decimal: true, signed: false),
            onChanged: (v) {
              widget.value = double.parse(v);
              if (widget.onChanged != null) {
                widget.onChanged!(widget.value);
              }
            },
            onFieldSubmitted: (v) {
              widget.value = double.parse(v);
              if (widget.onSubmitted != null) {
                widget.onSubmitted!(widget.value);
              }
            },
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
    ];
    if (widget.title != null) {
      children.insert(0, Text(widget.title!));
    }
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, children: children);
  }
}
