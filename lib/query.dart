import 'package:requests/requests.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:html/parser.dart' show parse, parseFragment;
import 'package:html/dom.dart' show Element;

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

final _transTopRegex = RegExp(r'^\s*[{]{2}trans-top\|(.*?)(?:\|id=.*?)?[}]{2}\s*$', multiLine: true);
final _transBottomRegex = RegExp(r'^\s*[{]{2}trans-bottom[}]{2}\s*$', multiLine: true);
final _transEntryOuterRegex = RegExp(r'^\*:* (.*?): (.*)$', multiLine: true);
//final _transEntryInnerRegex = RegExp(r'[{]{2}t\+?\|(?:[a-z-]{2,})\|(.*?)\|?([mfn]?)\|?((?:[a-z0-9-]+=.*?\|?)*)[}]{2}', multiLine: true);
final _wikitextTemplateRegex = RegExp(r'[{]{2}(.*?)\|(.*\|?)[}]{2}', multiLine: true);

/// Looks up the word in the Wiktionary.
Future<Definition?> lookupWord(String word, String inLanguageCode, String forLanguage) async {
  String inLanguage = tr("languages."+inLanguageCode);
  var prefetch = await Requests.get("https://en.wiktionary.org/w/api.php?format=json&action=parse&prop=sections&page=$word");
  if (prefetch.json().containsKey("error")) {
    throw Exception(tr("errors.notFound", namedArgs: {"word": word, "appLang": forLanguage, "wordLang": inLanguage}));
  }
  final sectionId = prefetch.json()["parse"]["sections"].firstWhere((e) => e["line"] == inLanguage, orElse: () => -1)["index"];
  if (sectionId == -1) {
    throw Exception(tr("errors.notAWord", namedArgs: {"word": word, "appLang": forLanguage, "wordLang": inLanguage}));
  }
  var response = await Requests.get("https://en.wiktionary.org/w/api.php?action=parse&format=json&prop=text|wikitext|properties|displaytitle&redirects=true&page=$word&section=$sectionId");
  //var opening_response = await Requests.get("https://en.wiktionary.org/w/api.php?action=parse&format=json&prop=text|wikitext|properties|revid|displaytitle|categories&redirects=true&page=$word&section=0");
  if (prefetch.json().containsKey("error")) {
    throw Exception(tr("errors.unknown", args: [prefetch.json()["error"]]));
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
  for (var list in langSection.where((element) => element.localName?.toLowerCase() == "ol")) {
    Element? header = list.previousElementSibling;
    final _wordline = header;
    if (header?.localName == "p") header = header?.previousElementSibling;
    // Parts of Speech
    String htxt = (header?.text ?? "Particle[edit]")
    .replaceAll('[edit]', '')
    .replaceAll(RegExp(r'[\n\r]'), '');
    // Qualifiers
    final qualifiers = RegExp(r'.*?\((.*)\)').firstMatch(_wordline!.text)?.group(1)?.split(",") ?? [];
    final _highlyIrreg = qualifiers.indexWhere((element) => element.startsWith("highly irregular"));
    if (_highlyIrreg != -1) {
      qualifiers.fillRange(_highlyIrreg, _highlyIrreg+1, "highly irregular");
    }
    if (forLanguage == "English" && enValidPartsOfSpeech.keys.contains(htxt))
      partDefinitions.add(
        PartDefinition(
          qualifiers: qualifiers,
          part: enValidPartsOfSpeech[htxt],
          definitions: [
            for (var listItem in list.children) listItem.text
          ],
          definitionMarkup: [
            for (var listItem in list.children) listItem
          ],
          // This elaborate spaghetti line determines which etymology the definition is under.
          etymology: (header?.parent?.children.where((e) => e == header || (e.localName?.toLowerCase() == "h3" && e.text.startsWith("Etymology"))).toList().indexOf(header) ?? 1) - 1
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
  List<String> etymologies = [];
  List<Element> etymologiesMarkup = [];
  for (var sect in langSection.where((element) => element.previousElementSibling?.text.startsWith("Etymology") == true)) {
    if (sect.localName == "p") {
      etymologies.add(sect.text);
      etymologiesMarkup.add(sect);
    } else {
      etymologies.add("");
      etymologiesMarkup.add(Element.tag("p"));
    }
  }
  // Categories
  List<String> categories = [];
  // for (var category in response.json()["parse"]["categories"]) {
  //   categories.add(category["*"]);
  // }
  // Translations
  List<DefTranslation> translations = [];
  for (final top in _transTopRegex.allMatches(response.json()["parse"]["wikitext"]["*"])) {
    final gloss = top.group(1);
    final bottom = _transBottomRegex.firstMatch(response.json()["parse"]["wikitext"]["*"].substring(top.end))!;
    final search = response.json()["parse"]["wikitext"]["*"].substring(top.end+1, top.end+bottom.start);
    for (final check in _transEntryOuterRegex.allMatches(search)) {
      final lang = check.group(1)!;
      final search = check.group(2)?.split(RegExp(r"[,;] ")) ?? [];
      if (search.isEmpty) continue;
      for (final entry in search) {
        final templates = _wikitextTemplateRegex.allMatches(entry).toList();
        final _tind = templates.indexWhere((element) => element.group(1) == "t" || element.group(1) == "t+");
        if (_tind == -1) continue;
        final parameters = templates[_tind]
        .group(2)?.split("|");
        final _translation = parameters?[1];
        if (parameters == null || _translation == null) continue;
        // Example below:
        //  g1  g2
        //   0  0  1        2 3           4
        // {{t+|el|κουβέντα|f|tr=kouvénta|sc=Grek}}
        final qualifiers = templates
        .where((element) => element.group(1) == "qualifier")
        .map((e) => e.group(2)?.split("|")[0]);
        translations.add(DefTranslation(
          language: lang,
          translation: _translation,
          gloss: gloss,
          gender: parameters.contains("m") ? GrammaticalGender.M
          : parameters.contains("f") ? GrammaticalGender.F
          : parameters.contains("n") ? GrammaticalGender.N
          : null,
          qualifiers: qualifiers.whereType<String>().toList(),
        ));
      }
    }
  }
  //return
  final def = Definition(
    partsOfSpeech: partDefinitions,
    etymology: etymologies,
    hyphenation: hyphenation,
    lemma: categories.contains(inLanguage+" lemmas"),
    audioClip: html.querySelector("audio")?.firstChild?.attributes["src"]?.replaceFirst("//", "https://"),
    translations: translations
  );
  return def;
}