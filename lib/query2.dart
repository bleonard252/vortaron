import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:vortaron/constants.dart';
import 'package:vortaron/query.dart';
import 'package:vortaron/views/definition.dart';
import 'package:vortaron/views/home.dart';

doLookup({required BuildContext of, required String word, required String wordLanguageCode, String appLanguage = "English"}) async {
  final context = of;
  final _x = lookupWord(word, wordLanguageCode, appLanguage);
  SpinningScreen.showIn(context, until: _x);
  _x.then((definition) => definition != null ? Navigator.push(
    context, MaterialPageRoute(builder: (context) => DefinitionScreen(definition: definition))
  ) : showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("errors.generic").tr(),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("buttons.ok").tr())
      ]
    )
  )).onError((error, stackTrace) => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        error.toString().contains("not a word") ? "errors.notAWord"
        : error.toString().contains("not found") ? "errors.notFound"
        : "errors.generic")
        .tr(namedArgs: {"word": word, "wordLang": languageNames["en"]?.keyOf(wordLanguageCode) ?? "Unknown", "appLang": "English"}),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("buttons.ok").tr())
      ]
    )
  ));
}