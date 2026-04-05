import 'package:flutter/material.dart';
class MyButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onpress;
  MyButton({
    required this.title,
    required this.color,
    required this.onpress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Material(
        elevation: 5,
        color: color,
        borderRadius: BorderRadius.circular(10),
        child: MaterialButton(
          onPressed: () => onpress(),
          minWidth: 200,
          height: 42,
          child: Text(title, style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
