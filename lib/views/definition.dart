import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mdi/mdi.dart';
import 'package:vortaron/widgets/html.dart';
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
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(definition.hyphenation),
          actions: [
            if (definition.audioClip != null &&
                (Platform.isAndroid ||
                    Platform.isMacOS ||
                    Platform.isIOS ||
                    kIsWeb))
              IconButton(icon: Icon(Icons.play_arrow), onPressed: playSound)
          ],
          bottom: TabBar(tabs: [
            Tab(
              icon: Icon(Mdi.text),
              text: tr("definitionScreen.tabs.definition"),
            ),
            Tab(
              icon: Icon(Mdi.swapHorizontal),
              text: tr("definitionScreen.tabs.thesaurus"),
            ),
            Tab(
              icon: Icon(Mdi.translate),
              text: tr("definitionScreen.tabs.translation"),
            ),
          ]),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap(
                  //   // for icons. not yet implemented
                  //   children: [
                  //     // lemmas
                  //   ],
                  // ),
                  //TODO: the icons and the explanation banner

                  // the max() below makes it show at least one "etymology" even if there are none
                  for (int i = 0;
                      i < max(1, definition.etymology.length);
                      i++) ...[
                    if (i != 0) Divider(),
                    if (definition.etymology.length > 0 &&
                        definition.etymology[i] != "") ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("definitionScreen.etymology",
                                style: Theme.of(context).textTheme.headline4)
                            .tr(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(definition.etymology[i]),
                      ),
                    ],
                    for (var part in definition.partsOfSpeech
                        .where((e) => e.etymology == i)) ...[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Wrap(
                          children: [
                            Text("definitionScreen.${part.part.toString()}",
                              style: Theme.of(context).textTheme.headline4)
                              .tr(),
                            if (part.qualifiers?.contains("irregular") == true) Tooltip(
                              message: tr("definitionScreen.irregular"),
                              child: IconButton(
                                onPressed: () => null,
                                icon: Icon(Mdi.tableAlert, color: theme.colorScheme.inverseSurface),
                              ),
                            ) else if (part.qualifiers?.contains("highly irregular") == true) Tooltip(
                              message: tr("definitionScreen.irregularHigh"),
                              child: IconButton(
                                onPressed: () => null,
                                icon: Icon(Mdi.tableAlert, color: theme.colorScheme.primary),
                              ),
                            ),
                            if (part.qualifiers?.contains("uncountable") == true) Tooltip(
                              message: tr("definitionScreen.uncountable"),
                              child: IconButton(
                                onPressed: () => null,
                                icon: Icon(Mdi.numericOff),
                              ),
                            ),
                            if (part.qualifiers?.contains("strong") == true) Tooltip(
                              message: tr("definitionScreen.strongVerb"),
                              child: IconButton(
                                onPressed: () => null,
                                icon: Icon(Mdi.formatLetterCaseLower),
                              ),
                            ),
                          ],
                        ),
                      ),
                      for (var def in part.definitions)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: Container(
                                  width: 36,
                                  child: Text("${(part.definitions.indexOf(def) + 1).toString()}. ", textAlign: TextAlign.end)
                                ),
                              ),
                              Expanded(
                                child: Text.rich(TextSpan(
                                children: [
                                  part.definitionMarkup
                                    ?.map((e) =>
                                      RichHtml(e, theme, context)
                                        .build())
                                    .toList()[part.definitions.indexOf(def)] ??
                                    TextSpan(text: def.split('\n').first)
                                ]))
                              )
                            ]
                          )
                        )
                    ]
                  ]
                ],
              ),
            ),
            Center(
              child: Icon(Mdi.alertCircleOutline),
            ),
            Center(
              child: Icon(Mdi.alertCircleOutline),
            )
          ],
        ),
      ),
    );
  }
}
