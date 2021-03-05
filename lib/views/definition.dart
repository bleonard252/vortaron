import 'package:flutter/material.dart';
import 'package:vortaron/wordclass.dart';
import 'package:vortaron/query.dart' show enValidPartsOfSpeech;
import 'package:easy_localization/easy_localization.dart';

class DefinitionScreen extends StatelessWidget {
  late final Definition definition;

  DefinitionScreen({Key? key, required this.definition}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(definition.hyphenation ?? "Unknown word"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Wrap( // for icons. not yet implemented
              children: [
                // lemmas
              ],
            ),
            //TODO: the icons and the explanation banner
            if (definition.etymology != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("definitionScreen.etymology", style: Theme.of(context).textTheme.headline4).tr(),
            ),
            if (definition.etymology != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(definition.etymology ?? ""),
            ),
            for (var part in definition.partsOfSpeech) ...[
              Text("definitionScreen.${part.part.toString()}", style: Theme.of(context).textTheme.headline4).tr(),
              for (var def in part.definitions) Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${(part.definitions.indexOf(def)+1).toString()}. $def"),
              )
            ]
          ],
        ),
      ),
    );
  }
}