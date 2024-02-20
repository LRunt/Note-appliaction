import 'package:hive/hive.dart';

part 'note.g.dart';

@HiveType(typeId: 1)
class Note {
  /// Id is path to the note
  @HiveField(0)
  String id;

  /// Content of the user note
  @HiveField(1)
  String content;

  /// Constructor of the note
  Note({
    required this.id,
    this.content = '',
  });

  /// Text representation of the note
  @override
  String toString() {
    return "Note: $id, Content: $content";
  }
}
