import 'package:flutter/material.dart';
import '../global_widgets/global_widget.dart';
import '../constants.dart';
import '../s_text_style.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.obscureText = false,
    this.errorText,
    this.focusNode,
    this.textInputType,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.suffixIcon,
    this.autofocus = false,
    this.style,
    this.hintStyle,
    this.fillColor,
    this.focusBorderColor,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final bool obscureText;
  final String? errorText;
  final FocusNode? focusNode;
  final TextInputType? textInputType;
  final int? maxLength;
  final int maxLines;
  final int minLines;
  final Widget? suffixIcon;
  final bool autofocus;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final Color? focusBorderColor;

  OutlineInputBorder outlinedInputBorder (Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 1 * sizeUnit),
    borderRadius: BorderRadius.circular(8 * sizeUnit),
  );

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      cursorColor: iaColorBlack,
      keyboardType: textInputType,
      style: style ?? STextStyle.subTitle3(),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle ?? STextStyle.subTitle3().copyWith(color: iaColorDarkGrey),
        border: outlinedInputBorder(iaColorDarkGrey),
        enabledBorder: outlinedInputBorder(iaColorDarkGrey),
        focusedBorder: outlinedInputBorder(focusBorderColor ?? iaColorBlack),
        errorBorder: outlinedInputBorder(Colors.red),
        contentPadding: EdgeInsets.all(14 * sizeUnit),
        errorText: errorText,
        errorMaxLines: 2,
        errorStyle: STextStyle.subTitle4().copyWith(color: iaColorAlert),
        suffixIcon: suffixIcon,
        counterStyle: STextStyle.subTitle4().copyWith(color: iaColorDarkGrey),
        filled: true,
        fillColor: fillColor ?? Colors.white,
      ),
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      autofocus: autofocus,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}
