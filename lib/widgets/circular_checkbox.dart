import 'package:flutter/material.dart';

class CircularCheckbox extends StatefulWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;

  const CircularCheckbox({Key? key, required this.value, required this.onChanged}) : super(key: key);

  @override
  State<CircularCheckbox> createState() => _CircularCheckboxState();
}

class _CircularCheckboxState extends State<CircularCheckbox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onChanged(!widget.value);
      },
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.value ? Colors.blue : Colors.transparent,
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: widget.value ? Icon(Icons.check, color: Colors.white, size: 12) : null,
      ),
    );
  }
}
