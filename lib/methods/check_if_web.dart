

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool checkIfWeb(context){
  return kIsWeb||(MediaQuery.of(context).size.width >= 500)? true: false;
}