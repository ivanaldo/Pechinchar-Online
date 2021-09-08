import 'package:flutter/material.dart';

class InputButtonCustomizado extends StatelessWidget {

  final String text;
  final onPressed;

  InputButtonCustomizado(
      {@required this.text,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        child: Text(this.text,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25.0),
            ),
            padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
            primary: Color(0xff0f530f)),
            onPressed: this.onPressed,
      ),
    );
  }
}
