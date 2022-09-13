import 'package:html/parser.dart';

class Definition {
  /// The list of possible parts of speech and definitions.
  final List<PartDefinition> partsOfSpeech;
  /// The word's etymology string.
  final List<String> etymology;
  /// The hyphenation or name of this word.
  final String hyphenation;
  /// Whether this word is the lemma.
  final bool lemma;
  /// The audio clip URL that says the word.
  final String? audioClip;
  final List<DefTranslation> translations;
  Definition({
    required this.partsOfSpeech,
    this.etymology = const [],
    required this.hyphenation,
    this.lemma = true,
    this.audioClip,
    this.translations = const []
  });
}

/// A block of definitions, associated by part of speech.
class PartDefinition {
  final partOfSpeech? part;
  /// Which etymology from the list it is under. Invalid values will be added
  /// to the end.
  final int etymology;
  final List<String>? qualifiers;
  final List<String> definitions;
  final List<dynamic>? definitionMarkup;
  PartDefinition({
    required this.part,
    this.qualifiers,
    this.etymology = 0,
    required this.definitions,
    this.definitionMarkup
  });
}

class DefTranslation {
  /// A short description of the meaning being translated.
  final String? gloss;
  /// The translated word or phrase.
  final String translation;
  /// Target language name (in app language).
  final String language;
  final GrammaticalGender? gender;
  /// Qualifiers or conditions given, i.e. formal or academic.
  final List<String> qualifiers;
  DefTranslation({
    this.gloss,
    required this.translation,
    required this.language,
    this.qualifiers = const [],
    this.gender
  });
}

enum GrammaticalGender {
  /// Masculine
  M,
  /// Feminine
  F,
  /// Neuter/neutral. Not necessarily the same as genderless
  N
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