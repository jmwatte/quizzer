String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
  String twoDigitCentiseconds = (duration.inMilliseconds.remainder(1000) / 10).floor().toString().padLeft(2, '0');
  return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitCentiseconds";
}



class ShortcutCategory {
  final String category;
  final List<Shortcut> shortcuts;

  ShortcutCategory({required this.category, required this.shortcuts});

  factory ShortcutCategory.fromJson(Map<String, dynamic> jsonData) {
    List<Shortcut> shortcuts = [];
    var shortcutsData = jsonData['shortcuts'];

    if (shortcutsData is List) {
      shortcuts = shortcutsData.map((shortcutJson) => Shortcut.fromJson(shortcutJson)).toList();
    } else if (shortcutsData is Map) {
      shortcuts.add(Shortcut.fromJson(shortcutsData as Map<String, dynamic>));
    }

    return ShortcutCategory(
      category: jsonData['category'],
      shortcuts: shortcuts,
    );
  }
}

class Shortcut {
  final String action;
  final String shortcut;
  final String note;

  Shortcut({required this.action, required this.shortcut, required this.note});

  factory Shortcut.fromJson(Map<String, dynamic> json) {
    return Shortcut(
      action: json['action'],
      shortcut: json['shortcut'],
      note: json['note'],
    );
  }
}
