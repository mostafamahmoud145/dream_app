
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class TextWidget extends StatelessWidget {
  const TextWidget({
    required this.text, required this.color, required this.size, required this.weight, required this.align, this.lines,this.family});
  final String   text;
  final String?   family;
  final Color color;
  final double size;
  final FontWeight weight;
  final TextAlign align;
  final int?lines;

  @override
  Widget build(BuildContext context) {
    return  Text(
      text,
      textAlign: align,
      maxLines: (lines==null)?1:lines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontFamily:family==null?"Ithra":family,
          fontSize: size,
          color: color,
          fontWeight: weight),
    );
  }
}
class SingleLineTextWidget extends StatelessWidget {
  const SingleLineTextWidget({
    required this.text, required this.color, required this.size, required this.weight, required this.align, required this.family, this.lines});
  final String   text;
  final Color color;
  final double size;
  final FontWeight weight;
  final TextAlign align;
  final String family;
  final String? lines;

  @override
  Widget build(BuildContext context) {
    return  Text(
      text,
      textAlign: align,
      maxLines: (lines==null)?1:int.parse(lines!),
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontFamily:family,// 'Montserrat',
          fontSize: size,
          color: color,
          fontWeight: weight),
    );
  }
}
