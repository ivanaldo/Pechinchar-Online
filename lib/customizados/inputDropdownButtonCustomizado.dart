import 'package:flutter/material.dart';

class InputDropdownButtonCustomizado extends StatelessWidget {

  final String value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final onChanged;
  final icon;

  const InputDropdownButtonCustomizado({@required
    this.value,
    this.hint,
    this.items,
    this.onChanged,
    this.icon = const Icon(Icons.account_balance_outlined)});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: DropdownButtonFormField(
        isExpanded: true,
        decoration: InputDecoration(
          labelText: this.hint,
            prefixIcon: this.icon,
            contentPadding:
            EdgeInsets.fromLTRB(2, 16, 2, 16),
            fillColor: Colors.transparent,
            filled: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25))),
        value: this.value,
        hint: Text(this.hint),
        items: items,
        onChanged: this.onChanged
      ),
    );
  }
}
