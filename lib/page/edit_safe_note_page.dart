import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:safe_notes/databaseAndStorage/safe_notes_database.dart';
import 'package:safe_notes/model/safe_note.dart';
import 'package:safe_notes/widget/safe_note_form_widget.dart';

class AddEditNotePage extends StatefulWidget {
  final SafeNote? note;

  const AddEditNotePage({
    Key? key,
    this.note,
  }) : super(key: key);
  @override
  _AddEditNotePageState createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();

  late String title;
  late String description;
  late String isArchive;
  final String ZWSP = '​';
  @override
  void initState() {
    super.initState();
    title = widget.note?.title ?? '';
    title = emptyTitle(title);
    description = widget.note?.description ?? '';
    isArchive = widget.note?.isArchive ?? "false";
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          actions: [copyButton(),shareButton(),buildButton()],
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
          ),
        ),
      ));

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

        if(usableCheck()){
          addOrUpdateNote();
        }
      },
      icon: Icon(Icons.save_rounded),
    );
  }
  Widget shareButton() => IconButton(
      icon: Icon(Icons.share),
      onPressed: () async {
        if(!usableCheck())
            return;
        Share.share(title + "\n" + description, subject: title);
      });
  Widget copyButton() => IconButton(
      icon: Icon(Icons.content_copy),
      onPressed: () async {
        if(!usableCheck())
            return;
        Clipboard.setData(
            new ClipboardData(text: title + "\n" + description))
            .then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Copied to your clipboard !')));
        });
      });
  bool isFormValid() {
    return description.isNotEmpty;
  }
  void startFixTitle(){
    if(title.isEmpty)
        title = ZWSP;
  }
  void endFixTitle(){
    if(title == ZWSP)
        title = '';
  }
  bool usableCheck(){
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
    final isValid = _formKey.currentState!.validate();

    if (isValid) {
      final isUpdating = widget.note != null;

      if (isUpdating) {
        await updateNote();
      } else {
        await addNote();
      }

      Navigator.of(context).pop();
    }
  }

  Future updateNote() async {
    final note = widget.note!.copy(
      title: title,
      description: description,
      isArchive: isArchive,
    );

    await NotesDatabase.instance.encryptAndUpdate(note);
  }
  String emptyTitle(String to_empty){
    if(to_empty == "​")
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
  }
}
