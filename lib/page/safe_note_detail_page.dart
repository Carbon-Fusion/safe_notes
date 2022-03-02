import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

import 'package:share_plus/share_plus.dart';

import 'package:safe_notes/databaseAndStorage/safe_notes_database.dart';
import 'package:safe_notes/model/safe_note.dart';
import 'package:safe_notes/page/edit_safe_note_page.dart';
import 'package:safe_notes/databaseAndStorage/preference_storage_and_state_controls.dart';

class NoteDetailPage extends StatefulWidget {
  final int noteId;
  const NoteDetailPage({
    Key? key,
    required this.noteId,
  }) : super(key: key);

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late SafeNote note;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    refreshNote();
  }

  Future refreshNote() async {
    setState(() => isLoading = true);

    this.note = await NotesDatabase.instance.decryptReadNote(widget.noteId);

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: UnDecryptedLoginControl.getNoDecryptionFlag()
              ? null
              : [editButton(), deleteButton(), copyButton(), shareButton()],
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : Padding(
                padding: EdgeInsets.all(12),
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  children: [
                    SelectableText(
                      note.title,
                      style: TextStyle(
                        //color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      DateFormat.yMMMd().format(note.createdTime),
                      //style: TextStyle(color: Colors.white38),
                    ),
                    // SizedBox(height: 8),
                    // Text(
                    //   note.isArchive.toString(),
                    // ),
                    SizedBox(height: 8),
                    SelectableText(
                      note.description,
                      style: TextStyle(/*color: Colors.white70,*/ fontSize: 18),
                    )
                  ],
                ),
              ),
      );
  Widget shareButton() => IconButton(
      icon: Icon(Icons.share),
      onPressed: () async {
        if (isLoading) return;
        Share.share(note.title + "\n" + note.description, subject: note.title);
      });
  Widget copyButton() => IconButton(
      icon: Icon(Icons.content_copy),
      onPressed: () async {
        if (isLoading) return;
        Clipboard.setData(
                new ClipboardData(text: note.title + "\n" + note.description))
            .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied to your clipboard !')));
        });
      });
  Widget editButton() => IconButton(
      icon: Icon(Icons.edit_outlined),
      onPressed: () async {
        if (isLoading) return;

        await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AddEditNotePage(note: note),
        ));

        refreshNote();
      });

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
    if(note.isArchive == "true"){
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
          showAlertDialog(context);
        },
      );

  void continueDeleteCallBack() async {
    await NotesDatabase.instance.delete(widget.noteId);
    Navigator.of(context).pop();
  }

  Future updateArchiveStatus() async {
    final noteForArchive =
        await NotesDatabase.instance.decryptReadNote(widget.noteId);
    final note = noteForArchive.copy(
      title: noteForArchive.title,
      description: noteForArchive.description,
      isArchive: "true",
    );

    await NotesDatabase.instance.encryptAndUpdate(note);
    Navigator.of(context).pop();
  }
}
