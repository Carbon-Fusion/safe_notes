import 'package:safe_notes/databaseAndStorage/preference_storage_and_state_controls.dart';
import 'package:safe_notes/aes256_encryption/aes_256bit_encryption_handler.dart';

final String tableNotes = 'safe_notes';

class NoteFields {
  static final List<String> values = [id, title, description, time, isArchive];

  static final String id = '_id';
  static final String title = 'title';
  static final String description = 'description';
  static final String time = 'time';
  static final String isArchive = 'isArchive';
}

class SafeNote {
  final int? id;
  final String title;
  final String description;
  final DateTime createdTime;
  final String? isArchive;
  const SafeNote({
    this.id,
    required this.title,
    required this.description,
    required this.createdTime,
    required this.isArchive,
  });

  SafeNote copy({
    int? id,
    String? title,
    String? description,
    DateTime? createdTime,
    String? isArchive,
  }) =>
      SafeNote(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        createdTime: createdTime ?? this.createdTime,
        isArchive: isArchive ?? this.isArchive,
      );

  static SafeNote fromJsonAndDecrypt(Map<String, dynamic> json) => SafeNote(
        id: json[NoteFields.id] as int?,

        title: UnDecryptedLoginControl.getNoDecryptionFlag()
            ? json[NoteFields.title] as String
            : decryptAES(json[NoteFields.title] as String,
                PhraseHandler.getPass()), //json[NoteFields.title] as String,

        description: UnDecryptedLoginControl.getNoDecryptionFlag()
            ? json[NoteFields.description] as String
            : decryptAES(
                json[NoteFields.description] as String,
                PhraseHandler
                    .getPass()), //json[NoteFields.description] as String,

        createdTime: DateTime.parse(json[NoteFields.time] as String),
        isArchive: json[NoteFields.isArchive] as String?,
      );

  Map<String, dynamic> toJsonAndEncrypted() => {
        NoteFields.id: id,
        NoteFields.title: encryptAES(title, PhraseHandler.getPass()), //title,
        NoteFields.description:
            encryptAES(description, PhraseHandler.getPass()), //description,
        NoteFields.time: createdTime.toIso8601String(),
        NoteFields.isArchive : isArchive,
      };

  Map<String, dynamic> toJson(bool isEncryptionNeeded) {
    return {
      //"${NoteFields.id}": this.id,
      '"${NoteFields.title}"': isEncryptionNeeded
          ? '"${encryptAES(this.title, PhraseHandler.getPass())}"'
          : '"${this.title}"',
      '"${NoteFields.description}"': isEncryptionNeeded
          ? '"${encryptAES(this.description, PhraseHandler.getPass())}"'
          : '"${this.description}"',
      '"${NoteFields.time}"': '"${this.createdTime.toIso8601String()}"',
      '"${NoteFields.isArchive}"': '"${this.isArchive}"',
    };
  }

  static SafeNote fromJson(Map<String, dynamic> json) {
    return SafeNote(
      title: ImportEncryptionControl.getIsImportEncrypted()
          ? decryptAES(json[NoteFields.title] as String,
              ImportPassPhraseHandler.getImportPassPhrase())
          : json[NoteFields.title] as String,
      description: ImportEncryptionControl.getIsImportEncrypted()
          ? decryptAES(json[NoteFields.description] as String,
              ImportPassPhraseHandler.getImportPassPhrase())
          : json[NoteFields.description] as String,
      createdTime: DateTime.parse(json[NoteFields.time] as String),
      isArchive: json[NoteFields.isArchive] as String,
    );
  }
}
