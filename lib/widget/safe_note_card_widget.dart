import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safe_notes/model/safe_note.dart';

final _lightColors = [
  Colors.lightBlue.shade700,
  Colors.pinkAccent.shade100,
  Colors.lightGreen.shade700,
  Color(0xFF4c6e81),
  Color(0xFF7aacb3),
  Colors.orange.shade400,
];

final _selectedColor = Colors.black;

class NoteCardWidget extends StatelessWidget {
  final SafeNote note;
  final bool isSelected;
  final int index;
  final bool isInSelectionMode;
  NoteCardWidget({
    Key? key,
    required this.note,
    required this.index,
    required this.isSelected,
    required this.isInSelectionMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Pick colors from the accent colors based on index
    final color = _lightColors[index % _lightColors.length];
    final time = DateFormat.yMMMd().format(note.createdTime);
    final minHeight = getMinHeight(index);

    return Card(
      color: color,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Visibility(
              visible: isInSelectionMode,
              child: Icon(
                isSelected
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
              ),
            ),
            SizedBox(height: 2),
            Text(
              note.title.length > 30
                  ? (note.title.substring(0, 30).replaceAll("\n", " ") + '...')
                  : note.title.replaceAll("\n", " "),
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
            SizedBox(height: 6),
            Text(
              note.description.length > 90
                  ? ((minHeight == 150)
                      ? (note.description
                              .substring(0, 90)
                              .replaceAll("\n", " ") +
                          '...')
                      : (note.description
                              .substring(0, 70)
                              .replaceAll("\n", " ") +
                          '...'))
                  : note.description.replaceAll("\n", " "),
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                //fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// To return different height for different widgets
  double getMinHeight(int index) {
    switch (index % 4) {
      case 0:
        return 100;
      case 1:
        return 150;
      case 2:
        return 150;
      case 3:
        return 100;
      default:
        return 100;
    }
  }
}
