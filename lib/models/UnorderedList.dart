import 'package:flutter/material.dart';
import 'package:grocery_store/config/colorsFile.dart';

import '../localization/localization_methods.dart';

class UnorderedList extends StatelessWidget {
  UnorderedList(this.texts);
  final List<String> texts;

  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      // Add list item
      widgetList.add(UnorderedListItem(text));
      // Add space between items
      widgetList.add(SizedBox(height: 20.0));

    }

    return Column(children: widgetList);
  }
}

class UnorderedListItem extends StatelessWidget {
  UnorderedListItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text("• ",style:TextStyle( fontFamily: getTranslated(context, 'Ithra'),
            color: AppColors.pureBlack,
            fontSize: 15.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),),
        Expanded(
          child: Text(text,style:TextStyle( fontFamily: getTranslated(context, "Ithra"),
            color: AppColors.pureBlack,
            fontSize: 13.0,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),),
        ),
      ],
    );
  }
}