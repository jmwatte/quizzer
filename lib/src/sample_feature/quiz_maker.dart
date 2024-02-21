import 'dart:convert';
import 'dart:io';
//import 'dart:io';
//import 'package:quizzer2/src/sample_feature/helpers.dart';

void main() async {
  String text = """
Kakoune KEYS
Key Syntax 	  Usual keys are written using their ascii character, including capital keys. Non printable keys use an alternate name, written between *<* and *>*, such as *<esc>* or *<del>*. Modified keys are written between *<* and *>* as well, with the modifier specified as either *c* for Control, *a* for Alt, or *s* for Shift, followed by a *-* and the key (either its name or ascii character), for example *<c-x>*, *<a-space>*, *<c-a-w>*.


Kakoune== Insert mode
*<esc>*::	leave insert mode
*<backspace>*::	delete characters before cursors
*<del>*::	delete characters under cursors
*<left>*, *<right>*, *<up>*, *<down>*::	move the cursors in given direction
*<home>*:: 	 move cursors to line begin
*<end>*::	move cursors to end of line
*<c-r>*::	insert contents of the register given by next key
*<c-v>*::	insert next keystroke directly into the buffer, without interpreting it
*<c-u>*::	commit changes up to now as a single undo group
*<a-;>*, *<a-semicolon>*::	escape to normal mode for a single command

Kakoune== Insert mode completion
*<c-o>*::	toggle automatic completion
*<c-n>*::	select next completion candidate
*<c-p>*::	select previous completion candidate
*<c-x>*::	explicit insert completion query, followed by:
*f*::: 	 explicit file completion
*w*::: 	 explicit word completion (current buffer)
*W*:::  	explicit word completion (all buffers)
*l*::: 	  explicit line completion (current buffer)
*L*:::  	 explicit line completion (all buffers)

Kakoune== Using Counts
In normal mode	 commands can be prefixed with a numeric `count`, which can control the command behaviour. For example, *3W* selects 3 consecutive words and *3w* select the third word on the right of the end of each selection.



Kakoune== Movement
'word'	 is a sequence of alphanumeric characters, or those in the `extra_word_chars` option (see <<options#builtin-options,`:doc options builtin-options`>>).
'WORD'	 is a sequence of non whitespace characters. Generally, a movement on its ownwill move each selection to cover the text moved over, while holding down the Shift modifier and moving will extend each selection instead.
*h*::	select the character on the left of the end of each selection
*j*::	select the character below the end of each selection
*k*::	select the character above the end of each selection
*l*::	select the character on the right of the end of each selection
*w*::	select the word and following whitespaces on the right of the end of each selection
*b*::	select preceding whitespaces and the word on the left of the end of each selection
*e*::	select preceding whitespaces and the word on the right of the end of each selection
*<a-[wbe]>*::	same as [wbe] but select WORD instead of word
*f*:: 	   select to the next occurrence of given character
*t*:: 	   select until the next occurrence of given character
*<a-[ft]>*::  	   same as [ft] but in the other direction
*<a-.>*:: 	   repeat last object or *f*/*t* selection command
*m*::  	  select to the next sequence enclosed by matching characters, see the`matching_pairs` option in <<options#,`:doc options`>>
*M*::   	 extend the current selection to the next sequence enclosed by matching character, see the `matching_pairs` option in <<options#,`:doc options`>>
*<a-m>*:: 	   select to the previous sequence enclosed by matching characters, see the `matching_pairs` option in <<options#,`:doc options`>>
*<a-M>*::  	 extend the current selection to the previous sequence enclosed by matching characters, see the `matching_pairs` option in <<options#,`:doc options`>>
*x*::  	 expand selections to contain full lines (including end-of-lines)
*<a-x>*:: 	  trim selections to only contain full lines (not including last end-of-line)
*%*, *<percent>*::	select whole buffer
*<a-h>*::	    select to line begin `<home>` maps to this by default. (See <<mapping#default-mappings,`:doc mapping default-mappings`>>)
*<a-l>*::  	  select to line end `<end>` maps to this by default.(See <<mapping#default-mappings,`:doc mapping default-mappings`>>)
*<pageup>, <c-b>*:: 	 scroll one page up
*<pagedown>, <c-f>*:: 	   scroll one page down
*<c-u>*::	    scroll half a page up
*<c-d>*:: 	   scroll half a page down
*;*, *<semicolon>*:: 	    reduce selections to their cursor
*<a-;>*, *<a-semicolon>*:: 	  flip the direction of each selection
*<a-:>*:: 	   ensure selections are in forward direction (cursor after anchor)

Kakoune== Changes
Yanking (copying) and pasting use the	 *"* register by default (See <<registers#,`:doc registers`>>)
*i*:: 	   enter insert mode before selections
*a*::  	  enter insert mode after selections
*d*::  	  yank and delete selections
*c*::  	  yank and delete selections and enter insert mode
*.*::  	  repeat last insert mode change (*i*, *a*, or *c*, including the inserted text)
*<a-d>*::	    delete selections (not yanking)
*<a-c>*::	    delete selections and enter insert mode (not yanking)
*I*::	    enter insert mode at the beginning of the lines containing the start of each selection
*A*::	    enter insert mode at the end of the lines containing the end of each selection
*o*::	    enter insert mode in a new line (or in a given `count` of new lines) below the end of each selection
*O*::	    enter insert mode in a new line (or in a given `count` of new lines) above the beginning of each selection
*<a-o>*::	    add an empty line below cursor
*<a-O>*::	    add an empty line above cursor
*y*::	    yank selections
*p*::	    paste after the end of each selection
*P*::	    paste before the beginning of each selection
*<a-p>*::	    paste all after the end of each selection, and select each pasted string
*<a-P>*::	    paste all before the start of each selection, and select each pasted string
*R*::	    replace selections with yanked text
*<a-R>*::	    replace selections with every yanked text
*r*::	    replace each character with the next entered one
*<a-j>*::	    join selected lines
*<a-J>*::	    join selected lines and select spaces inserted in place of line breaks
*<a-_>*::	    merge contiguous selections together (works across lines as well)
*<+>*, *<plus>*::	    duplicate each selection (generating overlapping selections)
*<a-+>*, *<a-plus>*::	    merge overlapping selections
*>*, *<gt>*::	    indent selected lines
*<a-\>>*, *<a-gt>*::	     indent selected lines, including empty lines
*<*, *<lt>*::	    unindent selected lines
*<a-<>*, *<a-lt>*::	  unindent selected lines, do not remove incomplete indent (3 leading spaces when indent is 4)
*u*::	    undo last change
*U*::	    redo last change
*<c-j>*::	    move forward in changes history
*<c-k>*::	    move backward in changes history
*<a-u>*::	    undo last selection change
*<a-U>*::	    redo last selection change
*&*::	    align selections, align the cursor of each selection by inserting spaces before the first character of each selection
*<a-&>*::	    copy indent, copy the indentation of the main selection (or the `count` one if a `count` is given) to all other ones
*`*::	    to lower case
*~*::	    to upper case
*<a-`>*::	    swap case
*@*::	    convert tabs to spaces in each selection, uses the buffer tabstop option or the `count` parameter for tabstop
*<a-@>*::	    convert spaces to tabs in each selection, uses the buffer tabstop option or the `count` parameter for tabstop
*_*::	    unselect whitespace surrounding each selection, drop those that only contain whitespace
*<a-)>*::	    rotate selections content, if specified, the `count` groups selections,
*<a-(>*::	    rotate selections content backward

Kakoune== Changes through external programs
Shell expansions are available  	, (See <<expansions#shell-expansions,`:doc expansions shell-expansions`>>)The default command comes   from the *|* register (See <<registers#,`:doc registers`>>)
*|*::	    pipe each selection through the given external filter program and replace the selection with its output.
*<a-|>*::	    pipe each selection through the given external filter program and ignore its output.
*!*::	    insert and select command output before each selection.
*<a-!>*::	    append and select command output after each selection.

Kakoune== Searching
Searches use 	   the */* register by default (See <<registers#,`:doc registers`>>)
*/*::	    select next match after each selection
*<a-/>*::	    select previous match before each selection
*?*::	    extend to next match after each selection
*<a-?>*::	    extend to previous match before each selection
*n*::	    select next match after the main selection
*N*::	    add a new selection with next match after the main selection
*<a-n>*::	    select previous match before the main selection
*<a-N>*::	    add a new selection with previous match before the main selection
***::	    set the search pattern to the main selection (automatically detects word boundaries)
*<a-***>*::	  set the search pattern to the main selection (verbatim, no smart detection)

Kakoune== Goto commands
*g*, *G*::	   When a `count` is specified, *G* only extends the selection to the given line,*g* sends the anchor to the given line and a menu is then displayed which waits for one of the following additional keys:
*g*,*l*:::	   go to line end
*g*,*h*:::	   go to line begin
*g*, *i*:::	   go to non blank line start
*g*, *g*,*k*:::	  go to the first line
*g*, *j*:::	   go to the last line
*g*, *e*:::	   go to last char of last line
*g*, *t*:::	   go to the first displayed line
*g*, *c*:::	   go to the middle displayed line
*g*, *b*:::	   go to the last displayed line
*g*, *a*:::	   go to the previous (alternate) buffer
*g*, *f*:::	   open the file whose name is selected
*g*, *.*:::	   go to last buffer modification position

== View commands
*v*, *V*::	   *V* enters lock view mode (which will be left when the <esc> is hit), and *v* modifies the current view; a menu is then displayed which waits for one of the following additional keys:
*v*,*v*, *c*::	  : center the main selection in the window (vertically)
*v*,*m*:::	   center the main selection in the window (horizontally)
*v*,*t*:::	   scroll to put the main selection on the top line of the window
*v*,*b*:::	   scroll to put the main selection on the bottom line of the window
*v*,*h*:::	   scroll the window `count` columns left
*v*,*j*:::	   scroll the window `count` line downward
*v*,*k*:::	   scroll the window `count` line upward
*v*,*l*:::	   scroll the window `count` columns right

== Marks
Current selections position  	   can be saved in a register and restored later on. Marks use the *^* register by default (See <<registers#,`:doc registers`>>)
*Z*::	    save selections to the register
*z*::	    restore selections from the register
*<a-z>*, *<a-Z>*::	   *<a-z>* combines selections from the register with the current ones, whereas
 *<a-z>*, *<a-Z>, *<a-Z>* 	combines current selections with the ones in the register; a menu is then displayed which waits for one of the following additional keys:
 *<a-z>*, *<a-Z>, *a*:::	   append selections
 *<a-z>*, *<a-Z>, *u*:::	   keep a union of selections
 *<a-z>*, *<a-Z>, *i*:::	   keep an intersection of selections
 *<a-z>*, *<a-Z>, *<*:::	   select the selection with the leftmost cursor for each pair
 *<a-z>*, *<a-Z>, *>*:::	   select the selection with the rightmost cursor for each pair
 *<a-z>*, *<a-Z>, *+*:::	   select the longest selection
 *<a-z>*, *<a-Z>, *-*:::	   select the shortest selection

== Macros
Macros use the	   *@* register by default (See <<registers#,`:doc registers`>>)
*Q*::	    start or end macro recording
*q*::	    play a recorded macro
*<esc>*::	    end macro recording


== Multiple selections
*s*, *S*, *<a-k>* and *<a-K>* use	    the */* register by default (See <<registers#,`:doc registers`>>)
*s*::	    create a selection for each match of the given regex (selects the count capture if it is given)
*S*::	    split selections with the given regex (selects the count capture if it is given)
*<a-s>*::	    split selections on line boundaries
*<a-S>*::	    select first and last characters of each selection
*C*::	    duplicate selections on the lines that follow them
*<a-C>*::	    duplicate selections on the lines that precede them
*,*::	    clear selections to only keep the main one
*<a-,>*::	    clear the main selection
*<a-k>*::	    keep selections that match the given regex
*<a-K>*::	    clear selections that match the given regex
*\$*::	    pipe each selection to the given shell command and keep the ones for which the shell returned 0. Shell expansions are available,
*)*::	    rotate main selection (the main selection becomes the next one)
*(*::	    rotate main selection backward (the main selection becomes the previous one)

== Object Selection
For nestable objects, 	   a `count` can be used in order to specify which surrounding level to select. Object selections are repeatable using *<a-.>*.

=== Whole object
A 'whole object' is an object 	   *including* its surrounding characters.For example, for a quoted string this will select the quotes, and for a word this will select trailing spaces.
*<a-a>*::	    select the whole object
*[*::	    select to the whole object start
*]*::	    select to the whole object end
*{*::	    extend selections to the whole object start
*}*::	    extend selections to the whole object end

=== Inner object
An 'inner object' is 	   an object *excluding* its surrounding characters. For example, for a quoted string this will *not* select the quotes, and for a word this will *not* select trailing spaces.
*<a-i>*::	    select the inner object
*<a-[>*::	    select to the inner object start
*<a-]>*::	    select to the inner object end
*<a-{>*::	    extend selections to the inner object start
*<a-}>*::	    extend selections to the inner object end

=== Objects types
After the keys described above 	 , a second key needs to be entered in order to specify the wanted object:
*b*, *(*, *)*::	  select the enclosing parenthesis
*B*, *{*, *}*::	  select the enclosing {} block
*r*, *[*, *]*::	  select the enclosing [] block
*a*, *<*, *>*::	  select the enclosing <> block
*Q*, *"*::	   select the enclosing double quoted string
*q*, *'*::	   select the enclosing single quoted string
*g*, *`*::	   select the enclosing grave quoted string
*w*::	    select the whole word
*<a-w>*:	    : select the whole WORD
*s*::	    select the sentence
*p*::	    select the paragraph
*␣*::	    select the whitespaces
*i*::	    select the current indentation block
*n*::	    select the number
*u*::	    select the argument
*c*::	    select user defined object, will prompt for open and close text
*<a-;>*, *<a-semicolon>*::	   run a command with additional expansions describing the selection context (See <<expansions#,`:doc expansions`>>)
""";
  String textc = """
  

Operators
d copy and delete selection.
c copy and delete selection and switch to insert mode.
y Yank/copy selection.
r Replace character under cursor.
shift r Yank/copy and replace.
v enter Visual mode.
. Repeat last edit without a command.


OperatorRanges
s jump to the next 2 letters
l	jump right.
h	jump left.
k	jump up
j	jump down
w	extend from cursor to next word start
alt w extend from cursor to start of next word (including punctuation).
b	extend from cursor to beginning of word/previous word.
alt b	extend from cursor to beginning of word/previous word (including punctuation).
e	extend from cursor to end of word/next word.
alt e	extend from cursor to end of word/next word (including punctuation).
x  select line.
shift alt l  extend to end of line.
shift alt h  extend to beginning of line.
T extend to character(excluded)
alt t extend to character(excluded) backward 
F extend to character(included)
alt f extend to character(included) backward
alt ] extend toinner object end(opens menu)
alt [ extend toinner object start(opens menu)
shift m extend to previous enclosing character when inside
alt shift m  extend to next enclosing character when inside
shift m  extends to end of next enclosing characters
m extend to next both enclosing characters when inside/outside
/ search forward for letters regex
alt / search backward for letters regex
u undo
i insert before
a insert after
shift a  insert at line end
o insert new line below and switch to insert mode
p paste after
[ extend to whole object start(opens menu)
] extend to whole object end(opens menu)
s leap or select(2 letters)
d copy and delete
f extend to character(included)
g extend to(opens menu)
h jump left
j jump down
k jump up
l jump right
; reduce selection to their cursor
z restore selections
x extend to line in v-mode extend to line below
c copy and delete and switch to insert mode
shift c copy selections below
alt shift c copy selections above
b extend to previous word
n add next / result
m select to enclosing characters
, clear secundary selections
/ search forward for letters
` transform to lowercase
shift ` transform to uppercase
shift - trim whitespace from selection
shift z save selections
z restore selections
shift v open view menu for scrolling up and down
% select whole editor/buffer`
shift 7 align selections
shift 8 search current selection









g opens menu for goto...
gh  goto line start
gl  goto line end
gi  goto non-blank line start
gg  goto file start
gj  goto the last line
ge  goto the last character of the last line
gt  goto the first displayed line on the screen
gc  goto the middle displayed line on the screen
gb  goto the last displayed line on the screen
ga  goto the last buffer/editor
gA  opens the selecte editor menu
gp  goto the previous editor
gn  goto the next editor
gd  goto the definition of the symbol under the cursor
gr  goto the reference of the symbol under the cursor
gf  goto the file under the cursor
f12  goto the file under the cursor
g.  goto the last edit
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

  List<Map<String, dynamic>> makeQuiz(String text) {
    List<String> pieces = text.trim().split(RegExp(r'\n\s*\n'));
    List<Map<String, dynamic>> quizzes = [];

    for (var piece in pieces) {
      List<String> lines = piece.split('\n');
      String quiz = lines[0];
      List<Map<String, String>> questions = [];

      for (var i = 1; i < lines.length; i++) {
        List<String> parts = lines[i].split('\t');
        questions.add({
          'question': parts[1],
          'answer': parts[0],
          'note': parts.length > 2 ? parts[2] : '',
        });
      }

      quizzes.add({
        'Quiz': quiz,
        'Questions': questions,
      });
    }

    return quizzes;
  }

  var data = makeQuiz(text);

  // Convert the data to JSON
  String jsonData = jsonEncode(data);

  // Write the JSON data to a file
  File file = File('simpleKakaoune.json');
  await file.writeAsString(jsonData);
}
