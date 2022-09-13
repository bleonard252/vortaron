/// A full list of known word language codes.
const knownWordLanguages = ["en", "eo", "la", "de"];

/// A full list of known app/dictionary language codes.
const knownAppLanguages = ["en"];

/// A set of conversion maps, used for reverse language code lookup.
///
/// The outermost layer is a map of app language to an inner layer.
///
/// The inner layer is a map of word language name, in the app language,
/// to the language code.
///
/// * To get the English name for Esperanto:
/// ```
/// languageNames["en"].keyOf("eo");
/// // OR, when set to English:
/// tr("languages.eo"); // <-- prefer this one
/// ```
/// * To get the language code for "Latin" in English:
/// ```
/// languageNames["en"]["Latin"];
/// ```
const languageNames = {
  "en": {
    "English": "en",
    "Esperanto": "eo",
    "Latin": "la",
    "German": "de"
  }
};

extension MapKeyOf<K, V> on Map<K, V> {
  /// Gets the key of a value in a map.
  ///
  /// If the value is not found, returns null.
  K? keyOf(V value) {
    for (var key in keys) {
      if (this[key] == value) return key;
    }
    return null;
  }
}