import 'package:flutter/material.dart';
import 'package:vortaron/views/home.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), /*Locale('eo')*/],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp()
    ),
  );
  //runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vortaron',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: HomePage(),
      // i18n with easy_localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}