import 'package:flutter/material.dart';
import 'package:work_tracker/views/numeric_edit.dart';

// https://stackoverflow.com/a/65271573/940182
class NumericStepButton extends StatefulWidget {
  int? minValue;
  int? maxValue;
  int? value;

  /// multiplier to increase font size (optional)
  double? fontSizeMulti;

  /// increment icon content description for screen readers
  String incrementContent;

  /// decrement icon content description for screen readers
  String decrementContent;
  final ValueChanged<int> onChanged;

  NumericStepButton(
      {Key? key,
      this.value,
      this.minValue,
      this.maxValue,
      required this.onChanged,
      this.decrementContent = "",
      this.incrementContent = ""})
      : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;

  void increment(int delta, {int count = 0}) {
    setState(() {
      if (count > 5) {
        delta *= 2;
      }
      var maxValue = widget.maxValue ?? (counter + delta);
      if (counter < maxValue) {
        if (counter + delta <= maxValue) {
          counter += delta;
        } else {
          counter = maxValue;
        }
      }
      widget.onChanged(counter);
    });
  }

  void decrement(int delta, {int count = 0}) {
    setState(() {
      if (count > 5) {
        delta *= 2;
      }
      var minValue = widget.minValue ?? (counter - delta);
      if (counter > minValue) {
        if (counter - delta >= minValue) {
          counter -= delta;
        } else {
          counter = minValue;
        }
      }
      widget.onChanged(counter);
      setState(() {});
    });
  }

  void cancelPress() {
    setState(() {
      isPressed = false;
    });
  }

  void startPressing(Function(int count) fu) async {
    isPressed = true;
    int q = 0;
    do {
      q++;
      fu(q);
      await Future.delayed(const Duration(milliseconds: 600));
    } while (isPressed);
  }

  late bool isPressed;

  Widget buildIcon(void Function(int, {int count}) onPressed, IconData? icon,
      String semanticLabel) {
    return GestureDetector(
      child: IconButton(
        onPressed: () => onPressed(1),
        icon: Icon(
          semanticLabel: semanticLabel,
          icon,
          //color: Theme.of(context).secondaryHeaderColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
        color: Theme.of(context).iconTheme.color,
      ),
      onLongPressStart: (_) async {
        startPressing((c) => onPressed(10, count: c));
      },
      onLongPressCancel: () {
        cancelPress();
      },
      onLongPressEnd: (_) {
        cancelPress();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    counter = widget.value ?? counter;
    widget.value = null; // reset after first use
    if (widget.minValue != null && counter < widget.minValue!) {
      counter = widget.minValue!;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildIcon((i, {int count = 0}) => decrement(i, count: count),
            Icons.remove, widget.decrementContent),
        NumericEdit(
          null,
          counter.toDouble(),
          min: widget.minValue?.toDouble(),
          max: widget.maxValue?.toDouble(),
          onChanged: (p0) {
            counter = p0.toInt();
            widget.onChanged(counter);
            setState(() {});
          },
        )
          ..fraction = 0
          ..fontSizeMulti = widget.fontSizeMulti,
        buildIcon((i, {int count = 0}) => increment(i, count: count), Icons.add,
            widget.incrementContent),
      ],
    );
  }
}
