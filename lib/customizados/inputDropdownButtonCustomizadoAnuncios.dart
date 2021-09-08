import 'package:flutter/material.dart';

class InputDropdownButtonCustomizadoAnuncios extends StatelessWidget {

  final String value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final onChanged;
  final icon;
  final Function(String) validator;

  const InputDropdownButtonCustomizadoAnuncios({@required
  this.value,
    this.hint,
    this.items,
    this.onChanged,
    this.icon = const Icon(Icons.account_balance_outlined),
    this.validator,});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
              labelText: this.hint,
              contentPadding:
              EdgeInsets.fromLTRB(32, 16, 2, 16),
              fillColor: Colors.transparent,
              filled: true,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25))),
          value: this.value,
          validator: this.validator,
          hint: Text(this.hint),
          items: items,
          onChanged: this.onChanged
      ),
    );
  }
}
