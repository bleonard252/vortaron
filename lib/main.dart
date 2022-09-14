import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vortaron/views/home.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

late final SharedPreferences sharedPreferences;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  GoogleFonts.config.allowRuntimeFetching = kDebugMode;

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('fonts/roboto/LICENSE.txt');
    yield LicenseEntryWithLineBreaks(['roboto'], license);
  });

  sharedPreferences = await SharedPreferences.getInstance();

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
        textTheme: GoogleFonts.robotoTextTheme(),
        useMaterial3: true,
        primarySwatch: Colors.amber, // TODO: make it red when a "cheating" mode is on
      ),
      home: HomePage(),
      // i18n with easy_localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}