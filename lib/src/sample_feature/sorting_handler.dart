import 'package:flutter/material.dart';

enum SortType {
  original,
  reversed,
  question,
  questionReversed,
  answer,
  answerReversed,
}

class SortingDialog extends StatelessWidget {
  const SortingDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Choose sorting method'),
      children: <Widget>[
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, SortType.original);
          },
          child: const Text('Original'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, SortType.reversed);
          },
          child: const Text('Reversed'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, SortType.question);
          },
          child: const Text('question'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, SortType.questionReversed);
          },
          child: const Text('questionReversed'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, SortType.answer);
          },
          child: const Text('answer'),
        ),
        SimpleDialogOption(
          onPressed: () {
            Navigator.pop(context, SortType.answerReversed);
          },
          child: const Text('answerReversed'),
        ),
        // Add more SimpleDialogOptions for more sorting methods
      ],
    );
  }
}
