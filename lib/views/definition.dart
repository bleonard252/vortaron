import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mdi/mdi.dart';
import 'package:vortaron/wordclass.dart';
import 'package:vortaron/query.dart' show enValidPartsOfSpeech;
import 'package:easy_localization/easy_localization.dart';

class DefinitionScreen extends StatelessWidget {
  late final Definition definition;

  DefinitionScreen({Key? key, required this.definition}) : super(key: key);

  void playSound() async {
    assert(definition.audioClip != null);
    final player = AudioPlayer();
    await player.setUrl(definition.audioClip!);
    player.play().then((_) {
      player.stop();
      player.seek(Duration.zero);
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(definition.hyphenation),
        actions: [
          if (definition.audioClip != null && (Platform.isAndroid || Platform.isMacOS || Platform.isIOS || kIsWeb)) 
            IconButton(icon: Icon(Icons.play_arrow), onPressed: playSound)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap( // for icons. not yet implemented
              children: [
                // lemmas
                if (!definition.lemma) Tooltip(
                  message: tr("definitionScreen.indicators.nonlemma"),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Mdi.lambda)
                  )
                ),
                if (definition.isOfficial) Tooltip(
                  message: tr("definitionScreen.indicators.official"),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Mdi.checkDecagram, color: Colors.amber)
                  )
                )
              ],
            ),
            if (definition.etymology != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("definitionScreen.etymology", style: Theme.of(context).textTheme.headline4).tr(),
            ),
            if (definition.etymology != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(definition.etymology ?? ""),
            ),
            for (var part in definition.partsOfSpeech) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("definitionScreen.${part.part.toString()}", style: Theme.of(context).textTheme.headline4).tr(),
              ),
              for (var def in part.definitions) Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                    text: "${(part.definitions.indexOf(def)+1).toString()}. ",
                    children: [WidgetSpan(child: def, alignment: PlaceholderAlignment.top)]
                  ),
                ),
                //child: Text("${(part.definitions.indexOf(def)+1).toString()}. ${def.split('\n').first}"),
              )
            ]
          ],
        ),
      ),
    );
  }
}