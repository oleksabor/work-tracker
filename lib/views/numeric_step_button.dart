import 'package:flutter/material.dart';

// https://stackoverflow.com/a/65271573/940182
class NumericStepButton extends StatefulWidget {
  int? minValue;
  int? maxValue;
  int? value;

  final ValueChanged<int> onChanged;

  NumericStepButton(
      {Key? key,
      this.value,
      this.minValue,
      this.maxValue,
      required this.onChanged})
      : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  int counter = 0;

  void increment(int delta) {
    setState(() {
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

  void decrement(int delta) {
    setState(() {
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

  void startPressing(Function() fu) async {
    isPressed = true;
    do {
      fu();
      await Future.delayed(const Duration(milliseconds: 600));
    } while (isPressed);
  }

  late bool isPressed;

  Widget buildIcon(void Function(int) onPressed, IconData? icon) {
    return GestureDetector(
      child: IconButton(
        onPressed: () => onPressed(1),
        icon: Icon(
          icon,
          //color: Theme.of(context).secondaryHeaderColor,
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
        color: Theme.of(context).iconTheme.color,
      ),
      onLongPressStart: (_) async {
        startPressing(() => onPressed(10));
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
        buildIcon((i) => decrement(i), Icons.remove),
        Text(
          '$counter',
          textAlign: TextAlign.center,
          style: const TextStyle(
            // color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        buildIcon((i) => increment(i), Icons.add),
      ],
    );
  }
}
