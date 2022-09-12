import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:html/dom.dart' as dom;
import 'package:vortaron/constants.dart';
import 'package:vortaron/query.dart';
import 'package:vortaron/views/home.dart';

import '../views/definition.dart';

final emptySpan = WidgetSpan(child: Container(height: 0, width: 0));

class RichHtml {
  final dom.Node element;
  final ThemeData theme;
  final bool inlineOnly;
  final BuildContext? context;
  RichHtml(this.element, this.theme, [this.context, this.inlineOnly = false]);
  InlineSpan build() {
    List<InlineSpan> buildAgain({List<dom.Node>? nodes, bool? inlineOnly}) {
      return (nodes ?? element.nodes)
        .map((e) => RichHtml(e, theme, context, inlineOnly ?? this.inlineOnly).build())
        .where((e) => e != emptySpan)
        .toList();
    }
    if (element is dom.Text) {
      return TextSpan(text: element.text);
    } else if (element is dom.Element) {
      final element = this.element as dom.Element;
      if (element.localName == 'br') {
        //return TextSpan(text: "\n");
        return emptySpan;
      } else if (element.localName == 'i' || element.localName == 'em') {
        return TextSpan(
          children: buildAgain(),
          style: TextStyle(fontStyle: FontStyle.italic),
        );
      } else if (element.localName == 'b' || element.localName == 'strong') {
        return TextSpan(
          children: buildAgain(),
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      } else if (element.localName == 'a') {
        final link = _WikiLink(element.attributes['href']!);
        final _knownLanguages = knownWordLanguages.map((e) => languageNames["en"]?.keyOf(e)).toList();
        if (element.attributes['href']?.startsWith("/wiki/") == true && (link.language == null || _knownLanguages.contains(link.language))) {
          return TextSpan(
            text: element.text,
            // children: element.nodes
            //     .map((e) => InlineHtml(e, theme).build())
            //     .toList(),
            style: TextStyle(color: theme.primaryColor),
            mouseCursor: SystemMouseCursors.click,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (this.context == null) {
                  return; // don't do anything if there is no context
                }
                final context = this.context!;
                final langCode = link.language == null ? "en" : languageNames["en"]?[link.language] ?? "en";
                final _x = lookupWord(link.article, langCode, "English");
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
                      .tr(namedArgs: {"word": link.article, "wordLang": langCode, "appLang": "English"}),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text("buttons.ok").tr())
                    ]
                  )
                ));
              }
          );
        } else if (element.attributes['href']?.startsWith("/wiki/") == true && link.article == tr("lookup.glossary")) {
          return TextSpan(
            text: element.text,
            style: TextStyle(
              decorationColor: theme.disabledColor,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.solid,
              decorationThickness: 1
            )
          );
        } else if (element.attributes['href']?.startsWith("/wiki/") == true) {
          return TextSpan(
            text: element.text,
            style: TextStyle(
              decorationColor: theme.colorScheme.primary,
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationThickness: 1
            )
          );
        } else {
          return TextSpan(
            children: buildAgain()
          );
        }
      } else if (element.localName == 'ul' && element.getElementsByClassName("citation-whole").length > 0) {
        return emptySpan; // an empty span; don't show these
      } else if (element.localName == 'ul' && element.getElementsByTagName("dl").length > 0) {
        return emptySpan; // an empty span; don't show these
      } else if (!inlineOnly && element.localName == 'ul') {
        return WidgetSpan(child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Container(
                  //width: 24,
                  child: Text(" · ", textAlign: TextAlign.end)
                ),
              ),
              Expanded(
                child: Text.rich(TextSpan(
                children: buildAgain(nodes: element.getElementsByTagName("li"))))
              )
            ]
          )
        ));
      } else if (element.localName == 'div' && element.classes.contains("h-usage-example")) {
        return TextSpan(
          //text: "\n",
          children: buildAgain(),
          style: TextStyle(
            color: theme.textTheme.bodyText1?.color?.withOpacity(0.7)
          )
        );
      } else if (element.localName == 'div' && element.classes.contains("citation-whole")) {
        return emptySpan; // an empty span; don't show these
      }
    }
    // Fallback behavior: parse the children, ignoring the tag
    if (element.nodes.length == 0) return emptySpan;
    return TextSpan(children: buildAgain());
  }
}

class _WikiLink {
  final String article;
  final String? language;
  _WikiLink._(this.article, this.language);
  factory _WikiLink(String href) {
    final parts = href.replaceFirst("/wiki/", "").split('#');
    final _fragment = parts.length > 1 ? parts[1] : null;
    final _article = parts[0];
    return _WikiLink._(_article, _fragment);
  }
}
