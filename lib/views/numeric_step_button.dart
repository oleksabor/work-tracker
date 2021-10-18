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
        counter += delta;
      }
      widget.onChanged(counter);
    });
  }

  void decrement(int delta) {
    setState(() {
      var minValue = widget.minValue ?? (counter - delta);
      if (counter > minValue) {
        counter -= delta;
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

  @override
  Widget build(BuildContext context) {
    counter = widget.value ?? counter;
    widget.value = null; // reset after first use
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          child: Container(
            child: const Icon(
              Icons.remove,
              // color: Theme.of(context).secondaryHeaderColor,
            ),
            padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 18.0),
            // color: Theme.of(context).primaryColor,
          ),
          onTap: () {
            decrement(1);
          },
          onLongPressStart: (_) async {
            startPressing(() => decrement(10));
          },
          onLongPressCancel: () {
            cancelPress();
          },
          onLongPressEnd: (_) {
            cancelPress();
          },
        ),
        Text(
          '$counter',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          child: Container(
            child: const Icon(
              Icons.add,
              //color: Theme.of(context).secondaryHeaderColor,
            ),
            padding: EdgeInsets.symmetric(vertical: 6.0, horizontal: 18.0),
          ),
          onTap: () {
            increment(1);
          },
          onLongPressStart: (_) async {
            startPressing(() => increment(10));
          },
          onLongPressCancel: () {
            cancelPress();
          },
          onLongPressEnd: (_) {
            cancelPress();
          },
        ),
      ],
    );
  }
}
