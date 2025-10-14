import 'package:flutter/material.dart';

/// Um item genérico para ser usado no campo de seleção múltipla.
class MultiSelectItem<T> {
  final T value;
  final String label;

  MultiSelectItem({required this.value, required this.label});
}

/// Um campo de formulário que permite a seleção de múltiplos itens a partir de um diálogo.
/// Os itens selecionados são exibidos como Chips.
class MultiSelectChipField<T> extends StatefulWidget {
  final List<MultiSelectItem<T>> items;
  final String title;
  final String buttonText;
  final Function(List<T>) onSelectionChanged;
  final List<T> initialValue;
  final String? errorText;

  const MultiSelectChipField({
    super.key,
    required this.items,
    required this.title,
    this.buttonText = 'OK',
    required this.onSelectionChanged,
    this.initialValue = const [],
    this.errorText,
  });

  @override
  State<MultiSelectChipField<T>> createState() => _MultiSelectChipFieldState<T>();
}

class _MultiSelectChipFieldState<T> extends State<MultiSelectChipField<T>> {
  late List<T> _selectedValues;

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.initialValue);
  }

  void _showMultiSelect() async {
    final List<T>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        final tempSelectedValues = List<T>.from(_selectedValues);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(widget.title),
              content: SingleChildScrollView(
                child: ListBody(
                  children: widget.items.map((item) {
                    return CheckboxListTile(
                      value: tempSelectedValues.contains(item.value),
                      title: Text(item.label),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (isChecked) {
                        setState(() {
                          if (isChecked ?? false) {
                            tempSelectedValues.add(item.value);
                          } else {
                            tempSelectedValues.remove(item.value);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(widget.buttonText),
                  onPressed: () => Navigator.of(context).pop(tempSelectedValues),
                ),
              ],
            );
          },
        );
      },
    );

    if (results != null) {
      setState(() => _selectedValues = results);
      widget.onSelectionChanged(_selectedValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showMultiSelect,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.title,
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              errorText: widget.errorText,
            ),
            child: Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: _selectedValues
                  .map((value) => Chip(
                        label: Text(widget.items.firstWhere((item) => item.value == value).label),
                        onDeleted: () {
                          setState(() => _selectedValues.remove(value));
                          widget.onSelectionChanged(_selectedValues);
                        },
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}