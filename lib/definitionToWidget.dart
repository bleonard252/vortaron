import 'dart:ui';

import 'package:flutter/material.dart' hide Element;
import 'package:html/dom.dart' hide Text;
import 'package:vortaron/views/home.dart';

List<InlineSpan> definitionToWidgets(Element element, BuildContext context, {String? allowedLang}) {
  List<InlineSpan> spans = [];
  for (var node in element.nodes) {
    // if (node is Element && node.querySelectorAll(".citation-whole").length > 1) continue;
    // else 
    if (node.nodeType == Node.TEXT_NODE) spans.add(TextSpan(text: node.text?.replaceAll(RegExp("[\n\r]"), " "), style: TextStyle(color: Theme.of(context).colorScheme.onBackground)));
    else if (node is Element && node.localName?.toLowerCase() == "a") {
      // Figure out what it links to
      if ((node.attributes["href"]?.startsWith("/wiki/") ?? false) && (node.attributes["href"]?.endsWith("#"+(allowedLang ?? "QQQ")) ?? false)) {
        // Wiki link for the current language; let's define the word
        spans.add(linkSpan(text: node.text, onClick: () => define(node.text, allowedLang!, context)));
      }
      // If the link is not supported, keep it as text
      else spans.add(TextSpan(text: node.text, style: TextStyle(color: Theme.of(context).colorScheme.onBackground)));
    }
    else if (node is Element && (node.localName?.toLowerCase() == "i" || node.localName?.toLowerCase() == "em")) {
      spans.add(TextSpan(
        style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.onBackground),
        children: definitionToWidgets(node, context, allowedLang: allowedLang)
      ));
    }
    else if (node is Element && (node.localName?.toLowerCase() == "b" || node.localName?.toLowerCase() == "strong")) {
      spans.add(TextSpan(
        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onBackground),
        children: definitionToWidgets(node, context, allowedLang: allowedLang)
      ));
    }
    else if (node is Element && (node.localName?.toLowerCase() == "span" || node.localName?.toLowerCase() == "p")) {
      spans.add(TextSpan(
        style: (node.className.contains("ib-brac") || node.className.contains("ib-content")) 
        ? TextStyle(fontStyle: FontStyle.italic, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted, decorationThickness: 0.5)
        : TextStyle(color: Theme.of(context).colorScheme.onBackground),
        children: definitionToWidgets(node, context, allowedLang: allowedLang)
      ));
    }
    else if (node is Element && (node.localName?.toLowerCase() == "li")) {
      spans.add(WidgetSpan(child: Container(
        alignment: Alignment.topLeft,
        child: RichText(text: TextSpan(
          text: " • ",
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
          children: definitionToWidgets(node, context, allowedLang: allowedLang)
        )),
      )));
    }
    else if (node is Element && (node.localName?.toLowerCase() == "ul")) {
      spans.add(WidgetSpan(
        child: definitionToWidget(node, context, allowedLang: allowedLang)
      ));
    }
    else if (node is Element && node.className.contains("citation-whole")) {
      spans.add(TextSpan(
        //text: "Quotation: ",
        children: [
          TextSpan(
            text: "Quotation:",
            style: TextStyle(decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dotted, decorationThickness: 0.5)
          ),
          TextSpan(text: " "),
          ...definitionToWidgets(node, context, allowedLang: allowedLang)
        ]
      ));
    }
    else if (node is Element && (node.localName?.toLowerCase() == "dl")) {
      spans.add(TextSpan(
        text: "\n",
        children: [WidgetSpan(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Container(
            child: definitionToWidget(node, context, allowedLang: allowedLang),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(
                color: Colors.grey,
                width: 4
              ))
            ),
          ),
        ))]));
    }
    else if (node is Element && (node.localName?.toLowerCase() == "dd")) {
      spans.add(TextSpan(
        text: node.previousElementSibling?.localName == "dd" ? "\n" : "",
        children: definitionToWidgets(node, context, allowedLang: allowedLang),
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground)));
    } else spans.add(TextSpan(text: node.text, style: TextStyle(color: Theme.of(context).colorScheme.onBackground)));
  }
  return spans;
}

Widget definitionToWidget(Element element, BuildContext context, {String? allowedLang}) {
  return RichText(text: TextSpan(children: definitionToWidgets(element, context, allowedLang: allowedLang)));
}

linkSpan({required String text, required void Function()? onClick}) {
  return WidgetSpan(
    child: GestureDetector(
      onTap: onClick,
      child: Text(text, 
        style: TextStyle(
          color: Colors.amber,
          decoration: TextDecoration.underline,
          decorationColor: Colors.amber
        )
      ),
    )
  );
}