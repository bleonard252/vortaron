import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:vortaron/constants.dart';
import 'package:vortaron/wordclass.dart';

class TranslationsTab extends StatelessWidget {
  final Definition definition;
  const TranslationsTab({
    super.key,
    required this.definition,
  });

  @override
  Widget build(BuildContext context) {
    final _fromKnownLanguages = definition.translations.where((t) => languageNames["en"]!.keys.contains(t.language));
    final _fromOtherLanguages = definition.translations.where((t) => !languageNames["en"]!.keys.contains(t.language));
    final __firstGloss = definition.translations.first.gloss;
    final _areMultipleSenses = definition.translations.any((t) => t.gloss != __firstGloss);
    return CustomScrollView(
      slivers: [
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final translation = _fromKnownLanguages.elementAt(index);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(translation.language),
                  subtitle: Text(
                    (_areMultipleSenses
                      ? "${translation.gloss}\n  ${translation.translation}"
                      : translation.translation)
                    +
                    (translation.gender == GrammaticalGender.M
                    ? " (M)"
                    : translation.gender == GrammaticalGender.F
                    ? " (F)"
                    : translation.gender == GrammaticalGender.N
                    ? " (N)"
                    : "")+
                    (translation.qualifiers.isNotEmpty
                      ? " (${translation.qualifiers.join(", ")})"
                      : ""
                    )),
                  trailing: Icon(Mdi.chevronRight),
                  onTap: () => {},
                ),
              );
          }, childCount: _fromKnownLanguages.length),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final translation = _fromOtherLanguages.elementAt(index);
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(translation.language),
                  subtitle: Text(
                    (_areMultipleSenses
                      ? "${translation.gloss}\n  ${translation.translation}"
                      : translation.translation)
                    +
                    (translation.gender == GrammaticalGender.M
                    ? " (M)"
                    : translation.gender == GrammaticalGender.F
                    ? " (F)"
                    : translation.gender == GrammaticalGender.N
                    ? " (N)"
                    : "")+
                    (translation.qualifiers.isNotEmpty
                      ? " (${translation.qualifiers.join(", ")})"
                      : ""
                    )),
                ),
              );
          }, childCount: _fromOtherLanguages.length),
        ),
      ],
    );
  }
}