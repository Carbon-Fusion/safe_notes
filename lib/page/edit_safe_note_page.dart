import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safe_notes/databaseAndStorage/safe_notes_database.dart';
import 'package:safe_notes/model/safe_note.dart';
import 'package:safe_notes/widget/safe_note_form_widget.dart';
import 'package:share_plus/share_plus.dart';

class AddEditNotePage extends StatefulWidget {
  final SafeNote? note;
  late String saveInArchive;
  AddEditNotePage({
    Key? key,
    this.note,
    this.saveInArchive = "false",
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  bool savedOnce = false;
  late String title;
  late String description;
  late String isArchive;
  final String ZWSP = '​';
  final titleFocus = FocusNode(debugLabel: "titleFocus");
  final descriptionFocus = FocusNode(debugLabel: 'descriptionFocus');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        usableCheck();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    title = widget.note?.title ?? '';
    title = emptyTitle(title);
    description = widget.note?.description ?? '';
    isArchive = widget.note?.isArchive ?? widget.saveInArchive;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        usableCheck();
        return true;
      },
      child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            appBar: AppBar(
              actions: [
                undoButton(),
                redoButton(),
                shareButton(),
                buildButton(),
                copyButton(),
                deleteButton(),
              ],
            ),
            body: Form(
              key: _formKey,
              child: NoteFormWidget(
                title: title,
                isArchive: isArchive,
                description: description,
                onChangedTitle: (title) => setState(() => this.title = title),
                onChangedDescription: (description) =>
                    setState(() => this.description = description),
                titleFocus: titleFocus,
                descriptionFocus: descriptionFocus,
              ),
            ),
          )),
    );
  }

  Widget undoButton(){
    return IconButton(
        icon: Icon(Icons.undo),
        onPressed: () {
          try {
            if(descriptionFocus.hasFocus) {
              Actions.invoke(descriptionFocus.context!,
                  UndoTextIntent(SelectionChangedCause.keyboard));
            }else{
              Actions.invoke(titleFocus.context!,
                  UndoTextIntent(SelectionChangedCause.keyboard));
            }
          } catch (e) {
            print(e.toString());
          }
        });
  }

  Widget redoButton(){
    return IconButton(
        icon: Icon(Icons.redo),
        onPressed: () {
          try {
            if(descriptionFocus.hasFocus) {
              Actions.invoke(descriptionFocus.context!,
                  RedoTextIntent(SelectionChangedCause.keyboard));
            }else{
              Actions.invoke(titleFocus.context!,
                  RedoTextIntent(SelectionChangedCause.keyboard));
            }
          } catch (e) {
            print(e.toString());
          }
        });
  }
  Widget buildButton() {
    // return Padding(
    //   padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    //   child: ElevatedButton(
    //     style: ElevatedButton.styleFrom(
    //       //onPrimary: Colors.white,
    //       primary: isFormValid ? null : Colors.grey.shade700,
    //     ),
    //     onPressed: addOrUpdateNote,
    //     child: Text('Save'),
    //   ),
    // );
    return IconButton(
      onPressed: () async {
        if (usableCheck()) {
          Navigator.of(context).pop();
        }
      },
      icon: Icon(Icons.save_rounded),
    );
  }

  Widget shareButton() => IconButton(
      icon: Icon(Icons.share),
      onPressed: () async {
        if (!usableCheck()) return;
        Share.share(title + "\n" + description, subject: title);
      });
  Widget copyButton() => IconButton(
      icon: Icon(Icons.content_copy),
      onPressed: () async {
        if (!usableCheck()) return;
        Clipboard.setData(new ClipboardData(text: title + "\n" + description))
            .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied to your clipboard !')));
        });
      });
  bool isFormValid() {
    return description.isNotEmpty || title.isNotEmpty;
  }

  void startFixTitle() {
    if (title.isEmpty) title = ZWSP;
  }

  void endFixTitle() {
    if (title == ZWSP) title = '';
  }

  bool usableCheck() {
    if (isFormValid()) {
      startFixTitle();
      addOrUpdateNote();
      endFixTitle();
      return true;
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Not a valid note")));
      return false;
    }
  }

  void addOrUpdateNote() async {
      final isUpdating = widget.note != null || savedOnce;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      title: title,
      description: description,
      isArchive: isArchive,
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Updated!")));
    await NotesDatabase.instance.encryptAndUpdate(note);
  }

  String emptyTitle(String to_empty) {
    if (to_empty == "​")
      return '';
    else
      return to_empty;
  }

  Future addNote() async {
    final note = SafeNote(
      title: title,
      description: description,
      createdTime: DateTime.now(),
      isArchive: isArchive,
    );

    await NotesDatabase.instance.encryptAndStore(note);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Saved!")));
    savedOnce = true;
  }

  //TODO(FIX THIS SHIT)
  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = TextButton(
      child: Text("Continue"),
      onPressed: () {
        continueDeleteCallBack();
        Navigator.of(context).pop();
      },
    );
    Widget archiveButton = TextButton(
      child: Text("Move to Archive"),
      onPressed: () async {
        await updateArchiveStatus();
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    List<Widget> detailBar = [
      cancelButton,
      continueButton,
      archiveButton,
    ];
    if (widget.note!.isArchive == "true") {
      detailBar.removeLast();
    }
    AlertDialog alert = AlertDialog(
      title: Text("Confirm Deletion"),
      content: Text("Would you really like to delete the note?"),
      actions: detailBar,
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
      useRootNavigator: false,
    );
  }

  Widget deleteButton() => IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          if (widget.note == null) {
            Navigator.of(context).pop();
            return;
          }
          showAlertDialog(context);
        },
      );

  void continueDeleteCallBack() async {
    await NotesDatabase.instance.delete(widget.note!.id!);
    Navigator.of(context).pop();
  }

  Future updateArchiveStatus() async {
    final noteForArchive =
        await NotesDatabase.instance.decryptReadNote(widget.note!.id!);
    final note = noteForArchive.copy(
      title: noteForArchive.title,
      description: noteForArchive.description,
      isArchive: "true",
    );

    await NotesDatabase.instance.encryptAndUpdate(note);
    Navigator.of(context).pop();
  }
}
