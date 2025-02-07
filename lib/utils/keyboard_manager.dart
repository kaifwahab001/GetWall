import 'package:flutter/cupertino.dart';

class KeyboardManager{
  static void  keyboarmanager(BuildContext context){
    FocusScopeNode scope = FocusScope.of(context);
    if(!scope.hasPrimaryFocus){
      scope.unfocus();
    }
  }
}