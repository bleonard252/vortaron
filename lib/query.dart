import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

import 'package:vortaron/wordclass.dart';

/// Looks up the word in the Wiktionary.
Future<Definition?> lookupWord(String word, String inLanguage, String forLanguage) async {
  final client = Dio();
  var response = await client.get("https://en.wiktionary.com/w/api.php?action=parse&format=json&prop=text|revid|displaytitle&page=$word");
  //print(response.data);
  var document = parse(response.data["parse"]["text"]["*"]);
  var langHeader = document.children
  .first.querySelector("h2 > span#$inLanguage")
  ?.parent;
  //.where((node) => node.children.first.getAttribute("class") == "mw-headline" && node.children.first.getAttribute("id") == inLanguage);
  // late var langHeader;
  // try {
  //   langHeader = langHeaders.first;
  // } catch(_) {
  //   langHeaders = List.unmodifiable([]);
  // }
  // if (langHeaders.isEmpty) throw Exception("$word is not a word in $inLanguage (via $forLanguage)");
  if (langHeader == null) throw Exception("$word is not a word in $inLanguage (via $forLanguage)");
  Element? currentElement = langHeader.nextElementSibling;
  List<Element> langSection = [];
  while (true) {
    if (currentElement == null) return null;
    else if (currentElement.outerHtml.toLowerCase().startsWith("<hr ")) break;
    else {
      langSection.add(currentElement);
      currentElement = currentElement.nextElementSibling;
    }
  }
  throw UnimplementedError();
}