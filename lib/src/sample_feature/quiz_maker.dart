import 'dart:convert';
import 'dart:io';

import 'helpers.dart';

// List<Map<String, dynamic>> makeQuiz(String text) {
//   List<String> pieces = text.trim().split(RegExp(r'\n\s*\n'));
//   List<Map<String, dynamic>> categories = [];

//   for (var piece in pieces) {
//     List<String> lines = piece.split('\n');
//     String category = lines[0];
//     List<Map<String, String>> quiz = [];

//     for (var i = 1; i < lines.length; i++) {
//       List<String> parts = lines[i].split('\t');
//       quiz.add({
//         'question': parts[1],
//         'answer': parts[0],
//       });
//     }

//     categories.add({
//       'category': category,
//       'quiz': quiz,
//     });
//   }

//   return categories;
// }
void main() async {
  String text = """
  

Operators
d	Delete range.
c	Delete range and enter insert mode.
y	Yank range.
r	Yank and delete range.
s	Select range and enter Visual mode.




OperatorRanges
l	Character under cursor.
h	Character to the left of cursor.
k	Current line and line above.
j	Current line and line below.
w	From cursor to beginning of next word.
W	From cursor to beginning of next word (including punctuation).
b	From cursor to beginning of previous word.
B	From cursor to beginning of previous word (including punctuation).
e	From cursor to end of next word.
E	From cursor to end of next word (including punctuation).
iw	Word under cursor.
iW	Word (including punctuation) under cursor.
aw	Word under cursor and whitespace after.
aW	Word (including punctuation) under cursor and whitespace after.
f<char><char>	From cursor to next occurrence (case sensitive) of .
F<char><char>	From cursor to previous occurrence (case sensitive) of .
t<char>	From cursor to next occurrence (case sensitive) of .
T<char>	From cursor to previous occurrence (case sensitive) of .
gg	From current line to first line of the document.
G	From current line to last line of the document.
}	From current line to beginning of next paragraph.
{	From current line to beginning of previous paragraph.
ip	Current paragraph.
ap	Current paragraph and whitespace after.
i<bracket>	Inside the matching <bracket>s. Where <bracket> is a quote or opening bracket character (any of '"`({[<).
a<bracket>	Outside the matching <bracket>s. Where <bracket> is a quote or opening bracket character (any of '"`({[<).
it	Inside XML tag.
at	Outside XML tag.
ii	Inside indentation level.

Motions
l	Character right.
h	Character left.
k	Line up.
j	Line down.
w	Word right.
W	Word (including punctuation) right.
b	Word left.
B	Word (including punctuation) left.
e	Word end right.
E	Word end (including punctuation) right.
f<char><char>	Next occurrence (case sensitive) of .
F<char><char>	Previous occurrence (case sensitive) of .
t<char>	Next occurrence (case sensitive) of .
T<char>	Previous occurrence (case sensitive) of .
gg	First line of the document.
G	Last line of the document.
}	Down a paragraph.
{	Up a paragraph.
\$	End of line.
_	Beginning of line.
H	Top of screen.
M	Middle of screen.
L	Bottom of screen.

Actions
i	Enter Insert mode.
I	Move to beginning of line and enter Insert mode.
a	Move one character to the right and enter Insert mode.
A	Move to end of line and enter Insert mode.
v	Enter VisualCharacter mode.
V	Enter VisualLine mode.
Escape	Enter Normal mode.
o	Insert line below and enter insert mode.
O	Insert line above and enter insert mode.
p	Put yanked text after cursor.
P	Put yanked text before cursor.
gp	Select the result of the last p or P actions and enter Visual mode.
u	Undo.
Ctrl+r	Redo.
dd	Delete current line.
D	Delete to the end of the line.
cc	Delete current line and enter Insert mode.
C	Delete to the end of the line and enter Insert mode.
yy	Yank current line.
Y	Yank to the end of the line.
rr	Yank current line and delete it.
R	Yank to the end of the line and delete it.
ss	Select current line.
S	Select to the end of the line.
x	Delete character.
zt	Scroll so that cursor is at the top of the screen.
zz	Scroll so that cursor is in the middle of the screen.
zb	Scroll so that cursor is at the bottom of the screen.
Ctrl+d	Scroll down half page.
Ctrl+u	Scroll up half page.
Ctrl+f	Scroll down full page.
Ctrl+b	Scroll up full page.
;	Repeat the last f, F, t or T motion forward.
,	Repeat the last f, F, t or T motion backward.
  """;

  var data = makeQuiz(text);

  // Convert the data to JSON
  String jsonData = jsonEncode(data);

  // Write the JSON data to a file
  File file = File('simpleVim.json');
  await file.writeAsString(jsonData);
}
