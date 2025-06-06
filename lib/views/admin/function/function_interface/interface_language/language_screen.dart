import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String selectedLanguage;


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedLanguage = context.locale.languageCode;
  }

  void changeLanguage(String languageCode) {
    setState(() {
      selectedLanguage = languageCode;
    });
    context.setLocale(Locale(languageCode));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFFF7F7F7),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text("change_language".tr(), style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(
              'vietnamese'.tr(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            trailing: selectedLanguage == 'vi' ? Icon(Icons.check, color: Colors.green) : null,
            onTap: () => changeLanguage('vi'),
          ),
          Divider(height: 1, color: Colors.grey[300]),
          ListTile(
            title: Text(
              'english'.tr(),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            trailing: selectedLanguage == 'en' ? Icon(Icons.check, color: Colors.green) : null,
            onTap: () => changeLanguage('en'),
          ),
          Divider(height: 1, color: Colors.grey[300]),
        ],
      ),
    );
  }
}
