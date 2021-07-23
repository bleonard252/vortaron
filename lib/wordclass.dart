class Definition {
  /// The list of possible parts of speech and definitions.
  final List<PartDefinition> partsOfSpeech;
  /// The word's etymology string.
  final String? etymology;
  /// The hyphenation or name of this word.
  final String hyphenation;
  /// Whether this word is the lemma.
  final bool lemma;
  /// Whether this word is considered "official" (Esperanto only).
  final bool isOfficial;
  /// The audio clip URL that says the word.
  final String? audioClip;
  Definition({
    required this.partsOfSpeech,
    this.etymology,
    required this.hyphenation,
    this.lemma = true,
    this.isOfficial = false,
    this.audioClip
  });
}

const _emptyList = [];
/// A block of definitions, associated by part of speech.
class PartDefinition {
  final partOfSpeech? part;
  final List<String>? qualifiers;
  final List definitions;
  PartDefinition({
    required this.part,
    this.qualifiers,
    required this.definitions
  });
}

enum partOfSpeech {
  LETTER,
  NOUN,
  PRONOUN,
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