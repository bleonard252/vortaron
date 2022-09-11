import 'package:requests/requests.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:html/parser.dart' show parse, parseFragment;
import 'package:html/dom.dart';

import 'package:vortaron/wordclass.dart';

const enValidPartsOfSpeech = {
  "Noun": partOfSpeech.NOUN,
  "Verb": partOfSpeech.VERB,
  "Adjective": partOfSpeech.ADJECTIVE,
  "Adverb": partOfSpeech.ADVERB,
  "Particle": partOfSpeech.PARTICLE,
  "Determiner": partOfSpeech.DETERMINER,
  "Article": partOfSpeech.ARTICLE,
  "Conjunction": partOfSpeech.CONJUNCTION,
  "Preposition": partOfSpeech.PREPOSITION,
  "Interjection": partOfSpeech.INTERJECTION
};

/// Looks up the word in the Wiktionary.
Future<Definition?> lookupWord(String word, String inLanguageCode, String forLanguage) async {
  String inLanguage = tr("languages."+inLanguageCode);
  var response = await Requests.get("https://en.wiktionary.com/w/api.php?action=parse&format=json&prop=text|revid|displaytitle|categories&page=$word#$inLanguage");
  if (response.json().containsKey("error")) {
    throw Exception("$word was not found in the $forLanguage dictionary");
  }
  //print(response.data);
  var document = parse(response.json()["parse"]["text"]["*"]);
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
  bool foundEnd = false;
  while (!foundEnd) {
    if (currentElement == null) foundEnd = true;
    else if ((currentElement.localName ?? "").toLowerCase() == "hr") foundEnd = true;
    else {
      langSection.add(currentElement);
      currentElement = currentElement.nextElementSibling;
    }
  }
  var html = parse(langSection.map<String>((e) => e.outerHtml).join());
  List<PartDefinition> partDefinitions = [];
  for (var list in langSection.where((element) => (element.localName ?? "").toLowerCase() == "ol")) {
    Element? header = list.previousElementSibling;
    if (header?.localName == "p") header = header?.previousElementSibling;
    // Parts of Speech
    String htxt = (header?.text ?? "Particle[edit]")
    .replaceAll('[edit]', '')
    .replaceAll(r'[\n\r]', '');
    if (forLanguage == "English" && enValidPartsOfSpeech.keys.contains(htxt))
      partDefinitions.add(
        PartDefinition(
          part: enValidPartsOfSpeech[htxt], 
          definitions: [
            for (var listItem in list.children) listItem.text
          ]
        )
      );
  }
  // Hyphenation and name
  String hyphenation = parseFragment(response.json()["parse"]["displaytitle"]).text ?? word;
  try {
    //hyphenation = langSection.where((element) => element.localName == "ui").firstWhere((element) => element.ha?.firstChild?.text?.startsWith("Hyphenation: ") ?? false).firstChild?.text.replaceAll("Hyphenation: ", "");
    for (var x in html.querySelectorAll("ul>li>span.Latn")) {
      final _y = x.parent?.text.replaceFirst("Hyphenation: ", "");
      if (_y != null && (x.parent?.text.startsWith("Hyphenation: ") ?? false)) hyphenation = _y;
    }
  } catch(_) {
    try {
      hyphenation = parseFragment(response.json()["parse"]["displaytitle"]).text ?? word;
    } catch(_) {
      hyphenation = word;
    }
  }
  // Etymology
  String? etymology;
  for (var sect in langSection.where((element) => element.previousElementSibling?.text.startsWith("Etymology") == true)) {
    etymology = sect.text;
  }
  // Categories
  List<String> categories = [];
  for (var category in response.json()["parse"]["categories"]) {
    categories.add(category["*"]);
  }
  //return 
  final def = Definition(
    partsOfSpeech: partDefinitions,
    etymology: etymology,
    hyphenation: hyphenation,
    lemma: categories.contains(inLanguage+" lemmas"),
    audioClip: html.querySelector("audio")?.firstChild?.attributes["src"]?.replaceFirst("//", "https://")
  );
  return def;
}