class Definition {
  final List<PartDefinition> partsOfSpeech;
  final String? etymology;
  final String? hyphenation;
  Definition({
    required this.partsOfSpeech,
    this.etymology,
    this.hyphenation,
  });
}

const _emptyList = [];
/// A block of definitions, associated by part of speech.
class PartDefinition {
  final partOfSpeech? part;
  final List<String>? qualifiers;
  final List<String> definitions;
  PartDefinition({
    required this.part,
    this.qualifiers,
    required this.definitions
  });
}

enum partOfSpeech {
  NOUN,
  VERB,
  ADJECTIVE,
  ADVERB,
  PARTICLE,
  DETERMINER,
  ARTICLE,
  CONJUNCTION,
  PREPOSITION,
  INTERJECTION
}