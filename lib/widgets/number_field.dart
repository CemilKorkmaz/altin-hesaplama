import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class NumberField extends StatelessWidget {
  const NumberField({
    super.key,
    required this.label,
    required this.controller,
    required this.placeholder,
    this.suffix,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String placeholder;
  final String? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]'))],
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F4F0),
            borderRadius: BorderRadius.circular(12),
          ),
          suffix: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Text(suffix!, style: const TextStyle(color: CupertinoColors.systemGrey)),
                ),
        ),
      ],
    );
  }
}
