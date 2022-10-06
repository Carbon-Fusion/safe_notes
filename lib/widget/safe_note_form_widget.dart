import 'package:flutter/material.dart';

class NoteFormWidget extends StatefulWidget {
  final String? title;
  final String? description;
  final String? isArchive;
  final ValueChanged<String> onChangedTitle;
  final ValueChanged<String> onChangedDescription;

  const NoteFormWidget({
    Key? key,
    this.title = '',
    this.description = '',
    this.isArchive = '',
    required this.onChangedTitle,
    required this.onChangedDescription,
  }) : super(key: key);

  @override
  State<NoteFormWidget> createState() => _NoteFormWidgetState();
}

class _NoteFormWidgetState extends State<NoteFormWidget> {
  List _undoTextHistory = <String>[];
  List _redoTextHistory = <String>[];

  TextEditingController _textController = TextEditingController();

  List _undoCursorHistory = <int>[];
  List _redoCursorHistory = <int>[];

  int _undoPreNumber = 0;
  int _undoPostNumber = 0;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTitle(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [undoButton(), redoButton()],
              ),
              SizedBox(height: 8),
              buildDescription(),
              SizedBox(height: 16),
            ],
          ),
        ),
      );

  Widget buildTitle() => TextFormField(
        maxLines: 2,
        initialValue: widget.title,
        enableInteractiveSelection: true,
        autofocus: false,
        toolbarOptions: ToolbarOptions(
          paste: true,
          cut: true,
          copy: true,
          selectAll: true,
        ),
        style: TextStyle(
          //color: Colors.white70,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Title',
          //hintStyle: TextStyle(color: Colors.white70),
        ),
        // validator: (title) =>
        //     title != null ? 'The title cannot be empty' : null,
        onChanged: widget.onChangedTitle,
      );

  Widget buildDescription() => TextFormField(
        maxLines: 30,
        initialValue: widget.description,
        enableInteractiveSelection: true,
        controller: _textController,
        autofocus: true,
        toolbarOptions: ToolbarOptions(
          paste: true,
          cut: true,
          copy: true,
          selectAll: true,
        ),
        style: TextStyle(/* color: Colors.white60, */ fontSize: 18),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Type something...',
          //hintStyle: TextStyle(color: Colors.white60),
        ),
        validator: (title) => title != null && title.isEmpty
            ? 'The description cannot be empty'
            : null,
        onChanged: (value) {
          _undoTextHistory.add(_textController.text);
          _undoCursorHistory.add(_textController.selection.start);
          _redoTextHistory = [""];

          widget.onChangedDescription(value);
          setState(() {});
        },
      );

  Widget undoButton() => IconButton(
      icon: Icon(Icons.undo),
      onPressed: (_undoTextHistory.length <= 1)
          ? null
          : () {
              if (_undoTextHistory.length <= 1) {
              } else {
                _undoPreNumber = _textController.text.length;
                _textController.text = "";
                _textController.text =
                    _undoTextHistory[_undoTextHistory.length - 2];
                _undoPostNumber = _textController.text.length;

                _textController.selection = TextSelection.fromPosition(
                    TextPosition(
                        offset:
                            _undoCursorHistory[_undoCursorHistory.length - 1] -
                                (_undoPreNumber - _undoPostNumber)));

                _redoTextHistory
                    .add(_undoTextHistory[_undoTextHistory.length - 1]);
                _redoCursorHistory
                    .add(_undoCursorHistory[_undoCursorHistory.length - 1]);

                _undoTextHistory.removeAt(_undoTextHistory.length - 1);
                _undoCursorHistory.removeAt(_undoCursorHistory.length - 1);

                setState(() {});
              }
            });

  Widget redoButton() => IconButton(
        icon: Icon(Icons.redo),
        onPressed: (_redoTextHistory.length <= 1)
            ? null
            : () {
                if (_redoTextHistory.length <= 1) {
                } else {
                  _textController.text = "";
                  _textController.text =
                      _redoTextHistory[_redoTextHistory.length - 1];

                  _textController.selection = TextSelection.fromPosition(
                      TextPosition(
                          offset: _redoCursorHistory[
                              _redoCursorHistory.length - 1]));

                  _undoTextHistory
                      .add(_redoTextHistory[_redoTextHistory.length - 1]);
                  _undoCursorHistory
                      .add(_redoCursorHistory[_redoCursorHistory.length - 1]);

                  _redoTextHistory.removeAt(_redoTextHistory.length - 1);
                  _redoCursorHistory.removeAt(_redoCursorHistory.length - 1);

                  setState(() {});
                }
              },
      );
}
