import 'package:hive/hive.dart';
import 'package:untitled/Models/notes_model.dart';

class Boxes
{
    static Box<NotesModel> getData() => Hive.box<NotesModel>('notes');
}