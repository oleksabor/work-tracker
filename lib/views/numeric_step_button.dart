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

  @override
  Widget build(BuildContext context) {
    counter = widget.value ?? counter;
    widget.value = null; // reset after first use
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          icon: Icon(
            Icons.remove,
            // color: Theme.of(context).secondaryHeaderColor,
          ),
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
          iconSize: 32.0,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              var minValue = widget.minValue ?? (counter - 1);
              if (counter > minValue) {
                counter--;
              }
              widget.onChanged(counter);
              setState(() {});
            });
          },
        ),
        Text(
          '$counter',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add,
            //color: Theme.of(context).secondaryHeaderColor,
          ),
          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
          iconSize: 32.0,
          color: Theme.of(context).primaryColor,
          onPressed: () {
            setState(() {
              var maxValue = widget.maxValue ?? (counter + 1);
              if (counter < maxValue) {
                counter++;
              }
              widget.onChanged(counter);
            });
          },
        ),
      ],
    );
  }
}
