import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mdi/mdi.dart';
import 'package:vortaron/wordclass.dart';

class ThesaurusTab extends StatelessWidget {
  final ThesaurusDefinition thesaurus;
  const ThesaurusTab({super.key, required this.thesaurus});

  @override
  Widget build(BuildContext context) {
    if (thesaurus == const ThesaurusDefinition()) return Center(child: Text("No thesaurus entries found!"));
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        if (thesaurus.synonyms.isNotEmpty) ...section(theme, tr("thesaurus.synonyms"), thesaurus.synonyms),
        if (thesaurus.antonyms.isNotEmpty) ...section(theme, tr("thesaurus.antonyms"), thesaurus.antonyms),
        if (thesaurus.homonyms.isNotEmpty) ...section(theme, tr("thesaurus.homonyms"), thesaurus.homonyms),
        if (thesaurus.hypernyms.isNotEmpty) ...section(theme, tr("thesaurus.hypernyms"), thesaurus.hypernyms),
        if (thesaurus.hyponyms.isNotEmpty) ...section(theme, tr("thesaurus.hyponyms"), thesaurus.hyponyms),
        if (thesaurus.meronyms.isNotEmpty) ...section(theme, tr("thesaurus.meronyms"), thesaurus.meronyms),
        if (thesaurus.holonyms.isNotEmpty) ...section(theme, tr("thesaurus.holonyms"), thesaurus.holonyms),
      ],
    );
  }

  List<Widget> section(ThemeData theme, String title, List<String> entries) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: theme.textTheme.headline6),
        )
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate((context, index) => ListTile(
          title: Text(entries[index]),
          // subtitle: "", // TODO: add senses, gender, and/or qualifiers
          dense: true,
          trailing: Icon(Mdi.chevronRight),
          onTap: () => {},
        ), childCount: entries.length),
      ),
    ];
  }
}