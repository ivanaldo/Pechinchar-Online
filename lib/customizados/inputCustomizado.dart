import 'package:flutter/material.dart';

class InputCustomizado extends StatelessWidget {

  final String hint;
  final bool obscure;
  final icon;
  final TextEditingController controller;

  InputCustomizado(
      {@required this.hint,
      this.obscure = false,
      this.icon = const Icon(Icons.person),
      this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: controller,
        style: TextStyle(
            fontSize: 20
        ),
          obscureText: this.obscure,
          decoration: InputDecoration(
            labelText: this.hint,
            contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
              prefixIcon: this.icon,
              hintText: this.hint,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0)
              )
          )
      ),
    );
  }
}
