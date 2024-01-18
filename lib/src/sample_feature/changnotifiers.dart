import 'package:flutter/material.dart';
import 'package:quizzer/src/sample_feature/sample_item.dart';

class CategoryProvider extends ChangeNotifier {
  ShortcutCategory? selectedCategory;

    void selectCategory(ShortcutCategory category) {
        selectedCategory = category;
        notifyListeners();
    }
}
