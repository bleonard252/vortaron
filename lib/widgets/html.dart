import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import "package:flutter/material.dart";
import 'package:html/dom.dart' as dom;
import 'package:vortaron/constants.dart';
import 'package:vortaron/query.dart';
import 'package:vortaron/views/home.dart';

import '../views/definition.dart';

class InlineHtml {
  final dom.Node element;
  final ThemeData theme;
  final BuildContext? context;
  InlineHtml(this.element, this.theme, [this.context]);
  InlineSpan build() {
    if (element is dom.Text) {
      return TextSpan(text: element.text);
    } else if (element is dom.Element) {
      final element = this.element as dom.Element;
      if (element.localName == 'br') {
        return TextSpan(text: "\n");
      } else if (element.localName == 'i' || element.localName == 'em') {
        return TextSpan(
          children: element.children
              .map((e) => InlineHtml(e, theme, context).build())
              .toList(),
          style: TextStyle(fontStyle: FontStyle.italic),
        );
      } else if (element.localName == 'b' || element.localName == 'strong') {
        return TextSpan(
          children: element.children
              .map((e) => InlineHtml(e, theme, context).build())
              .toList(),
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
        } else {
          return TextSpan(
              text: element.text,
              style: TextStyle(
                  decorationColor: Colors.red,
                  decoration: TextDecoration.underline,
                  decorationStyle: TextDecorationStyle.dotted,
                  decorationThickness: 1));
        }
      }
    }
    // Fallback behavior: parse the children, ignoring the tag
    return TextSpan(
        children:
            element.nodes.map((e) => InlineHtml(e, theme, context).build()).toList());
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
