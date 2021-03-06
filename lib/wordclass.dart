class Definition {
  /// The list of possible parts of speech and definitions.
  final List<PartDefinition> partsOfSpeech;
  /// The word's etymology string.
  final String? etymology;
  /// The hyphenation or name of this word.
  final String hyphenation;
  /// Whether this word is the lemma.
  final bool lemma;
  /// The audio clip URL that says the word.
  final String? audioClip;
  Definition({
    required this.partsOfSpeech,
    this.etymology,
    required this.hyphenation,
    this.lemma = true,
    this.audioClip
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