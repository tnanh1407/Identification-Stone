import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingPageUser extends StatelessWidget {
  const SettingPageUser({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('main_nav.settings'.tr())),
      body: Center(child: Text('main_nav.settings'.tr(), style: TextStyle(fontSize: 24))),
    );
  }
}
