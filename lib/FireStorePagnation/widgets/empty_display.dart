import 'package:flutter/material.dart';
import 'package:grocery_store/localization/localization_methods.dart';

class EmptyDisplay extends StatelessWidget {
  const EmptyDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(getTranslated(context, "noDocuments"),style: TextStyle(fontFamily: getTranslated(context, 'Ithra')),));
  }
}
