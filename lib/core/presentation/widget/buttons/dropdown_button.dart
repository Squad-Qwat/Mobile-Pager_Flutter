import 'package:flutter/material.dart';

class CustomDropdownButton extends StatelessWidget 
{
  final Map<String, String> options; // <value: text>
  final String? selectedValue;
  final Function(String?) onChanged;
  final String? hintText;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? width;

  const CustomDropdownButton({
    Key? key,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
    this.hintText = 'Pilih opsi',
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) 
  {
    return Container(
      width: width,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedValue,
          hint: Text(
            hintText!,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down, 
            color: textColor ?? Colors.black87
          ),
          style: TextStyle(
            color: textColor ?? Colors.black87,
            fontSize: 16,
          ),
          items: options.entries.map((entry) 
          {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(growable: true),
          onChanged: onChanged,
        ),
      ),
    );
  }
}