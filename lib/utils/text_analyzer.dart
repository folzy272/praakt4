/// Результат статистичного аналізу тексту.
class TextAnalysis {
  final int characters;
  final int charactersWithoutSpaces;
  final int words;
  final int lines;
  final Map<String, int> wordFrequencies;

  const TextAnalysis({
    required this.characters,
    required this.charactersWithoutSpaces,
    required this.words,
    required this.lines,
    required this.wordFrequencies,
  });

  @override
  String toString() =>
      'символів: $characters, без пробілів: $charactersWithoutSpaces, '
      'слів: $words, рядків: $lines';
}

class TextAnalyzer {
  /// Літери й цифри Unicode, включно з українськими словами.
  static final RegExp _wordPattern = RegExp(r'[\p{L}\p{N}]+', unicode: true);

  static List<String> tokenize(String text) => _wordPattern
      .allMatches(text.toLowerCase())
      .map((match) => match.group(0)!)
      .toList();

  static TextAnalysis analyze(String text) {
    final words = tokenize(text);
    final frequencies = <String, int>{};
    for (final word in words) {
      frequencies.update(word, (count) => count + 1, ifAbsent: () => 1);
    }
    return TextAnalysis(
      characters: text.runes.length,
      charactersWithoutSpaces:
          text.runes.where((rune) => !RegExp(r'\s').hasMatch(String.fromCharCode(rune))).length,
      words: words.length,
      lines: text.isEmpty ? 0 : text.split(RegExp(r'\r\n|\n|\r')).length,
      wordFrequencies: frequencies,
    );
  }
}
